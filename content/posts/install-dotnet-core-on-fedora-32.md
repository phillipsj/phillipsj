---
title: "Install .NET Core on Fedora 32"
date: 2020-05-17T22:09:20-04:00
Tags:
- Open Source
- Dotnet Core
- Microsoft And Linux
- Tools
- Fedora
- .NET Core
---

[Fedora 32](https://fedoramagazine.org/announcing-fedora-32/) was released a few short weeks ago. In this latest release .NET Core 3.1 is being shipped in the official repositories. This package now makes it simpler to install than before. In this post, we will walk through installing .NET Core 3.1 and how to disable telemetry if you desire.

## Disabling Telemetry

You can find out more about the [telemtery](https://docs.microsoft.com/en-us/dotnet/core/tools/telemetry) collected here. You can [opt out](https://docs.microsoft.com/en-us/dotnet/core/tools/telemetry#how-to-opt-out) by setting an environment variable. I am going to show you how to set it in your *.profile*, so when you log in, it will set the environment variable for you.

```bash
$ cd ~
$ echo 'export DOTNET_CLI_TELEMETRY_OPTOUT=1' >> .profile
```

Now reboot, and you will have this set. If you don't want your installation telemetry sent, then set this before running your installation.

## Installation

Let's search the package repositories and find the name of the new .NET Core packages.

```bash
$ sudo dnf search dotnet*
dotnet.x86_64 : .NET Core CLI tools and runtime
dotnet-host.x86_64 : .NET command line launcher
dotnet-sdk-3.1.x86_64 : .NET Core 3.1 Software Development Kit
dotnet-hostfxr-3.1.x86_64 : .NET Core command line host resolver
dotnet-runtime-3.1.x86_64 : NET Core 3.1 runtime
dotnet-templates-3.1.x86_64 : .NET Core 3.1 templates
dotnet-apphost-pack-3.1.x86_64 : Targeting Pack for Microsoft.NETCore.App 3.1
dotnet-targeting-pack-3.1.x86_64 : Targeting Pack for Microsoft.NETCore.App 3.1
dotnet-build-reference-packages.x86_64 : Reference packages needed by the .NET Core SDK build
dotnet-sdk-3.1-source-built-artifacts.x86_64 : Internal package for building .NET Core 3.1 Software Development Kit
```

Our search returned ten packages. The top result is a meta-package that installs all the required packages and the only one to start doing .NET development. Let's install the package.

```bash
$ sudo dnf install dotnet -y
Transaction Summary
====================================================================================================================
Install  16 Packages

Total download size: 88 M
Installed size: 299 M

Installed:
  aspnetcore-runtime-3.1-3.1.3-1.fc32.x86_64            aspnetcore-targeting-pack-3.1-3.1.3-1.fc32.x86_64           
  dotnet-3.1.103-1.fc32.x86_64                          dotnet-apphost-pack-3.1-3.1.3-1.fc32.x86_64                 
  dotnet-host-3.1.3-1.fc32.x86_64                       dotnet-hostfxr-3.1-3.1.3-1.fc32.x86_64                      
  dotnet-runtime-3.1-3.1.3-1.fc32.x86_64                dotnet-sdk-3.1-3.1.103-1.fc32.x86_64                        
  dotnet-targeting-pack-3.1-3.1.3-1.fc32.x86_64         dotnet-templates-3.1-3.1.103-1.fc32.x86_64                  
  libicu-65.1-2.fc32.x86_64                             libunwind-1.3.1-5.fc32.x86_64                               
  lttng-ust-2.11.0-4.fc32.x86_64                        netstandard-targeting-pack-2.1-3.1.103-1.fc32.x86_64        
  numactl-libs-2.0.12-4.fc32.x86_64                     userspace-rcu-0.11.1-3.fc32.x86_64                          

Complete!
```

The command installed 16 packages existing of the ten listed above, a few ASP .NET Core packages, and some dependencies for the runtime. Now let's create a test project and make sure that it behaves as expected.

```bash
$ dotnet new console -o test
Getting ready...
The template "Console Application" was created successfully.
```

Now let's run the default console application.

```bash
$ cd test
$ dotnet run
Hello World!
```

## Conclusion

Thanks for reading, and I hope you found this useful. I have been enjoying Fedora 32, and I thought I would share that the step of adding a repository isn't needed any longer.

Jamie
