---
title: "Initial Silverblue Device and Blogging Setup"
date: 2023-04-03T20:59:17-04:00
tags:
- Open Source
- Linux
- Fedora
- Fedora Silverblue
- Immutable OS
- Fedora Silverblue Challenge
---

It's April and I've started my [Silverblue](https://silverblue.fedoraproject.org/) journey. I picked a laptop to start as that allows me to chill on the couch and think about how I want to handle the setup. I will be using [Ansible](https://www.ansible.com/) to do my installation of [Flatpaks](https://flatpak.org/) and my [Toolbox](https://docs.fedoraproject.org/en-US/fedora-silverblue/toolbox/) setups. 

The laptop that I'm using is an Asus Vivobook with a 12th Gen Intel i3-1220p and 12GB of RAM. Silverblue was installed flawlessly and has been working as expected. I haven't noticed any strange behavior or negatives with the newer hardware. After getting Silverblue installed, I wanted to write this post and I had to set up my first toolbox. I'm going to use the default toolbox for my blogging activities. Let me take you through the setup.

The first step is to create a toolbox.

```Bash
toolbox create
```

Then we can enter the new toolbox. Once you enter a toolbox your prompt should change to `username@toolbox $`. That is a nice feature.

```Bash
toolbox enter
```

The toolbox is just an OCI container that has full access to your home directory. It feels seamless for the most part minus a few hiccups that I will cover in a future post. Now that we are in the toolbox, we can use *dnf* to install [Hugo](https://gohugo.io/).

```Bash
sudo dnf install hugo -y
```

Once that's finished you can run `hugo version` to see the version installed.

```Bash
$ hugo version
hugo v0.98.0+extended linux/amd64 BuildDate=unknown
```

I want to further illustrate that it's an isolated container, so let's exit the toolbox and type `hugo version` again. Notice that your prompt changed.

```Bash
$ exit
$ hugo version
bash: hugo: command not found
```

However, we can run hugo from Silverblue using the container with the `toolbox run` command.

```Bash
$ toolbox run hugo version
hugo v0.98.0+extended linux/amd64 BuildDate=unknown
```

## Wrapping Up

This was a quick post on getting started with a few of the new tools and experiences that I've had to learn to move into this immutable OS world. It's an interesting approach that I'm excited to learn how to push it to its limits. I'm also making a good attempt at using Ansible to finally get the initial bootstrap of my machines so I can get up and running faster. Please keep stopping by as I dig further.

Thanks for reading,

Jamie