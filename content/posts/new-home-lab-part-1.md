---
title: "New Home Lab Part 1"
date: 2025-01-13T19:29:48-05:00
tags:
- Home Lab
- MicroK8s
- MetalLB
- Ubuntu
- Linux
- Kubernetes
---

It’s time to get the home lab back up and running since I need an environment that I can use to do some learning. I’m focusing on getting a Kubernetes cluster up with all the tools that interest me. I want to be able to start simple and slowly build in more complexity. I also want maintenance to be straightforward. That said, I will use an Intel NUC with plenty of RAM and storage. I will be running Ubuntu 24.04 with automatic updates, and finally, I will be using [MicroK8s](https://microk8s.io) for my Kubernetes distribution. This will take a little time to set up and configure like I want.  

Here is the current plan: 
 
1. Check the hardware and make any tweaks 
2. Install Ubuntu 
3. Configure the home network for MetalLB
4. Install MicroK8s 
     1. Enable CoreDNS 
     2. Cert-manager 
     3. ArgoCD 
     4. MetalLB 
     5. Host path storage 
 
I’m going to leverage the MicroK8s config file, and I will be posting it to GitHub in case you want to have a similar setup. As stated above, the real focus of this isn’t to have a setup to run as “production” at home. It’s to have a setup that I can use to learn tools and create experiments. It may eventually become a template for a production-quality home K8s cluster. There are a few things that need to be done in preparation. We will start with my hardware and their tweaks.
 
## Hardware 

This is the hardware and configuration that I will be using.

### Server

I will be using my 8th gen Intel NUC, here are the specs:
 
```Bash
            .-/+oossssoo+/-.               phillipsj@mylab.home.arpa
        `:+ssssssssssssssssss+:`           -----------------------
      -+ssssssssssssssssssyyssss+-         OS: Ubuntu 24.04.1 LTS x86_64
    .ossssssssssssssssssdMMMNysssso.       Host: NUC8i5BEK J72742-305
   /ssssssssssshdmmNNmmyNMMMMhssssss/      Kernel: 6.8.0-51-generic
  +ssssssssshmydMMMMMMMNddddyssssssss+     Uptime: 35 mins
 /sssssssshNMMMyhhyyyyhmNMMMNhssssssss/    Packages: 780 (dpkg), 4 (snap)
.ssssssssdMMMNhsssssssssshNMMMdssssssss.   Shell: bash 5.2.21
+sssshhhyNMMNyssssssssssssyNMMMysssssss+   Terminal: /dev/pts/0
ossyNMMMNyMMhsssssssssssssshmmmhssssssso   CPU: Intel i5-8259U (8) @ 3.800GHz
ossyNMMMNyMMhsssssssssssssshmmmhssssssso   GPU: Intel CoffeeLake-U GT3e [Iris Plus Graphics 655]
+sssshhhyNMMNyssssssssssssyNMMMysssssss+   Memory: 350MiB / 31964MiB
.ssssssssdMMMNhsssssssssshNMMMdssssssss.
 /sssssssshNMMMyhhyyyyhdNMMMNhssssssss/
  +sssssssssdmydMMMMMMMMddddyssssssss+
   /ssssssssssshdmNNNNmyNMMMMhssssss/
    .ossssssssssssssssssdMMMNysssso.
      -+sssssssssssssssssyyyssss+-
        `:+ssssssssssssssssss+:`
            .-/+oossssoo+/-.
``` 
 
I had the NVMe 1TB drive that I put in it, and it’s just an SN550 and should work great for this purpose. If this was a more production-like system, I would be leveraging NFS and using my NAS. Honestly, I would probably focus on building out an ARM solution or at least having the majority of the nodes be ARM. I’ve installed Ubuntu 24.04 as the operating system, configured [Ubuntu Pro](https://ubuntu.com/pro), and set up [livepatch](https://ubuntu.com/security/livepatch). This makes the operating system easy to maintain. The last configuration item planned is automated backups to my NAS.

### Router

[MetalLB](https://metallb.io) serves the purpose of having a way to create K8s load balancers. If you don’t want or need level 2 networking, you could probably get by using an Ingress controller like [nginx](https://github.com/kubernetes/ingress-nginx). I however want that capability. To leverage MetalLB, you will need to have a router that has the capabilities that allow you to define subnets or allocate CIDR ranges to specific services. If you want to be able to resolve names for your services, then you will also need DNS. I have an older [Synology RT2600](https://www.synology.com/en-global/products/RT2600ac) that has been pretty decent and is more toward the prosumer category. The tweaks required here were to configure the [DNS Package](https://www.synology.com/en-us/dsm/packages/DNSServer) on the router. I trimmed my DHCP range by 25 IPs, so I could allocate those IPs to MetalLB. I did run into one frustrating item that has me considering purchasing some new home networking gear. That point of frustration is that the DHCP inside the Synology router isn't capable of updating DNS with records associated with the leases. This means that for anything I want to have a fixed IP address, I will need to reserve the lease, and then add the DNS record manually. I have found a GitHub repo [here](https://github.com/gclayburg/synology-diskstation-scripts) that has a workaround. I may implement, or I may not, there are some additional features that I would like which may push me to replace it with something more heavy duty.

## Wrapping Up

These are just the first steps to preparing for the installation of MicroK8s to get this home lab up and running. Part 2 will cover the automation of the MicroK8s deployment.

Thanks for reading,

Jamie
