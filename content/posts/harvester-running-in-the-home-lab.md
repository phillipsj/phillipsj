---
title: "Harvester Running in the Home Lab"
date: 2021-06-01T22:50:26-04:00
tags:
- Open Source
- Cloud
- Rancher
- Home Lab
---

I have made several attempts at configuring a home lab over the years. I use it for a while, and then it sits there. Since I have started my new job, I have found an increasing need for it. The cloud is super convenient, yet nothing is faster than having servers locally. I have been using [Vagrant](https://www.vagrantup.com/) with success, and I did have a [KVM](https://www.linux-kvm.org/page/Main_Page) setup working. I have decided that I needed something a tad more than what KVM could provide. Given all of that, I decided that I would give [Harvester](https://harvesterhci.io/) a spin, given it's Kubernetes based.

I decided to leverage both my Intel NUC and my Asrock Beebox to build out a cluster. I downloaded the ISO from the GitHub page and followed the installation instructions [here](https://docs.harvesterhci.io/v0.2/install/iso-install/). My two small boxes are both quad-core Intel CPUs with 8GB of RAM each. So far, performance has been satisfactory, and I am sure as I learn how to use it more effectively, I will need to get some more hardware behind it. Here is a dashboard view of my hosts that I have.

![](/images/other-posts/harvester-hosts.png)

As I explore more features and start putting this cluster to use, I will blog about any interesting things that I learn.

Thanks for reading,

Jamie
