---
title: "Using SSH with Windows and Packer"
date: 2026-02-02T21:07:41-05:00
draft: true
tags:
- Open Source
- Packer
- HashiCorp
- Windows
- Microsoft
- SSH
- VMWare
- vSphere
---

I looked through all of my past posts and I just can't believe that I have written about this topic yet. I have an unusual set of skills that I have been fortunate to learn and flex over the years. One of those skills is building Windows images with Packer. I learned how to do this back in 2018 and I have slowly refined my approach. That approach often involves not doing it the way a normal Windows person would do it. I like to use [OpenSSH](https://www.openssh.org) instead of using [WinRM](https://learn.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management) and I prefer to use [Ansible](https://docs.ansible.com/projects/ansible/latest/index.html) over [PowerShell](https://learn.microsoft.com/en-us/powershell/). Now, PowerShell isn't 100% avoidable as there will be certain circumstances where it has to be leveraged. That's okay with me as I'm not cobbling together multiple scripts and I'm leveraging a skill that can more easily be translated to Linux.

Okay, with that out of the way, I bet you want to know how to get this setup. I'm going to assume you know how to use Packer already. If not, I would suggest heading over to the [docs](https://developer.hashicorp.com/packer/docs) to get started. I'm going to show you how to leverage it with both [AWS EC2](https://aws.amazon.com/ec2/) and [vSphere](https://www.vmware.com/products/cloud-infrastructure/vsphere). I'm sure other clouds and virtualization platforms will require some combination of the two approaches.

## AWS EC2

## VMware vSphere

