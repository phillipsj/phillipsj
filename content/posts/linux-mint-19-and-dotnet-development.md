---
Title: "Linux Mint 19 and .NET Development"
date: 2018-09-14T19:55:22
Tags: 
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
---
# Linux Mint 19 and .NET Development

Setting up a new Linux environment and I decided to go with [Linux Mint 19 Xfce Edition](https://blog.linuxmint.com/?p=3599). I haven't used Linux Mint in about 4 years, but I wanted to give it a try. Ubuntu 18.04 used well over 1GB of RAM just sitting idle, with Mint, I am around 500MB. So far I am really liking it, but I had a little trouble getting Docker, .NET Core, PowerShell, and GitKraken to either install or run correctly. Here are the steps I had to take.

## Docker

Since Mint 19 is based on Ubuntu 18.04 all you have to do to install any software that isn't typically found in the repos are to just add the Ubuntu 18.04 repo. Most applications have the instructions, however it doesn't always work as planed. I started off following these [Docker instructions](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository). All the steps went smoothly until I got here:

```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
When I ran this command I kept getting a ca-certificate error. Funny enough I was getting this same error earlier when trying to install .NET Core. After a little digging, I found some info that said to install ca-certificates using apt.

So I ran:

```
sudo apt install ca-certificates
Reading package lists... Done
Building dependency tree       
Reading state information... Done
ca-certificates is already the newest version (20180409).
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
```

Hmm, it seemed by certificates are just fine. However, I kept seeing posts telling me to that they may be corrupted and to reinstall. So I ran the following command to reinstall.

```
sudo apt install --reinstall ca-certificates
```

After that completed, I tried running the *curl* command again and it succedded. After that the only other gotcha is when adding the repo, do not use the **lsb_release -cs** command as it will put *tara* which isn't valid, *bionic* will need to be put in there before running the command.

```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
```

With these changes, everything works as normal.

## .NET Core

Following the instructions for Ubuntu 18.04 located [here](https://www.microsoft.com/net/download/linux-package-manager/ubuntu18-04/sdk-2.1.300), it just doesn't work. I haven't figured that out yet, however here are the instructions that do work. Make sure that *ca-certificates* don't need reinstalled, see above. If any certificate errors go back to the step above and reisntall that package.

With that out of the way, what we can do is just use the [Debian 9 instructions](https://www.microsoft.com/net/download/linux-package-manager/debian9/sdk-2.1.300) with a few modifications as show below.

```
$ wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg
$ sudo mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
$ wget -q https://packages.microsoft.com/config/ubuntu/18.04/prod.list
$ sudo mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
$ sudo chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
$ sudo chown root:root /etc/apt/sources.list.d/microsoft-prod.list
```

Notice that on line three the correct Ubuntu 18.04 information is inserted instead of the Debian 9 info. After that small change, .NET Core can be installed.

```
$ sudo apt-get update
$ sudo apt-get install dotnet-sdk-2.1
```

That is it, .NET Core should be installed and working.

## PowerShell

After setting up the .NET Core repo, PowerShell is just a simple install.

```
$ sudo apt install powershell
```

## GitKraken

I like using GitKraken, no need to use the commandline until I need to do something more complex, but that isn't necessary with GitKraken. After downloading the GitKraken .deb file, the GUI would just not launch. After a little google fu it seems that a few missing depedencies that are required don't get installed using the .deb on Linux Mint 19. To fix that the following depedencies need installed.

```
$ sudo apt install libgnome-keyring0 libcurl4-openssl-dev
```

Hopefully someone else finds this useful too, thanks for reading.
