---
title: "openSUSE vSphere Template for Rancher"
date: 2022-04-16T13:39:53-04:00
tags:
- Open Source
- Linux
- openSUSE
- openSUSE Tumbleweed
- VMware
- vSphere
- Rancher
- RKE1
- RKE2
- Kubernetes
- K8s
- Packer
- cloud-init
- cloudbase-init
---

[Rancher](https://rancher.com/) has a feature called [node drivers](https://rancher.com/docs/rancher/v2.6/en/admin-settings/drivers/node-drivers/) that allow for the automatic creation of clusters against different environments. One of those exists for VMware vSphere for both RKE1 and RKE2. This driver leverages [cloud-init](https://cloud-init.io/) for Linux and [cloudebase-init](https://cloudbase.it/cloudbase-init/) for Windows to create a VM from vSphere templates. This assumes that you have a vSphere template already created with all the necessary packages installed and configured. Often users need to create these templates to ensure the correct setup exists. 

[openSUSE Leap](https://get.opensuse.org/leap) doesn't leverage cloud-init by default, except in the [JeOS](https://en.opensuse.org/Portal:JeOS) images for OpenStack. We will need to ensure that cloud-init is installed and configured correctly for use with vSphere and our node driver. I am going to guide you through how to leverage [Packer](https://www.packer.io/) and the vSphere builder to automate the creation of a template based on openSUSE Leap. We will install Packer, create our Packer configuration, then work through the provisioning steps, and finally convert our VM to an OVA template that will be placed into a content library.

**This has been tested on several Linux distributions and on the same distributions with WSL.**

## Preparation

There is some preparation that is going to be required before we can get started. At a high level here is what needs to be done

• Download the openSUSE Leap ISO
• Create our ISO folder in our VMWare data store
• Create our vSphere Content Library
• Upload our Leap ISO to our ISO folder

*Optionally you may want to create a dedicated account for Packer in vSphere. We won't cover that here and will assume you are using an account with the correct permissions.*

### Download the openSUSE ISO

We will be using the openSUSE Leap 15.3 ISO and in this example I will use the offline ISO, feel free to use the network image if you desire. Let's get our ISO and checksum file.

```Bash
wget https://download.opensuse.org/distribution/leap/15.3/iso/openSUSE-Leap-15.3-3-DVD-x86_64-Build38.1-Media.iso.sha256
wget https://download.opensuse.org/distribution/leap/15.3/iso/openSUSE-Leap-15.3-3-DVD-x86_64-Build38.1-Media.iso
```

Let's verify our download with our checksum.

```Bash
$ sha256sum -c openSUSE-Leap-15.3-3-DVD-x86_64-Build38.1-Media.iso.sha256
openSUSE-Leap-15.3-3-DVD-x86_64-Build38.1-Media.iso: OK
```

Keep the checksum file as you will need to put the checksum value in our Packer template.

### Creating the data store folder

Open of vCenter for your cluster. Navigate to the data store that you want to use and add a folder called `iso`. Inside of `iso` create a folder called `linux`. Finally, inside of the `linux` folder create a folder called `openSUSE`. 

*iso-datastore.png*

### Creating the content library

Create a content lbriary to save your templates. [Here](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-2A0F1C13-7336-45CE-B211-610D39A6E1F4.html) are the official docs on how to do that.

*content-library.png*

### Uploading the ISO

Navigate to the openSUSE folder that we created in previous step and click on `Upload Files`. Select the openSUSE ISO that we downloaded and upload it to that location.

## Packer installation and setup

We just have a few more steps left before we can start creating our Packer template. First we need to install Packer. You can download it from [here](https://www.packer.io/downloads) or you can use a package manager.

Windows:

```PowerShell
choco install packer
```

openSUSE:

```Bash
$ wget https://releases.hashicorp.com/packer/1.8.0/packer_1.8.0_linux_amd64.zip
$ unzip packer_1.8.0_linux_amd64.zip && mv packer ~/bin
```

macOS: 

```Bash
brew tap hashicorp/tap
brew install hashicorp/tap/packer
```

Now that we have it Packer installed, we need to make sure that we have a few other tools installed. You will need `xorriso` or `mkisofs` on Linux/macOS. On Windows you will need [`oscdimg`](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/oscdimg-command-line-options). These are all used to create ISOs to mount your unattend configuration. In the case of openSUSE that would be an [AutoYaST](https://doc.opensuse.org/projects/autoyast/) file. That wraps up everything we need before we start creating our Packer configuration.

## Packer Configuration

We are now getting to the section we all want. Let's first create a directory for our project.

```Bash
mkdir packer-opensuse-template && cd "$_"
```

Now I am a big fan of how Terraform started laying out projects when 0.12 was introduced. We will follow a similar pattern. Let's create our `versions.pkr.hcl`.

```HCL
packer {
  required_version = ">= 1.8.0, < 2.0.0"
  required_plugins {
    vsphere = {
      version = ">= 0.0.1"
      source = "github.com/hashicorp/vsphere"
    }
  }
}
```

Now we can run `packer init` to install our plugin and make sure that our `versions.pkr.hcl` is valid.

```Bash
$ packer init .
Installed plugin github.com/hashicorp/vsphere v1.0.3 in "/home/phillipsj/.config/packer/plugins/github.com/hashicorp/vsphere/packer-plugin-vsphere_v1.0.3_x5.0_linux_amd64"
```

Great, let's now start create our `source.pkr.hcl` file that defines our vSphere VM that will be used to build.

```HCL

```

You will notice that we have some variables defined that we need to create. Let's create a `variables.pkr.hcl`.

```HCL
variable "vsphere_endpoint" {
  type        = string
  description = "The fully qualified domain name or IP address of the vCenter Server instance. (e.g. 'sfo-w01-vc01.sfo.rainpole.io')"
}

variable "vsphere_username" {
  type        = string
  description = "The username to login to the vCenter Server instance. (e.g. 'svc-packer-vsphere@rainpole.io')"
  sensitive   = true
}

variable "vsphere_password" {
  type        = string
  description = "The password for the login to the vCenter Server instance."
  sensitive   = true
}

variable "vsphere_insecure_connection" {
  type        = bool
  description = "Do not validate vCenter Server TLS certificate."
  default     = true
}

variable "vsphere_datacenter" {
  type        = string
  description = "The name of the target vSphere datacenter. (e.g. 'sfo-w01-dc01')"
}

variable "vsphere_cluster" {
  type        = string
  description = "The name of the target vSphere cluster. (e.g. 'sfo-w01-cl01')"
}

variable "vsphere_datastore" {
  type        = string
  description = "The name of the target vSphere datastore. (e.g. 'sfo-w01-cl01-vsan01')"
}

variable "vsphere_folder" {
  type        = string
  description = "The name of the target vSphere cluster. (e.g. 'sfo-w01-fd-templates')"
}

variable "build_username" {
  type        = string
  description = "The username to login to the guest operating system. (e.g. 'rainpole')"
  sensitive   = true
}

variable "build_password" {
  type        = string
  description = "The password to login to the guest operating system."
  sensitive   = true
}
```

The last item before we check our work is creating a `locals.pkr.hcl` file.

```HCL
locals {
  build_by      = "Built by: HashiCorp Packer ${packer.version}"
  build_date    = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_version = formatdate("YY.MM", timestamp())
}
```