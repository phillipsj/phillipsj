---
title: "Generating SSH Keys With Terraform"
date: 2021-01-27T20:07:31-05:00
tags:
- Open Source
- Terraform
- HashiCorp
- Linux
- Linode
- SSH
---

I have been learning lots of new things about Terraform. I have spent a lot of time in some odd crevices of the documentation and code, and I still keep finding cool new features. This functionality is provided with the [TLS](https://registry.terraform.io/providers/hashicorp/tls/latest) provider. I will show you how to leverage the [tls_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) resource to generate an SSH key and assign that key to a Linode server we will create. Let's get into it.


## The Terraform Template

Create a *main.tf* and add the Terraform block with the TLS and Linode providers defined and configured.

```HCL
terraform {
  required_version = ">=0.14.3"
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.13.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.0.0"
    }
  }
}

provider "linode" {
  token = "<LINODE_TOKEN>"
}

provider "tls" {}
```

Now we need to add a *tls_private_key* resource to generate our SSH key. We will set the algorithm to RSA and the rsa_bits property to 4096, so we generate a suitable key.

```HCL
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}
```

Great, we will now have a key generated. Our private key will be stored in Terraform state. If you want to generate a new key, you will either need to destroy it or taint it, so it gets regenerated. At this point, I will say that this may not be how you would want to do in production. I see this more for demos, development, and proof of concepts.

Now we are going to create a nanode on Linode and use our SSH key for access. Notice that we are referencing our *tls_private_key* resource in the authorized_keys property, and we are pulling the public_key_openssh property. We have to use the chomp function with the public_key_openssh property to remove the line ending since this is intended to be a complete authorized_keys file.

```HCL
resource "linode_instance" "ssh_tf" {
  label           = "ssh-tf"
  image           = "linode/ubuntu18.04"
  region          = "us-east"
  type            = "g6-nanode-1"
  authorized_keys = [chomp(tls_private_key.ssh.public_key_openssh)]
  root_pass       = "S3cr#tP@ssw0rd"
}
```

The last thing we need to do is to generate our outputs. The two outputs we need are our private key and the IP address of our nanode.

```HCL
resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "linode.pem"
  file_permission = "0600"
}

output "nanode_ip" {
  value = linode_instance.ssh_tf.ip_address
}
```

Finally, we made it. Now we can apply our Terraform.

```Bash
$ terraform apply -auto-approve

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

nanode_ip = "XX.XX.XX.XXX"
```

With our resources created, let's SSH into our new server.

```Bash
$ ssh -i linode.pem root@XX.XX.XX.XXX
Welcome to Ubuntu 18.04.5 LTS (GNU/Linux 4.15.0-118-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Thu Jan 28 02:10:57 UTC 2021

  System load:  0.08              Processes:           101
  Usage of /:   9.3% of 24.06GB   Users logged in:     0
  Memory usage: 12%               IP address for eth0: XX.XX.XX.XXX
  Swap usage:   0%

0 packages can be updated.
0 updates are security updates.



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

root@localhost:~# 
```

It worked, and we are using our Terraform generated SSH key to access our nanode on Linode. Make sure to clean up your resources when you are done.

## Conclusion

This feature is another feature that you probably won't use all that much in a production scenario. Yet, it makes it easier to generate everything someone will need in the Terraform when it comes to learning and teaching. Generating these items with Terraform prevents the users from tooling overload and demonstrates that you can automate most things.

Thanks for reading,

Jamie
