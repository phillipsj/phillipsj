---
title: "Proxmox Linux Templates"
date: 2022-01-20T23:30:42-05:00
tags:
- Open Source
- Virtual Machines
- Proxmox
- Homelab
- Linux
- openSUSE
- openSUSE Tumbleweed
- openSUSE Leap
- openSUSE MicroOS
- MicroOS
- Cloud-init
- Ignition
---

Adding in virtualization to your workflows requires that you streamline steps as much as possible. Containers solved that for many types of work and there are still plenty of things that require dedicated VMs. As part of streamlining, creating templates for your VMs can make setup and any required bootstrapping easier than doing it from an ISO installation. Many Linux distros create cloud images that are small and provide a way to bootstrap that cloud image into a running VM efficiently. I have created a set of templates for several [openSUSE](https://www.opensuse.org) flavors from Leap JeOS to MicroOS. The openSUSE JeOS images leverage the [JeOS firstboot](https://github.com/openSUSE/jeos-firstboot) while the openSUSE [MicroOS](https://microos.opensuse.org) flavors use [ignition](https://en.opensuse.org/Portal:MicroOS/Ignition). An item to note is that the OpenStack versions of the openSUSE images support [cloud-init](https://cloud-init.io) which I have included just the Leap version to support if needed. Lastly, I also added an Ubuntu template that uses cloud-init. Here is the script that you can run on your Proxmox server to create these templates too.

## openSUSE Templates

```Bash
# Creating Tumbleweed Template
wget https://download.opensuse.org/tumbleweed/appliances/openSUSE-Tumbleweed-JeOS.x86_64-kvm-and-xen.qcow2
qm create 9000 --name tumbleweed --cores 2 --memory 4096 --net0 virtio,bridge=vmbr0 
qm importdisk 9000 openSUSE-Tumbleweed-JeOS.x86_64-kvm-and-xen.qcow2 local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --boot c --bootdisk virtio0
qm set 9000 --agent 1
qm set 9000 --vga qxl
qm set 9000 --machine q35
qm resize 9000 scsi0 +10000M
qm template 9000

# Creating Leap Template
wget https://download.opensuse.org/distribution/leap/15.3/appliances/openSUSE-Leap-15.3-JeOS.x86_64-kvm-and-xen.qcow2
qm create 9001 --name leap --cores 2 --memory 4096 --net0 virtio,bridge=vmbr0
qm importdisk 9001 openSUSE-Leap-15.3-JeOS.x86_64-kvm-and-xen.qcow2 local-lvm
qm set 9001 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9001-disk-0
qm set 9001 --boot c --bootdisk virtio0
qm set 9001 --agent 1
qm set 9001 --vga qxl
qm set 9001 --machine q35
qm resize 9001 scsi0 +10000M
qm template 9001

# Creating MicroOS Template
wget https://download.opensuse.org/tumbleweed/appliances/openSUSE-MicroOS.x86_64-kvm-and-xen.qcow2
qm create 9002 --name microos --cores 2 --memory 4096 --net0 virtio,bridge=vmbr0
qm importdisk 9002 openSUSE-MicroOS.x86_64-kvm-and-xen.qcow2 local-lvm
qm set 9002 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9002-disk-0
qm set 9002 --boot c --bootdisk virtio0
qm set 9002 --agent 1
qm set 9002 --vga qxl
qm set 9002 --machine q35
qm resize 9002 scsi0 +10000M
qm template 9002

# Creating MicroOS Leap Template
wget https://download.opensuse.org/repositories/openSUSE:/Leap:/Micro:/5.1/images/openSUSE-Leap-Micro.x86_64-Default.raw.xz
qm create 9003 --name microleap --cores 2 --memory 4096 --net0 virtio,bridge=vmbr0
unxz openSUSE-Leap-Micro.x86_64-Default.raw.xz
qm importdisk 9003 openSUSE-Leap-Micro.x86_64-Default.raw local-lvm
qm set 9003 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9003-disk-0
qm set 9003 --boot c --bootdisk virtio0
qm set 9003 --agent 1
qm set 9003 --vga qxl
qm set 9003 --machine q35
qm resize 9003 scsi0 +10000M
qm template 9003

# Creating Leap Cloud Init Template
wget https://download.opensuse.org/distribution/leap/15.3/appliances/openSUSE-Leap-15.3-JeOS.x86_64-OpenStack-Cloud.qcow2
qm create 9004 --name leapOpenStack --cores 2 --memory 4096 --net0 virtio,bridge=vmbr0
qm importdisk 9004 openSUSE-Leap-15.3-JeOS.x86_64-OpenStack-Cloud.qcow2 local-lvm
qm set 9004 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9004-disk-0
qm set 9004 --boot c --bootdisk virtio0
qm set 9004 --agent 1
qm set 9004 --vga qxl
qm set 9004 --machine q35
qm set 9004 --serial0 socket # for cloud init
qm resize 9004 scsi0 +10000M
qm template 9004
```

## Ubuntu Template

```Bash
# Creating Ubuntu Template
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
qm create 9020 --name ubuntu2004 --cores 2 --memory 8192 --net0 virtio,bridge=vmbr0
qm importdisk 9020 focal-server-cloudimg-amd64.img local-lvm
qm set 9020 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9020-disk-0
qm set 9020 --boot c --bootdisk virtio0
qm set 9020 --agent 1
qm set 9020 --vga qxl
qm set 9020 --machine q35
qm set 9020 --serial0 socket # for cloud init
qm resize 9020 scsi0 +10000M
qm template 9020
```

## Cloud-init Configuration

Proxmox supports cloud-init out of the box. The cloud-init templates have the required serial port hooked up, you just need to go to the hardware section on the template and add the `CloudInit Drive`. Once it is added, then go to the `Cloud-Init` section in the main template tab and fill out all the information like your SSH keys, password, and of course your network. Then, you can clone that template which will also clone your base cloud-init information so your machine will boot configured with your SSH keys, etc.

## Ignition Configuration

Ignition is a little more involved and this [quick start guide](https://en.opensuse.org/Portal:MicroOS/Ignition#Ignition_Quick_Start) has most of what you need to know. I am going to cover the steps here too. The first step is to create your directory structure and ignition file.

```Bash
$ mkdir -p igndisk/ignition
$ touch igndisk/ignition/config.ign
``` 

Then has the password you want to set with openssl.

```Bash
$ openssl passwd
```

Then paste the hashed password and your public key into the following JSON and place that into the `config.ign`.

```JSON
{
  "ignition": { "version": "3.1.0" },
  "passwd": {
    "users": [
      {
        "name": "root",
        "passwordHash": "<openssl password here>",
        "sshAuthorizedKeys":
         [
           "<ssh pub key here>"
         ]
      }
    ]
  }
}
```

Next, you can generate your ISO using `mkisofs`. The important part of this step is to make sure that your volume label is `ignition`.

```Bash
$ mkisofs -o ignition.iso -V ignition igndisk
```

Finally, take that generated ISO and upload that to your local storage in Proxmox. Add it as a CDROM drive to your MicroOS templates. Now when you clone those templates to create a VM that ignition file will be attached so you can have the machine configured with your SSH key.

## Wrapping Up

Not much to say on this one. These are the templates that I am currently using to create VMs to test some items then quickly destroy them. This is not how you would want to do this for more long-term solutions or for production systems. Hopefully, there is some useful information in here for others that want to get started leveraging Proxmox in their workflow.

Thanks for reading,

Jamie
