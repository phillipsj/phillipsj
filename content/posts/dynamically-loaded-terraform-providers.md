---
title: "Dynamically Loaded Terraform Providers"
date: 2021-01-17T20:23:42-05:00
tags:
- Terraform
- HashiCorp
- Open Source
- Kubernetes
---

Typically, Terraform providers are loaded when Terraform executes. This means that your configuration for the provider has to be set before you run any Terraform command. There are some situations where you need information from your Terraform execution to configure a provider. This can be a challenge and not super obvious if you need to do it. Let's dive into a scenario where this exists.

As I mentioned in the introduction, you may need to get the configuration from executing Terraform to configure another provider. The case that immediately comes to mind for me is when working with Kubernetes. You use Terraform to create the Kubernetes cluster, and then you want to use the Kubernetes provider to bootstrap some manifests in your cluster. The problem is that you won't have your *.kubeconfig* until the creation of the cluster, so you can't use the provider. This is where having the ability to load a provider during execution dynamically comes into play. Terraform will, in fact, allow you to pull the *.kubeconfig* from your created cluster and use that in your Kubernetes provider. It just requires an odd implementation.

## Existing Kubernetes Cluster Terraform

Let's look at the Linode cluster that I set up in a previous [post](https://www.phillipsj.net/posts/terraforming-a-linode-kubernetes-cluster/). In that example, I showed you all to retrieve and decode your *.kubeconfig*. We are going to leverage them in configuring the Kubernetes provider. Here is the Linode example again.

```YAML
terraform {
  required_version = "=0.14.3"
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.13.4"
    }
  }
}

provider "linode" {
  token = "<LINODE_TOKEN>"
}

resource "linode_lke_cluster" "cluster" {
  label       = "cluster"
  k8s_version = "1.18"
  region      = "us-central"
  tags        = ["self-hosted"]

  pool {
    type  = "g6-standard-1"
    count = 1
  }
}

output "kubeconfig" {
  description = "Linode kubeconfig."
  value       = base64decode(linode_lke_cluster.cluster.kubeconfig)
  sensitive   = true
}
```

## Configuring the Kubernetes Provider

Let's go ahead and add the Kubernetes and local providers to our list of required providers.

```YAML
terraform {
  required_version = "=0.14.3"
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.13.4"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "1.13.3"
    }
    local = {
      source = "hashicorp/local"
      version = "2.0.0"
    }
  }
}
```

Now we need to configure our provider, and this is where the magic happens. Notice that we have given our provider a unique name, called an [alias](https://www.terraform.io/docs/configuration/providers.html#alias-multiple-provider-configurations), and we are setting a custom config path to point to a *kubeconfig* we haven't created yet. When we set an alias, the configuration isn't loaded during execution because it isn't the default provider. The configuration will get loaded the first time we use it.

```YAML
provider "kubernetes" {
  alias = "lke"
  load_config_file = "true"
  config_path = ".tfkubeconfig"
}
```

Now we don't have our *.tfkubeconfig* file, so let's make sure that it gets created using the local provider. Our content will be the same as the output variable we have already defined. We will then write it to the file that we have specified as our *kubeconfig*. Since this references the LKE cluster, we don't need to set the depends_on.

```YAML
provider "local" {}

resource "local_file" "kubeconfig" {
  content  = base64decode(linode_lke_cluster.cluster.kubeconfig)
  filename = ".tfkubeconfig"
}
```

We have it all configured, so let's put it to use.

## Creating a Kubernetes resource with Terraform

Now we can test this all out by creating a busybox pod on our cluster. The one particular thing that we need to do is specify which Kubernetes provider we want to use. Remember, if we treated the one we had as a *default* it would try to load the config upon execution and error since it doesn't exist. This means that we need to configure our resource to use our Kubernetes provider by its alias. We can do that by setting the provider property and specifying our provider using its alias. 

```YAML
resource "kubernetes_pod" "busybox" {
  provider = kubernetes.lke

  metadata {
    name = "busybox-tf"
  }

  spec {
    container {
      image   = "busybox"
      command = ["sleep", "3600"]
      name    = "busybox"
      
      image_pull_policy = "IfNotPresent"
    }
    
    restart_policy = "Always"
  }
}
```

If we were to run this right now, it probably isn't going to work because there isn't a dependency between the pod resource and the creation of the configuration file. Let's set that now.

```YAML
resource "kubernetes_pod" "busybox" {
  provider = kubernetes.lke

  metadata {
    name = "busybox-tf"
  }

  spec {
    container {
      image   = "busybox"
      command = ["sleep", "3600"]
      name    = "busybox"
      
      image_pull_policy = "IfNotPresent"
    }
    
    restart_policy = "Always"
  }
  
  depends_on = [local_file.kubeconfig]
}
```

Now we can execute our Terraform, and it should dynamically configure the Kubernetes provider and create our pod. Let's give that a try.

```Bash
$ terraform plan

Plan: 2 to add, 0 to change, 0 to destroy.
```

Adding two items is expected. The two items will be the *kubeconfig* and the busybox pod. Let's apply that now.

```Bash
$ terraform apply
local_file.kubeconfig: Creating...
local_file.kubeconfig: Creation complete after 0s
kubernetes_pod.busybox: Creating...
kubernetes_pod.busybox: Creation complete after 4s

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

kubeconfig = <sensitive>
```

Great, we should now have a busybox pod running in our cluster. We can verify that with kubectl.

```Bash
$ kubectl --kubeconfig .tfkubeconfig get pods
NAME         READY   STATUS    RESTARTS   AGE
busybox-tf   1/1     Running   0          3m50s
```

We have confirmed that we have a busybox pod running in our cluster. Here is the complete Terraform.

```YAML
terraform {
  required_version = "=0.14.3"
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.13.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "1.13.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.0.0"
    }
  }
}

provider "linode" {
  token = "<LINODE_TOKEN>"
}

provider "kubernetes" {
  alias            = "lke"
  load_config_file = "true"
  config_path      = ".tfkubeconfig"
}

provider "local" {}

resource "linode_lke_cluster" "cluster" {
  label       = "cluster"
  k8s_version = "1.18"
  region      = "us-central"
  tags        = ["self-hosted"]

  pool {
    type  = "g6-standard-1"
    count = 1
  }
}

resource "local_file" "kubeconfig" {
  content  = base64decode(linode_lke_cluster.cluster.kubeconfig)
  filename = ".tfkubeconfig"
}

resource "kubernetes_pod" "busybox" {
  provider = kubernetes.lke

  metadata {
    name = "busybox-tf"
  }

  spec {
    container {
      image   = "busybox"
      command = ["sleep", "3600"]
      name    = "busybox"

      image_pull_policy = "IfNotPresent"
    }

    restart_policy = "Always"
  }

  depends_on = [local_file.kubeconfig]
}

output "kubeconfig" {
  description = "Linode kubeconfig."
  value       = base64decode(linode_lke_cluster.cluster.kubeconfig)
  sensitive   = true
}

```

## Conclusion

I hope you found this helpful. This is another one of those techniques that aren't an everyday technique you will have to use. However, it will come in handy when you want to Terraform for items, and you depend on the configuration to come from within Terraform. Provider aliases are also handy when you need to perform multi-region deployments of a resource. You can define the provider multiple times and specify which one to use for a resource to be in the correct region. Before we are entirely wrap-up, one last item, make sure to clean up that *.tfkubeconfig* file as it has sensitive information for your cluster.

Thanks for reading,

Jamie
