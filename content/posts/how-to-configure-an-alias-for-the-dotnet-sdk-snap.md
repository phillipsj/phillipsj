---
Title: "How To Configure an Alias for The .NET SDK Snap"
date: 2019-05-27T20:35:18
Tags: 
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
- Ubuntu
---
# How To Configure an Alias for The .NET SDK Snap

### Introduction

[Snaps](https://docs.snapcraft.io/) are packages that allow easy, agnostic, and sandboxed installation of applications on Linux. This will enable you to be able to install the same app across any Linux distribution that supports Snap packages. To aid you in working with Microsoft applications, they have started creating Snaps for [PowerShell](https://snapcraft.io/powershell), [Visual Studio Code](https://snapcraft.io/code), and the [.NET SDK](https://snapcraft.io/dotnet-sdk). The PowerShell and Visual Studio Code Snaps operate as one would expect, however, the .NET SDK Snap doesn't perform as you would expect. Due to the nature of the sandboxing technology used by Snaps, the commands for the application are structured as follows:  **application-name.command**. What this means is that to call the .NET SDK on the command line, you will need to execute the following command:

```Bash
$ dotnet-sdk.dotnet

Usage: dotnet [options]
Usage: dotnet [path-to-application]

Options:
  -h|--help         Display help.
  --info            Display .NET Core information.
  --list-sdks       Display the installed SDKs.
  --list-runtimes   Display the installed runtimes.

path-to-application:
  The path to an application .dll file to execute.
```

Take note that you have to use the Snap name along with the command you want to execute, which in this case is the .NET CLI. The issue with this new command structure is that all scripts and tooling will expect the command to be named exactly like the command above. If you made that change then someone working on MacOS, Windows, or someone who didn't install using the Snap would have that script or tool break on their system.

Fortunately, Snaps offer a way for you to address this issue by creating a [alias](https://docs.snapcraft.io/commands-and-aliases). Follow along to create a **dotnet** alias for the **dotnet-sdk.dotnet** command.

## Prerequisites

To follow this tutorial, you will need:

* A Linux distribution that supports Snaps.
* [Snapd](https://docs.snapcraft.io/getting-started) installed on your system.
* The [.NET SDK Snap](https://snapcraft.io/dotnet-sdk) installed.

This tutorial is using Ubuntu, which has been shipping with Snap support since 16.04.

## Step 1 - Verify .NET SDK Snap Installation

The very first thing to do is to verify that the .NET SDK Snap is installed.

```Bash
$ snap list
Name                    Version                 Rev   Tracking  Publisher              Notes
core                    16-2.39                 6964  stable    canonical✓             core
core18                  20190508                970   stable    canonical✓             base
dotnet-sdk              2.2.300                 39    stable    dotnetcore✓            classic
```

This command lists all Snaps currently installed on your system. If the .NET SDK isn't found in your list, please install it following the information located [here](https://snapcraft.io/dotnet-sdk).

## Step 2 - Execute the .NET SDK

Next, you need to validate the installation by executing the command.

```Bash
$ dotnet-sdk.dotnet

Usage: dotnet [options]
Usage: dotnet [path-to-application]

Options:
  -h|--help         Display help.
  --info            Display .NET Core information.
  --list-sdks       Display the installed SDKs.
  --list-runtimes   Display the installed runtimes.

path-to-application:
  The path to an application .dll file to execute.
```

Everything looks great, time to create the alias.

## Step 3 - Creating the Alias

Now you can create the **dotnet** alias for the **dotnet-sdk.dotnet** command. You will need administrative privileges.

```Bash
$ sudo snap alias dotnet-sdk.dotnet dotnet
Added:
  - dotnet-sdk.dotnet as dotnet
```

You can now validate that it shows in your list of Snap aliases by running this command.

```Bash
$ snap aliases
Command                               Alias           Notes
dotnet-sdk.dotnet                     dotnet          manual
```

This command lists all Snap aliases configured on the system. Some packages will have aliases by default. However, this requires working directly with Snapcraft.

## Step 4 - Test the New Alias

Now that you have the alias configured let's test it out to ensure that it is working as expected.

```Bash
$ dotnet

Usage: dotnet [options]
Usage: dotnet [path-to-application]

Options:
  -h|--help         Display help.
  --info            Display .NET Core information.
  --list-sdks       Display the installed SDKs.
  --list-runtimes   Display the installed runtimes.

path-to-application:
  The path to an application .dll file to execute.
```

The alias is working as expected, now any scripts or tools will work as expected using the Snap installation.

## Conclusion

You have learned how Snap packages work, commands are formed, and how to create an alias so existing scripts or tools will not break when leveraging Snaps. A default alias would be nice, however, understanding that Snaps allow multiple installations of different versions prevents a default from being used in this case.  

Thanks for reading,

Jamie
