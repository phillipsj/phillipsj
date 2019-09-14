---
Title: "Packaging .NET Core with Flatpak"
date: 2019-02-09T21:23:20
Tags: 
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
- Flatpak
---
# Packaging .NET Core with Flatpak

Someone reminded me on Twitter that I mentioned covering how to package .NET Core applications using [Flatpak](https://flatpak.org/) or [Snaps](https://snapcraft.io/). Here is a quick guide on how to create a Flatpak app with .NET Core. You will need to be on a Linux distribution that you can install the Flatpak tools. I am using an Ubuntu-based distro so that will be the steps that I show. Let's jump in and get started.

## Installing Flatpak and Flatpak Builder

We will need to install Flatpak and Flatpak builder. To do this on Ubuntu 18.04, you will need to add a PPA for Flatpak. If you are on a newer version, then you can just run the commands without adding the PPA. A quick note about PPAs, these are Personal Package Archives which means that you are taking someone else's word that the software is safe. In the case of Flatpak, I trust it.

```Bash
$ sudo add-apt-repository ppa:alexlarsson/flatpak
$ sudo apt update
$ sudo apt install flatpak flatpak-builder
```

Once that completes, we will need to add the Flathub software repository so we can get other resources we will need.

```Bash
$ flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

Now we need to do something that seems a little odd, and we need to restart our system to finish the installation.

```Bash
$ sudo shutdown -r now
```

Once your system is back up, we can get started on building our example .NET Core application.

## Creating our .NET Core Application

I am going to assume that you have .NET Core already installed and configured. If not, you can use one of my guides location [here](https://www.phillipsj.net/tags/net-core). Okay, let's create our test app.

```Bash
$ dotnet new console -o flatpak-dotnetcore
The template "Console Application" was created successfully.
```

Now navigate open that directory in your favorite editor and make the following changes to your *Program.cs*.

```C#
using System;

namespace flatpak_dotnetcore
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello from Flatpak!");
        }
    }
}
```

Now let's make sure that our application builds.

```Bash
$ dotnet build
Microsoft (R) Build Engine version 15.9.20+g88f5fadfbe for .NET Core
Copyright (C) Microsoft Corporation. All rights reserved.

  Restore completed in 60.82 ms for ../flatpak-dotnetcore/flatpak-dotnetcore.csproj.
  flatpak-dotnetcore -> ../flatpak-dotnetcore/bin/Debug/netcoreapp2.2/flatpak-dotnetcore.dll

Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:03.23
```

Okay, the final step is going to be to package it up so we can build our Flatpak. We are going to use [Warp](https://github.com/dgiagio/warp) to accomplish getting a single binary. I have done a post [here](https://www.phillipsj.net/posts/warp-single-executable-dotnet-core-app) on it in the past. We will install it as a global .NET Core tool.

```Bash
$ dotnet tool install -g dotnet-warp
You can invoke the tool using the following command: dotnet-warp
Tool 'dotnet-warp' (version '1.0.4') was successfully installed.
```

Now we can build our single binary by using the following command.

```Bash
$ dotnet-warp
✔ Running Publish...
✔ Running Pack...
```

Now if you list all the files in your directory, you will see that we have the following.

```Bash
$ ls -lt
total 28784
-rwxr-xr-x 1 phillipsj phillipsj 29456076 Feb  9 21:41 flatpak-dotnetcore
drwxrwxr-x 5 phillipsj phillipsj     4096 Feb  9 21:41 obj
drwxrwxr-x 4 phillipsj phillipsj     4096 Feb  9 21:41 bin
-rw-rw-r-- 1 phillipsj phillipsj      207 Feb  9 21:36 Program.cs
-rw-rw-r-- 1 phillipsj phillipsj      233 Feb  9 21:35 flatpak-dotnetcore.csproj
```

And we can execute *flatpak-dotnetcore* by doing the following.

```Bash
$ ./flatpak-dotnetcore
Hello from Flatpak!
```

It's time to pack this as a Flatpak.

## Creating our Flatpak

Since we are using Warp to create a single binary .NET Core application that includes our .NET Core Runtime we can use the Freedesktop 18.08 runtime and SDK for our Flatpak. I am not going into a lot of detail about how Flatpaks work, but you can read more [here](http://docs.flatpak.org/en/latest/introduction.html).

```Bash
$ flatpak install flathub org.freedesktop.Platform//18.08 org.freedesktop.Sdk//18.08
Looking for matches…
Skipping: org.freedesktop.Platform/x86_64/18.08 is already installed
Skipping: org.freedesktop.Sdk/x86_64/18.08 is already installed
```

Flatpak uses a JSON based manifest to provide information about the application and how to build it. Since we are offering a prebuilt app, we can keep it simple. So let's create our manifest called *org.flatpak.DotNetCore.json*.

```Bash
$ touch org.flatpak.DotNetCore.json
```

Now open it in your favorite editor and past the following.

```JSON
{
    "app-id": "org.flatpak.DotNetCore",
    "runtime": "org.freedesktop.Platform",
    "runtime-version": "18.08",
    "sdk": "org.freedesktop.Sdk",
    "command": "flatpak-dotnetcore",
    "modules": [
        {
            "name": "flatpak-dotnetcore",
            "buildsystem": "simple",
            "build-commands": [
                "install -D flatpak-dotnetcore /app/bin/flatpak-dotnetcore"
            ],
            "sources": [
                {
                    "type": "file",
                    "path": "flatpak-dotnetcore"
                }
            ]
        }
    ]
}
```

Now we can build our application.

```Bash
$ flatpak-builder build-dir org.flatpak.DotNetCore.json
Downloading sources
Initializing build dir
Committing stage init to cache
Starting build of org.flatpak.DotNetCore
========================================================================
Building module flatpak-dotnetcore in /home/phillipsj/code/flatpak-dotnetcore/.flatpak-builder/build/flatpak-dotnetcore-1
========================================================================
Running: install -D flatpak-dotnetcore /app/bin/flatpak-dotnetcore
Committing stage build-flatpak-dotnetcore to cache
Cleaning up
Committing stage cleanup to cache
Finishing app
Please review the exported files and the metadata
Committing stage finish to cache
Pruning cache
```

Now let's test that the build worked.

```Bash
$ flatpak-builder --run build-dir org.flatpak.DotNetCore.json flatpak-dotnetcore
Hello from Flatpak!
```

Awesome! We made it this far. However, this is running it locally and not how it will run if we were to publish this to a Flatpak repository like FlatHub. So what we will do is create a local repository, publish it to our local repository, then install it like you work a Flatpak from FlatHub and make sure it works.

```Bash
$ flatpak-builder --repo=repo --force-clean build-dir org.flatpak.DotNetCore.json
Emptying app dir 'build-dir'
Downloading sources
Starting build of org.flatpak.DotNetCore
Cache hit for flatpak-dotnetcore, skipping build
Cache hit for cleanup, skipping
Cache hit for finish, skipping
Everything cached, checking out from cache
Exporting org.flatpak.DotNetCore to repo
Commit: d113ac58b11a5e8455598db798f79eb252713a6c8a1483ad65a1bf4fce4054c5
Metadata Total: 9
Metadata Written: 6
Content Total: 3
Content Written: 3
Content Bytes Written: 29456902 (29.5 MB)
Pruning cache
```

Finally, we can install the application to do a test in an accurate sandboxed installation.

```Bash
$ flatpak --user remote-add --no-gpg-verify tutorial-repo repo
$ flatpak --user install tutorial-repo org.flatpak.DotNetCore
Looking for matches…


        ID                             Arch           Branch         Remote                Download
 1. [✓] org.flatpak.DotNetCore         x86_64         master         tutorial-repo         1.0 kB / 28.9 MB

Installation complete.
```

Does it actually work?

```Bash
$ flatpak run org.flatpak.DotNetCore
Hello from Flatpak!
```

## Conlusion

There you go, quick and easy. If you followed along, you just created and packaged a .NET Core application as a Linux application that can be distributed as a Flatpak to any Linux distribution that supports Flatpak, which is almost all of them.

Thanks for reading,

Jamie

**If you enjoy the content then consider [buying me a coffee](https://www.buymeacoffee.com/aQPnJ73O8).**
