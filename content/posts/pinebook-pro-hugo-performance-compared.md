---
title: "Pinebook Pro Hugo Performance Compared"
date: 2021-01-19T19:50:27-05:00
tags:
- Pine64
- Pinebook Pro
- Linux
- Open Source
---

I decided to finally do a tiny little benchmark comparing my Pinebook Pro to the other three devices that I use regularly. The benchmark will be building my blog using Hugo v0.80.0 to see how they perform relative to each other. I use the following commit [a62eabffaac779b7b288144d9bfd02b8bb143e8a](https://gitlab.com/phillipsj/phillipsj/-/tree/a62eabffaac779b7b288144d9bfd02b8bb143e8a) from my GitLab repo. Hugo builds 755 pages along with a couple of hundred alias and static files. The results are kind of interesting, and the difference was shocking and unexpected at the same time. Before I show the results, let's talk about the machines that we will be comparing.

* Pinebook Pro, RK3399, 4GB RAM, 64GB eMMC
* Thinkpad x260, i5-6200U, 16GB RAM, 256GB SATA SSD
* Asus Zenbook UX305F, M-5Y10c, 8GB RAM, 256GB SATA SSD
* Custom Desktop, Ryzen 5 3600, 32GB RAM, 512GB Gen3 NVMe

Now I'm not running the same distro on all of these machines, which may be a factor. Here are the distros used by each device, and all distros were up to date.

* Pinebook Pro - Manjaro KDE
* Thinkpad x260 - openSUSE Leap 15.2
* Asus Zenbook - openSUSE Tumbleweed
* Custom Desktop - openSUSE Tumbleweed

With that information out of the way, here is the list of results from fastest to slowest.

Name           | CPU            | Cores/Threads | Total Time |
---------------|----------------|---------------|------------|
Custom Desktop | Ryzen 5 3600   | 6/12          | 727ms      |
Thinkpad x260  | Intel i5-6200U | 2/4           | 2426ms     |
Asus Zenbook   | Intel M-5Y10c  | 2/4           | 3054ms     |
Pinebook Pro   | RK3399         | 6/0           | 4892ms     |


I don't think anyone would be this surprised by the results. I was more shocked by just the difference between all of them. I am curious if the Pinebook Pro performance would be better with SSD storage instead of the eMMC. I will be testing that out in the future and adding the Raspberry PI 400 when it arrives. The Thinkpad's 6th Gen Core i5 from 2015 was twice as fast as the Pinebook Pro. The M-5Y10c is from 2014, and it is 38% faster than the Pinebook Pro if I calculated that correctly. I am curious to try this on something like the M1 Mac just for a straightforward comparison. Now, in everyday use, do I notice the speed difference? Not all that much. 

I hope you found this useful and thanks for reading,

Jamie
