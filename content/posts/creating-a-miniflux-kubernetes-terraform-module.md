---
title: "Creating a Miniflux Kubernetes Terraform Module"
date: 2021-01-21T14:56:34-05:00
tags:
- Linux
- Open Source
- RSS
- Self-hosted
- Miniflux
- Terraform
- HashiCorp
- Kubernetes
- Postgres
- PostgreSQL
---

I posted a few days ago that I thought that leveraging Terraform for creating Kubernetes resoures is under utilized. With that being repeated again, I decided that I would build a module for deploying [miniflux](https://miniflux.app/) to my Linode k8s cluster. 


## The Plan

There are some examples for [Docker and Docker compose](https://miniflux.app/docs/installation.html#docker) in the documentation that we will be using to get this up and running. The official image is using Alpine as the base and we will use the PostgreSQL Alpine base too for our database. I am not planning to actually provision any external storage for the PostgreSQL as making periodic backups should be sufficient for a personal feed reader. I do plan to put some resource limits in place too, just not immediately. 

Now when I develop a Terraform module, I start with putting in the basic configuration with no configurability. Once I know that works, I go back and start abstracting out what needs to be customizable. I then will finish off any packaging/documentation that I need. Let's get started with the process.

## Creating the basic implementation.

Create a directory and inside that directory create a *main.tf* and a modules directory.

```Bash
$ touch main.tf && mkdir modules
$ ls -l
main.tf
modules
```

Let's do a quick edit of our *main.tf* to configure our providers.

```HCL
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "1.13.3"
    }
  }
}

provider "kubernetes" {
  config = "path/to/config"
}
```

Now in our modules directory let's create our miniflux k8s modules.

```Bash
$ cd modules && mkdir miniflux-kubernetes
$ touch {main,outputs,variables}.tf
$ ls -l
main.tf
outputs.tf
variables.tf
```

Let's define our miniflux and PostgreSQL pods in the *main.tf* file in our module.

```HCL
resource "kubernetes_pod" "postgres" {
  metadata {
    name = "minifluxdb"
    labels {
        app = "minifluxdb"
    }
  }

  spec {
    container {
      image = "postgres/postgres:alpine"
      name  = "minifluxdb"

      env {
        name  = "POSTGRES_USER"
        value = "minflux"
      }

      env {
        name  = "POSTGRES_PASSWORD"
        value = "miniflux123"
      }

      port {
        container_port = 5432
      }
    }
  }
}

resource "kubernetes_pod" "miniflux" {
  metadata {
    name = "miniflux"
    labels {
      app = "miniflux"
    }
  }

  spec {
    container {
      image = "miniflux/miniflux:latest"
      name  = "miniflux"

      env {
        name  = "DATABASE_URL"
        value = "postgres://miniflux:miniflux123@minifluxdb/miniflux?sslmode=disable"
      }
      env {
        name  = "RUN_MIGRATIONS"
        value = "1"
      }
      env {
        name  = "CREATE_ADMIN"
        value = "1"
      }
      env {
        name  = "ADMIN_USERNAME"
        value = "admin"
      }
      env {
        name  = "ADMIN_PASSWORD"
        value = "test123"
      }

      port {
        container_port = 8080
      }
    }
  }
}

```

This is a very basic configuration. If we were to apply the Terraform now, we wouldn't be able to connect to the database. We need to define a service for the database.

```HCL
resource "kubernetes_service" "db_service" {
  metadata {
    name = "minifluxdb"
  }
  spec {
    selector = {
      app = "${kubernetes_pod.postgres.metadata.0.labels.app}"
    }
    session_affinity = "ClientIP"
    port {
      port        = 5432
      target_port = 5432
    }
  }
}
```

We should now have a basic working module that if we deployed it, we should see a healhty status. Let's do that to make sure we are doing this correctly. Let's jump back to the *main.tf* in the root and add the module.

```HCL
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "1.13.3"
    }
  }
}

provider "kubernetes" {
  config = "path/to/config"
}

module "miniflux-kubernetes" {
  source = "modules/miniflux-kubernetes"
}
```

Let's initialize and apply it.

```Bash
$ terraform init && terraform apply -auto-approve
```

