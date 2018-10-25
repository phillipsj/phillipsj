---
Title: ".NET Core Development on Ubuntu 18.10"
Published: 10/24/2018 20:42:42
Tags: 
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
- Ubuntu
---
# .NET Core Development on Ubuntu 18.10

I really enjoy using Linux and specifically Debian and Ubuntu based distributions. When I started hearing the positive feedback about [Ubuntu 18.10 Cosmic CuttleFish](http://releases.ubuntu.com/18.10/), I had to give it a try. Once I got it installed I will say that it is way more responsive than Ubuntu 18.04 and resource usage seems to be down. Visually, it is a stunning release with the new [Yaru](https://github.com/ubuntu/yaru) theme. The main question I had was, will .NET Core install? This is a pretty fair question considering that most of the documentation on the site is written focus on the LTS releases of Ubuntu and I cannot blame them for that. So here we go, let's see if we can get this to work.

## Install .NET Core

Good thing here is there is nothing to report. Just run the installation steps for Ubuntu 18.04 [here](https://www.microsoft.com/net/download/linux-package-manager/ubuntu18-04/sdk-current) and you should have a working .NET Core installation. Let's test it out.

```Bash
$ mdkir coreTest
$ cd coreTest
$ dotnet new console
$ dotnet run
Hello World!
```

![](/images/install-cosmic/dotnetcli.png)

Looks like it works to me, now to the other key pieces of a .NET Core dev environment on Linux.

## Install VSCode

Again, another easy one, just download the *.deb* file from the website and run the installation. It works without any additional needed configuration.

![](/images/install-cosmic/vscode.png)

Now time for the last piece.

## Install PowerShell

And you thought I wasn't going to mention PowerShell in this post. This one is super easy as PowerShell is available in Ubuntu Software as a snap. Open Ubuntu Software and install PowerShell.

![](/images/install-cosmic/ps-ubu-soft.png)

After it is installed, you can launch your terminal and run the following command:

```Bash
$ pwsh
PowerShell 6.1.0
Copyright (c) Microsoft Corporation. All rights reserved.

https://aka.ms/pscore6-docs
Type 'help' to get help.

PS /home/phillipsj>
```

And here is what it looks like in action:

![](/images/install-cosmic/pwsh.png)

## That's it

That's it for now, there are plenty of other tools we could install like [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download?view=sql-server-2017), but I will leave that you as it isn't much different that installing VSCode. [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/) is a little different, however there is an upstream issue that is causing a *segfault* error to occur. Once that is fixed, I will make a post about it.

Thanks for reading,

Jamie