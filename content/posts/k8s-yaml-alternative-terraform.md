---
title: "K8s YAML Alternative: Terraform"
date: 2020-02-16T14:39:36-05:00
tags:
- YAML
- k8s
- Kubernetes 
- Terraform
---

In a previous set of posts I have shown examples using [JSON](https://www.phillipsj.net/posts/k8s-yaml-alternative-json/) and [.NET](https://www.phillipsj.net/posts/k8s-yaml-alternative-dotnet/) instead of YAML. This post is going to show another alternative using Terraform. I will be using the same Kubernetes object to allow comparison.

## YAML Object

We are going to create a busybox pod. This manifest isn't a super simple example, nor is it a complex example. This manifest should allow demonstrating the differences. Here is the pod YAML.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  containers:
  - image: busybox
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
    name: busybox
  restartPolicy: Always
```

Now we can save this as *busybox.yaml* and create it on our cluster. 

```bash
$ kubectl apply -f busybox.yaml
pod/busybox created
```

Now let's take a look at this in Terraform.

## Terraform

This example is going to leverage the [Kubernetes Provider](https://www.terraform.io/docs/providers/kubernetes/index.html) for Terraform. Let's create a Terraform file with the provider and the object.

```bash
$ mkdir k8stf && cd k8stf && touch main.tf
```

Now we can setup our provider, create our object, and execute the Terraform.

```hcl
provider "kubernetes" {
}

resource "kubernetes_pod" "busybox" {
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

Now we can init Terraform.

```bash
$ terraform init
* provider.kubernetes: version = "~> 1.11"

Terraform has been successfully initialized!
```

Now, execute Terraform plan.

```bash
$ terraform plan
Plan: 1 to add, 0 to change, 0 to destroy.
```  

Finally, let's create our Kubernetes object with Terraform.

```bash
$ terraform apply
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Now, if we get all pods, we should see it running.

```bash
$ kubectl get pods 
NAME              READY   STATUS    RESTARTS   AGE
busybox-tf   1/1     Running   0          30m
```  

Don't forget to clean up your cluster by deleting the object, which can be done with Terraform.

```bash
$ terraform destroy
Destroy complete! Resources: 1 destroyed.
```

## Wrap Up

The key take away from this is that you don't have to use YAML. As with any markup, an excellent tool goes a long way in making it more manageable. If you are already using Terraform in your environment, then I would recommend you trying out the Kubernetes provider to see if it meets your needs or not. I personally like HCL and I see it as having the simplicity of YAML with a little better tooling. 

Stay tuned for more alternatives.

Thanks for reading,

Jamie
