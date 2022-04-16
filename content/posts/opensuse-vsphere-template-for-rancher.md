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

Open of vCenter for your cluster. Navigate to the data store 

### Creating the content library

### Uploading the ISO


