---
title: "openSUSE MicroOS, Ignition, and Proxmox"
date: 2022-01-15T21:40:27-05:00
tags:
- Open Source
- Linux
- openSUSE
- openSUSE Tumbleweed
- openSUSE Leap
- openSUSE MicroOS
- MicroOS
- Proxmox
- Ignition
---

I have been spending time to automate more of my workflows and I have turned my focus back to leveraging many of the [openSUSE](https://www.opensuse.org) images along with [Proxmox](https://www.proxmox.com/en/proxmox-ve). After a little experimentation between the [JeOS](https://en.opensuse.org/Portal:JeOS) and [MicroOS](https://microos.opensuse.org) images, I have settled on the MicroOS images. They ship with the option to leverage [Combustion](https://en.opensuse.org/Portal:MicroOS/Combustion) or [Ignition](https://en.opensuse.org/Portal:MicroOS/Ignition) to bootstrap the images. After trying different techniques for a couple of days I just couldn't get [cloud-init](https://cloud-init.io) to function with Proxmox and the [OpenStack](https://www.openstack.org) images produced by openSUSE. It would function just fine with other distros, or on other hyper-visors. Another advantage of working with MicroOS are the many advantages that it provides along with being immutable. I also started checking out the beta version of Leap MicroOS which is cool to see. 

To get started working with these in Proxmox, we need to create some templates to leverage that we can clone to create more VMs. After that, we need to create our ignition file and generate the correctly formated ISO to mount as a CDROM to our VM to do the configuration. I have all of these steps outlined below, let's get going.

## Creating Proxmox Templates

We will be creating Proxmox templates for Tumbleweed and Leap MicroOS with some basic configuration. If you want different defaults, then change the RAM and cores settings along with the disk resizing. You can change these later when you clone the template so no need to worry. The script below will download the images, create the Proxmox VMs, then generate a template. This script will need to be executed on your Proxmox server which should have ` xz-utils`, if not then those will need to be installed for the MicrOS Leap template.

```Bash
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
```

Once this is finished if you open your Proxmox Web UI, you will see the two templates. Now we can move on to creating our ignition file and ISO.

## Creating the ignition ISO

There are good instructions [here](https://en.opensuse.org/Portal:MicroOS/Ignition#Create_an_ISO-Image) for most of the steps that are required they just aren't all in the same place. The first step is to create our directory structure that is required.

```Bash
mkdir -p microos/ignition
touch microos/ignition/config.ign
```

Now open the `config.ign` in your favorite text editor and past the following.

```JSON
{
  "ignition": { "version": "3.1.0" },
  "passwd": {
    "users": [
      {
        "name": "root",
        "passwordHash": "<paste your hashed password here, generate with 'openssl passwd'>",
        "sshAuthorizedKeys":
         [
           "<paste your public key here>"
         ]
      }
    ]
  }
}
```

This is very basic, but will set your default account password and any SSH keys you want to have in your VMs. The password needs to be hashed with the `openssl passwd` command before being placed in the file. Once you have the ignition file as desired, we can then generate your ISO.

```Bash
mkisofs -o ignition.iso -V ignition microos
```

Now the `ignition.iso` file needs to be uploaded to your ISOs directory in Proxmox. If you kept it basic as I did above, then I would suggest you go ahead and add a CDROM to your template machines with this ISO being the once mounted. 

## Cloning the template

At this point, you can clone either one of the templates generated above, making sure that you have the `ignition.iso` mounted on the machine. Then when you start it, it should come up with the password and the SSH key configured. 

## Wrapping Up

I hope this helps anyone trying to do the same thing. A lot of this documentation exists and there is much more that can be accomplished with it. I look forward to seeing how far I can push these.

Thanks for reading,

Jamie

