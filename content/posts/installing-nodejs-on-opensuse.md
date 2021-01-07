---
title: "Installing Node.js on openSUSE"
date: 2021-01-06T19:05:41-05:00
tags:
- Open Source
- Linux
- openSUSE
- openSUSE Leap
- openSUSE Tumbleweed
- Node
---

I have been slowly working through the setup on openSUSE, and now I need Node.js installed. A quick search using *zypper* for *node* produced a lot of results. All the LTS, Long Term Support, versions are available in the repositories by default, which is refreshing, including Leap. That isn't always the case with Debian based systems, so I was surprised. I decided that I would install Node.js v14 as that is the latest LTS. I ran the following command.

```Bash
$ sudo zypper install nodejs14
Loading repository data...
Reading installed packages...
Resolving package dependencies...

The following 5 NEW packages are going to be installed:
  nodejs14 nodejs14-devel nodejs-common npm14 python

The following 3 recommended packages were automatically selected:
  nodejs14-devel npm14 python

5 new packages to install.
Overall download size: 11.4 MiB. Already cached: 0 B. After the operation, additional 49.5 MiB will be used.
Continue? [y/n/v/...? shows all options] (y): y
Retrieving package nodejs-common-2.0-lp152.3.2.noarch                                (1/5),   8.1 KiB (  230   B unpacked)
Retrieving: nodejs-common-2.0-lp152.3.2.noarch.rpm .................................................................[done]
Retrieving package python-2.7.17-lp152.3.9.1.x86_64                                  (2/5), 332.6 KiB (  1.4 MiB unpacked)
Retrieving: python-2.7.17-lp152.3.9.1.x86_64.rpm ...................................................................[done]
Retrieving package nodejs14-14.15.0-lp152.2.1.x86_64                                 (3/5),   7.3 MiB ( 27.8 MiB unpacked)
Retrieving: nodejs14-14.15.0-lp152.2.1.x86_64.rpm ......................................................[done (3.7 MiB/s)]
Retrieving package nodejs14-devel-14.15.0-lp152.2.1.x86_64                           (4/5), 182.4 KiB (924.7 KiB unpacked)
Retrieving: nodejs14-devel-14.15.0-lp152.2.1.x86_64.rpm ...............................................[done (15.0 KiB/s)]
Retrieving package npm14-14.15.0-lp152.2.1.x86_64                                    (5/5),   3.6 MiB ( 19.4 MiB unpacked)
Retrieving: npm14-14.15.0-lp152.2.1.x86_64.rpm .........................................................[done (1.9 MiB/s)]

Checking for file conflicts: .......................................................................................[done]
(1/5) Installing: nodejs-common-2.0-lp152.3.2.noarch ...............................................................[done]
(2/5) Installing: python-2.7.17-lp152.3.9.1.x86_64 .................................................................[done]
(3/5) Installing: nodejs14-14.15.0-lp152.2.1.x86_64 ................................................................[done]
Additional rpm output:
update-alternatives: using /usr/bin/node14 to provide /usr/bin/node-default (node-default) in auto mode


(4/5) Installing: nodejs14-devel-14.15.0-lp152.2.1.x86_64 ..........................................................[done]
(5/5) Installing: npm14-14.15.0-lp152.2.1.x86_64 ...................................................................[done]
Additional rpm output:
update-alternatives: using /usr/bin/npm14 to provide /usr/bin/npm-default (npm-default) in auto mode
update-alternatives: using /usr/bin/npx14 to provide /usr/bin/npx-default (npx-default) in auto mode
```

A couple of exciting things immediately jump out for me. The first is that it installs **npm** by default. The second exciting thing is that Python gets installed too, which allows you to build packages if required. The third item is the installation of **npx**, a tool for executing packages in your local *node_modules* folder. By including these, openSUSE saves you some eventual hassle and time. I am slowly learning that these are the nice touches openSUSE brings to the table. Let's check out exactly which versions we received for the Node.js tools.

```Bash
$ npm -v
6.14.8
$ npx -v
6.14.8
$ node -v
v14.15.0
```

It looks like these are very recent versions for each. That is great to see, and I will be curious to see how updates occur over time. I hope this was able to help someone get up and running with Node.js on openSUSE.

Thanks for reading,

Jamie
