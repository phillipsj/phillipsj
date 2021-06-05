---
title: "Developing Kubernetes for Windows Requires VMs"
date: 2021-06-04T21:35:14-04:00
tags:
- Open Source
- Kubernetes
- Rancher
- RKE2
- Windows
- Containers
- Microsoft
- Windows Containers
- Virtual Machines
- Vagrant
- Proxmox
---

It's been exactly two months since I started working on a Kubernetes distribution as a member of the Windows team. It has presented some new challenges, with the most challenging coming down to testing. If you are working on Linux, you can nest k8s inside of k8s, use tools like [kind](https://kind.sigs.k8s.io/). When working on Windows, you will need a Linux control plane, and then you can configure a Windows node. Now you could leverage a container or WSL to host the control plane, then use your local machine as the Windows node. That approach risks your local machine getting misconfigured or corrupted. Having to reinstall Docker/Hyper-v when something goes wrong takes a lot of time. This work creates some interesting solutions that we are going to discuss.

### Solution 1: The Cloud

The cloud is one possible solution and a good one. It provides a lot of flexibility, ready-to-go images, and tons of options. The one frustration that I had was that it was slow. After some time doing development that needs that tighter feedback, I used not to think that the provisioning time of VMs in a cloud takes times which the load can impact the region. On top of that, often multiple teams are working on solutions that start putting a strain on the resource limits, which can affect all kinds of work. Those two reasons alone had me looking for different solutions unless I explicitly tested something that needs a cloud provider.

### Solution 2: Basic Hypervisor

Spinning up a single VM on a local hypervisor like Hyper-V is another solution. It's quick, local, and fast, which is necessary for the feedback loop. Once you start getting into multiple VMs, snapshots, and other miscellaneous, you can start putting a lot of stress on your local machine. Tearing them down and standing them back up can be slow and time-consuming. If I need to test something unique, this approach works; for needing to make tweaks repeatably, it doesn't.

### Solution 3: Vagrant

[Vagrant](https://www.vagrantup.com/) is just a modification on solution two. It adds in the scriptability and automation that makes it trivial to provide an entire cluster from scratch, test, and then destroy it until it is required again. It only consumes resources when you need it, it's highly repeatable, and you can manipulate the machines individually or as a group. It has become my go-to setup for doing Windows node work. I can share it with others to help them out, ensuring that network settings and shared drives are consistent. I know that I need to make some additional boxes with specific items preinstalled to speed it up even more.

### Solution 4: Proxmox

The final solution is the newest solution I have been experimenting with [Proxmox VE](https://www.proxmox.com/en/proxmox-ve). I took an Intel NUC that I had extra and installed it. I have loaded up a few ISOs to it and created some VM templates. I then use it to generate control planes for different versions and to run Rancher. This approach keeps all of that on my network and off my local machine. Proxmox provides some stability with the control plane, saves time, and reduces local resource usage. Overall, I am pleased with this solution and will invest more heavily in this setup. I need to focus on template setup and storage to cover snapshots, backups, and ISOs. There is an existing Terraform provider that I need to check out.

## Wrapping up

I hope you found this insightful. I thought I would share my experiences working on an infrastructure-level system that requires heavier usage of virtual machines than what I am typically used to doing. Containers happened, and VM usage, at least for me, just stopped.

Thanks for reading,

Jamie
