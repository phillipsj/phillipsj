---
Title: ".NET Core Development on Elementary OS 5.0 Juno"
date: 2018-10-22T22:54:54
Tags: 
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
---
# .NET Core Development on Elementary OS 5.0 Juno

Someone mentioned [Elementary OS](https://elementary.io/) and how you would set it up to do .NET Development. In the past it would have been a little more challenging, however it seems pretty straight forward with the Juno release. Let's get started.

![](/images/elementary/Desktop.png)

## Install Eddy

We need to work with installing a few debian packages and elementary doesn't come with a graphical debian package installation tool by default.

Launch the App Center and search for a tool called Eddy. Click on it and then run *Install*.

![](/images/elementary/InstallEddy.png)

After Eddy is installed we can start working on the other tools that we need.

## Install .NET Core SDK

We are going to install the .NET Core SDK. Since Elementary OS 5 Juno is based on Ubuntu 18.04, we can follow those installation directions from the .NET home page. We cannot run the *dpkg* command since that tool isn't installed by default on Elementary.

```Bash
$ wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
```

Now that it has been downloaded, open the folder where you downloaded it and click it once to launch Eddy to install it.

![](/images/elementary/InstallingMicrosoftRepo.png)

Now we can hop back to the terminal and run the remaining commands.

```Bash
$ sudo apt-get install apt-transport-https
$ sudo apt-get update
$ sudo apt-get install dotnet-sdk-2.1
```

When that is finished, let's test it out and make sure that everything install correctly.

```Bash
$ dotnet --version
2.1.403

$ mkdir test
$ cd test
$ dotnet new console
$ dotnet run
Hello World!
```

Looks like we have a working .NET Core installation, now we just need a development environment.

## Install Visual Studio Code

This is all personal preference at this point. I know many people that use vim and emacs to do .NET. Elementary has a really nice app called *Code* that is already installed that can do C# syntax highlighting and I am sure that an extension could be written to provide omnisharp support. With that said, I prefer VSCode as I can use it everywhere.

Go to the VSCode page and download the debian package.

![](/images/elementary/GettingVSCode.png)

Again we are going to use Eddy to install it.

![](/images/elementary/InstallingVSCode.png)

Once installed just hit *super key + space bar* and type vs and it should pull it up.

![](/images/elementary/VSCodeRunning.png)

## Final Thoughts

I really enjoy the aesthetics of Elementary. The feel of using it is very unique and elegant. Many of the apps it has work very well and I like the fact that Solorized themes are available for the terminal and Code editor. The default terminal configuraiton is pretty slick and has some of that Oh-My-Zsh feel to it, but it's Bash. I feel most people will really enjoy using it and some of the small details haven't been forgotten.

My biggest quibble is that it isn't like a typical Linux distro. A debian package installation tool isn't installed by default and neither is a system monitor. Both of those items are things I use pretty regularly. Lastly, some of the UI features I personally find frustrating like the choice to not have minimize and maximize buttons like MacOS. Not having this feature alone is almost the deal breaker for me.
