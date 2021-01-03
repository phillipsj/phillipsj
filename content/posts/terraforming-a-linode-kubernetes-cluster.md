---
title: "Terraforming a Linode Kubernetes Cluster"
date: 2021-01-02T12:35:36-05:00
tags:
- YAML
- k8s
- Kubernetes 
- Terraform
- Linode
---

I have been wanting to start self-hosting some services myself. I don't mind paying for services if I know they will be around and respect my privacy. After a little research, I decided that I would host a Kubernetes cluster on either Linode or Digital Ocean because they offer some of the best pricing for what I need. After a little research, I decided that I would use Linode. I plan to host a single node cluster, which should cost be about ten dollars per month. Digital Ocean is the only other provider that can touch that price. That is a really small node, which will be enough to host the few things I need to at the moment. I can quickly scale up as needed.

I am a big fan of a Terraform, so I will be Terraforming its creation. Let's dive into how to do that. We need to get our Linode token using their [guide](https://www.linode.com/docs/guides/getting-started-with-the-linode-api/) and set an environment variable. I like to add this to my *.bashrc* to make it easier to consume. With our token in place, we can now initialize Terraform to ensure it all works. A side note about the token carefully read through the permissions required and select what you need.

Here is the basic Terraform file setting up the provider. Create *main.tf* and add the HCL below.

```HCL
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
```

We now have our basic Terraform, so let's initialize.

```Bash
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding linode/linode versions matching "1.13.4"...
- Installing linode/linode v1.13.4...
- Installed linode/linode v1.13.4 (signed by a HashiCorp partner, key ID F4E6BBD0EA4FE463)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

We have confirmed that our API key works, we can build out our cluster. Add the following to your *main.tf* file.

```HCL
resource "linode_lke_cluster" "cluster" {
    label       = "cluster"
    k8s_version = "1.18"
    region      = ""
    tags        = ["self-hosted"]

    pool {
        type  = ""
        count = 1
    }
}
```

We need to decide on the region we want to use. Linode has a list [here](https://api.linode.com/v4/regions), and if you go to create a resource in the Cloud Manager, you can do a speed test. I think that is a cool feature as it helps you decide the best region for latency. US Central, Dallas, is the best one for me. We also need to determine the node size we want to use. I want to use the smallest node that I can, and LKE limits it to a 2GB standard node. Here is the final configuration.

```HCL
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
```

Now we can run a plan to double-check everything.

```HCL
$ terraform plan

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # linode_lke_cluster.cluster will be created
  + resource "linode_lke_cluster" "cluster" {
      + api_endpoints = (known after apply)
      + id            = (known after apply)
      + k8s_version   = "1.18"
      + kubeconfig    = (sensitive value)
      + label         = "cluster"
      + region        = "us-central"
      + status        = (known after apply)
      + tags          = [
          + "self-hosted",
        ]

      + pool {
          + count = 1
          + id    = (known after apply)
          + nodes = (known after apply)
          + type  = "g6-standard-1"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

The plan looks good, so we can now apply it.

```Bash
$ terraform apply

linode_lke_cluster.cluster: Creating...
linode_lke_cluster.cluster: Still creating... [10s elapsed]
linode_lke_cluster.cluster: Still creating... [20s elapsed]
linode_lke_cluster.cluster: Still creating... [30s elapsed]
linode_lke_cluster.cluster: Still creating... [40s elapsed]
linode_lke_cluster.cluster: Still creating... [50s elapsed]
linode_lke_cluster.cluster: Still creating... [1m0s elapsed]
linode_lke_cluster.cluster: Still creating... [1m10s elapsed]
linode_lke_cluster.cluster: Creation complete after 1m10s [id=*****]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Our cluster is now up and running. The LKE resource in Terraform has the kubeconfig available as an output. Let's update our *main.tf* to output the kubeconfig from our cluster. Add the following to the bottom. We mark it as sensitive, so it isn't displayed in the output unless explicitly called. The kubeconfig coming from Linode is Base64 encoded, so we can decode it using Terraform, or you can do it on the command line. I am doing it with Terraform.

```HCL
output "kubeconfig" {
  description = "Linode kubeconfig."
  value       = base64decode(linode_lke_cluster.cluster.kubeconfig)
  sensitive   = true
}
```

Now we can run our *apply* again.

```Bash
$ terraform apply

Terraform will perform the following actions:

Plan: 0 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kubeconfig = (sensitive value)

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

kubeconfig = <sensitive>
```

Great! We now have our kubeconfig being returned as output. I am now going to call it, decode it, and append it to my local kubeconfig.

```Bash
$ terraform output kubeconfig >> $HOME/.kube/config
```

Now let's list our contexts with kubectl.

```Bash
$ kubectl config get-contexts
CURRENT   NAME           CLUSTER    AUTHINFO         NAMESPACE
          lke*****-ctx   lke*****   lke*****-admin   default
```

Let's set our context to be the new cluster.

```Bash
$ kubectl config set-context lke*****-ctx
Context "lke*****-ctx" modified.
```

Finally, we can connect to our cluster and get the node information.

```Bash
$ kubectl get nodes
NAME                          STATUS   ROLES    AGE   VERSION
lke*****-*****-************   Ready    <none>   29m   v1.18.8
```

Awesome! We now have a basic cluster on Linode that is ready to be configured. It looks like the default configuration for Linode is the Calico CNI, and there is a CSI for Linode. That's good and leaves configuring RBAC and other basic security configurations. I will not be doing that in this post so stay tuned.

Thanks for reading,

Jamie
