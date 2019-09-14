---
Title: "Linux toolbox for .NET Development"
date: 2017-12-17T16:35:28
Tags: 
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
---
# Linux toolbox for .NET Development

This is going to be my list of the tools that I setup when doing .NET development on Linux. I know my future self is going to reference this and I hope others find it useful.

## .NET SDKs

This is pretty easy, you need to have .NET core at a minimum. I do find having Mono installed is useful sometimes when a particular tool you need to use is not available on .NET core or you need to create a Mono/Xamarin app.

* [.NET Core SDK](https://www.microsoft.com/net/core#linuxubuntu)
* [Mono](http://www.mono-project.com/download/#download-lin-ubuntu)

Just follow the directions above to get the bits you need. I would suggest on the Mono front installing *mono-complete*, *mono-dbg*, *referenceassemblies-pcl*, and *mono-xsp4*.

## Code Editors and IDEs

There are many choices in this area thanks to the [Omnisharp project](http://www.omnisharp.net/#integrations). My favorite choices are below.

* [Visual Studio Code](https://code.visualstudio.com/)
* [JetBrains Rider](https://www.jetbrains.com/rider/)

There is always [Mono-Develop](http://www.monodevelop.com/download/linux/), but it will require Flatpak to get the latest version.

## Visual git Guis

Ah, I know, sometimes I just like having a nice gui for git. Not a heck of a lot of choices, however my favorite tool is available.

* [GitKraken](https://www.gitkraken.com/download)

I have heard great things about [Git Cola](https://git-cola.github.io/), but I have not used it enough to form my own opinion.
