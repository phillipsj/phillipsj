---
title: "PostgreSQL Backend for Terraform"
date: 2021-01-20T20:43:17-05:00
tags:
- Open Source
- Terraform
- HashiCorp
- PostgreSQL
---


I have started configuring my Kubernetes cluster to begin doing some self-hosting of a few small services that I have determined to be critical and not something I want to depend on an external service. As part of that, I figured an [LKE cluster](https://www.phillipsj.net/posts/terraforming-a-linode-kubernetes-cluster/) on Linode. I am using Terraform to do all of that configuration, and I decided that I need to use a remote backend for my Terraform state. 

## Background

State locking isn't a feature with all remote backends, and it is a feature that I feel should be required. I am just a single person and could get away without it, but why should I. The Azure Storage backend supports locking out of the box, but S3 doesn't. That quickly ruled out any cloud options that I wanted to use, so I decided to give the [PostgreSQL backend](https://www.terraform.io/docs/backends/types/pg.html) a try and use my PG database running on my NAS. With all of that background out of the way, let's get a PostgreSQL DB running as a container to test the configuration.

### PostgreSQL Container Setup

I will do all of my setup and testing using Docker compose before doing this on my NAS. It will help me work out how it will work with Terraform and help others get something running locally. Here is the Docker compose for the database using Alpine to keep it small. Now I am only running the Terraform backend in this container. There is a requirement to name the database *terraform_backend*, which we can configure as the default database.

```YAML
version: '3.1'

services:

  db:
    image: postgres:13.1-alpine
    restart: always
    ports:
      - 5432:5432
    environment:
      POSTGRES_PASSWORD: tfbackend123
      POSTGRES_DB: terraform_backend
```

Now we can bring that database up.

```Bash
$ docker-compose up
Pulling DB (postgres:13.1-alpine)...
13.1-alpine: Pulling from library/postgres
Digest: sha256:0b6f8681377407396a54512812789bd311afd40b2b4e2bd66e9d98da6632bd8e
Status: Downloaded newer image for postgres:13.1-alpine
Creating pgtf_db_1 ... done
Attaching to pgtf_db_1
```

We are good to go with the database part of the setup.

### Configuring the PostgreSQL Backend

Now we can configure our Terraform backend to use this database we just created. Once we have the backend working, we will create a straightforward resource to see what it does in the database. Let's get the backend in our *main.tf.*

```HCL
terraform {
  backend "pg" {
    conn_str = "postgres://postgres:tfbackend123@localhost/terraform_backend?sslmode=disable"
  }
}
```

When we initialize Terraform, you will see that it connects. Let's do that now.

```Bash
$ terraform init
initializing the backend...

Successfully configured the backend "pg"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Awesome! It shows that it is working as expected. I am going to check to see if I see the schema in the database.

```Bash
terraform_backend> SELECT * FROM terraform_remote_state.states
[2021-01-20 22:27:12] 0 rows retrieved in 206 ms (execution: 7 ms, fetching: 199 ms)
```

Nice, we can see that the terraform_remote_state schema was created, and a table called states now exists. It has three columns: id, name, and data. I want to explore this a touch more, so I will add a local provider and create a file resource to generate some state data.

```HCL
terraform {
  backend "pg" {
    conn_str = "postgres://postgres:tfbackend123@localhost/terraform_backend?sslmode=disable"
  }

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.0.0"
    }
  }
}

provider "local" {}

resource "local_file" "hello" {
  content  = "Hello!"
  filename = "hello.txt"
}
```

Now, we can initialize and apply to see what gets added to that table.

```Bash
$ terraform init && terraform apply -auto-approve
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

A quick query of the table again results in the following.

```Bash
terraform_backend> SELECT * FROM terraform_remote_state.states
[2021-01-20 22:36:37] 1 row retrieved starting from 1 in 82 ms (execution: 12 ms, fetching: 70 ms)
```

We have one row inserted with the id being unique. The name field is the workspace, so in this case, it is *default*. The data field is just the JSON contained in what you usually would have inside a state file stored locally. Surprisingly it is a straightforward table structure. The execution seems no slower than other backends that I have used, so that is a good sign. 

## What's next

Now that I have created a basic setup of the PostgreSQL backend and understand how it works, I am ready to use it for my self-hosted project. I have existing resources already deployed, so I will do a follow-up post showing how to go from not using a remote backend to using one.

Thanks for reading,

Jamie
