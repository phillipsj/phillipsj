---
title: "Install PowerShell on Fedora 32"
date: 2020-05-20T20:30:12-04:00
Tags:
- Open Source
- Microsoft And Linux
- Tools
- Fedora
- PowerShell
---

There are many ways to install [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7) on Linux. I usually install PowerShell as a snap package. Fedora doesn't have snaps installed by default, so I figured I would use a different method. The available repositories are not updated for Fedora 32 but still may work. That leaves doing a binary archive installation or leveraging the global .NET Core tool. The binary method requires installing dependencies, and the global tool requires the installation of .NET Core. Considering the requirements are the .NET Core requirements, I think it would be best to install the .NET Core SDK, which will cover everything that is needed. If you want to know how to install .NET Core on Fedora 32, you can check out this [post](https://www.phillipsj.net/posts/install-dotnet-core-on-fedora-32/).

## Disabling Telemetry

You can find out more about the [telemetry](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_telemetry?view=powershell-7) collected here. You can opt-out by setting an environment variable. I am going to show you how to set it in your *.profile*, so when you log in, it will set the environment variable for you.

```bash
$ cd ~
$ echo 'export POWERSHELL_TELEMETRY_OPTOUT=1' >> .profile
```

Now reboot, and you will have this set. If you don't want your installation telemetry sent, then set this before running your installation.

## Installation

Once we have the .NET Core SDK installed, we can execute the global tool command for PowerShell.

```bash
$ dotnet tool install --global PowerShell
You can invoke the tool using the following command: pwsh
Tool 'powershell' (version '7.0.0') was successfully installed.
```

Now we can follow the message by executing *pwsh*.

```bash
$ pwsh
PowerShell 7.0.0
Copyright (c) Microsoft Corporation. All rights reserved.

https://aka.ms/powershell
Type 'help' to get help.

PS > 
```

Excellent, it works, and we now have a PowerShell command prompt. Let's execute a command to print the PowerShell version table.

```bash
PS > $PSVersionTable

Name                           Value
----                           -----
PSVersion                      7.0.0
PSEdition                      Core
GitCommitId                    7.0.0
OS                             Linux 5.6.10-300.fc32.x86_64 #1 SMP Mon May 4 14:29:45 UTC 2020
Platform                       Unix
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0
```

## Conclusion

That's it, and now you can start using PowerShell on Fedora. If you need some resources to get started, check out the [PowerShell tag](https://www.phillipsj.net/tags/powershell/) on my blog. 

Thanks for reading,

Jamie
