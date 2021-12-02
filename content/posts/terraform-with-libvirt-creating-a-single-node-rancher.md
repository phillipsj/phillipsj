---
title: "Terraform with libvirt: Creating a single node Rancher"
date: 2021-12-01T22:28:13-05:00
tags:
- Open Source
- Terraform
- HashiCorp
- Cloud
- openSUSE
- KVM
- libvirt
- Rancher
---

Previously I discussed that I was starting to test [KVM on openSUSE](https://www.phillipsj.net/posts/opensuse-perfect-kvm-setup/) in my homelab and this is a follow-up, and an introduction to using the [Terraform libvirt provider](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs). I am enjoying using this provider, and I like how it feels to use it. I haven't been using Terraform as heavily the last few months, and it feels good to be back using it in my workflow. In the repo, there are [examples](https://github.com/dmacvicar/terraform-provider-libvirt/tree/main/examples/v0.13) in the repo on GitHub, which provide a basic overview of most of the features. In this post, I will cover one of the scenarios that I am using it to do, which is to create a single node Rancher server deployed using Docker.

## Setup

You will need the following to follow along:

* Latest version of Terraform
* A KVM server
* SSH key access configured to the KVM server if not local.

Once you have those items, let's get started.

## Configuring libvirt provider

The Terraform documentation makes it very easy to do this part. Just add the following to your `main.tf`.

```HCL
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.11"
    }
  }
}

provider "libvirt" {
  # Configuration options
}
```

We need to set our environment variable to define the `uri` we want to connect. I have included an example for local and remote access via SSH. You only need to set it based on which one you are using.

```Bash
# Local 
export LIBVIRT_DEFAULT_URI="qemu:///system"

# Remote over SSH
export LIBVIRT_DEFAULT_URI="qemu+ssh://<user>@<server name or ip>/system"
```

Now we can run our `init` command to make sure we have everything set up correctly.

```Bash
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding dmacvicar/libvirt versions matching "0.6.11"...
- Installing dmacvicar/libvirt v0.6.11...
- Installed dmacvicar/libvirt v0.6.11 (self-signed, key ID 96B1FE1A8D4E1EAB)


Terraform has been successfully initialized!
```

Great, we can now get started creating our VM.

## Picking our base image and creating volumes

One of the biggest motivations for making the switch was to leverage Linux cloud images in the qcow2 format. Proxmox doesn't have an easy or intuitive way to import qcow2 images, which was another motivator for trying this out. Most enterprise Linux distribution makers provide qcow2 images, and that includes openSUSE. We will define our base image as [Tumbleweed JeOS](https://en.opensuse.org/Portal:JeOS), pronounced Juice, and store it in the default storage pool. In the provider, the *libvirt_volume* refers to a disk.

```HCL
# base image
resource "libvirt_volume" "tumbleweed" {
  name   = "tumbleweed"
  pool   = "default"
  source = "http://download.opensuse.org/tumbleweed/appliances/openSUSE-Tumbleweed-JeOS.x86_64-OpenStack-Cloud.qcow2"
  format = "qcow2"
}
```

Now we can take this base image and use it to create the actual volume for our Rancher VM. The default size will be 1GB, so we will need to increase that in our new volume. We will set the base volume id to be our Tumbleweed image, and then we will increase the size to 10GB which needs to be in bytes.

```HCL
resource "libvirt_volume" "rancher" {
  name           = "rancher"
  base_volume_id = libvirt_volume.tumbleweed.id
  pool           = "default"
  size           = 10737418240
}
```

With our volumes all configured, we need to start handling our [cloud-init](https://cloudinit.readthedocs.io/).

## Cloud-init 

Most examples show defining both a `user_data` and `network_config` files for cloud-init to use to configure the VM, and we will do the same to make this a hearty post. Let's get started with the network config first.

```HCL
locals {
  network_config = yamlencode({
    network = {
      version = 1
      config = [{
        type = "physical"
        name = "eth0"
        subnets = [{
          type = "dhcp"
        }]
      }]
    }
  })
}
```

We are defining it as a TF object then encoding that as YAML to use it later. Now we can do the same for the user data.

```HCL
locals {

  # Network config is here

  user_data = yamlencode({
    users = [{
      name = "root"
      ssh_authorized_keys = [""]
    }]
    ssh_pwauth = true
    chpasswd = {
      list = ["root:linux"]
    }
    disable_root = false
    growpart = {
      mode = "auto"
      devices = ["/"]
    }
    packages = ["docker"]
    runcmd = [
      "sed  -i '/PermitRootLogin/s/.*/PermitRootLogin yes/' /etc/ssh/sshd_config",
      "systemctl restart sshd",
      "systemctl enable docker --now",
      "sleep 30",
      "docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged rancher/rancher:latest"
    ]
  })
}
```

Notice that the authorized ssh keys are empty. These keys can be generated in Terraform or passed in as a variable. I have chosen not to worry about it for this example. This last section finishes the parts of our cloud-init. Now we need to create our libvirt cloud-init disk.

```HCL
resource "libvirt_cloudinit_disk" "init" {
  name           = "init.iso"
  user_data      = local.user_data
  network_config = local.network_config
}
```

That is the last piece needed before creating the VM. 

## Defining the VM

I am excited, and we finally made it to what I wanted to do, create a VM. In libvirt, a VM is called a domain, which you will see in the resource. I am not up to speed on the terminology used, and it may have more meaning than I am aware. Let's get creating the VM. 

I have found that Rancher runs better with 4GB of RAM and at least two CPUs, so that we will assign that. We need to pass in our cloud-init disk so we can leverage all of that configuration. The network interface is the network that you have set up in KVM. My example is using the bridged setup that I have configured with openSUSE, and I am waiting for a DHCP lease plus setting the hostname. 

You will notice that we have two consoles defined. I know that the serial console requirement is due to a bug. We can then set the disk that we created earlier and finally configure the graphics that we want to use.

```HCL
resource "libvirt_domain" "rancher" {
  name   = "rancher"
  memory = "4096"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.init.id

  network_interface {
    bridge = "br0"
    hostname = "rancher"
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.rancher.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
```

Let's export out the IP address that gets assigned.

```HCL
output "rancher_ip" {
  value = libvirt_domain.rancher.network_interface.0.addresses.0
}
```

We are now ready to validate and execute our template.

## Running the Terraform

Thanks for following along, and we are almost ready. The first thing we run is validation to make sure that our template is good.

```Bash
$ terraform validate 

Success! The configuration is valid.
```

At least we don't have any apparent mistakes. Let's plan.

```Bash
$ terraform plan

...
Plan: 4 to add, 0 to change, 0 to destroy.
```

That is looking correct, two volumes, one cloud-init disk, and one VM for a total of four. Let's apply.

```Bash
$ terraform apply -auto-approve

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

rancher_ip = "XXX.XXX.XXX.XXX"
```

Give it about a minute to finish executing the cloud-init, and you should be able to navigate to the Rancher setup page at `HTTPS://<ip or hostname>/`. 

## Wrapping up

I hope you found this helpful. You can leverage the same technique against a local KVM setup or one running on a server. That is what makes this valuable and flexible.

Thanks for reading,

Jamie
