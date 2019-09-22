---
title: "Azure CLI on Manjaro"
date: 2019-09-21T21:49:45-04:00
tags:
- Open Source
- Azure
- Microsoft And Linux
- Tools
- Manjaro
---

I have decided to give [Manjaro](https://manjaro.org/) Linux a couple of months as my daily driver distro to see how it works. I have only briefly tried it in the past, so this is my first time giving it any serious time. Along with a new distro comes getting all the tooling that I use regularly up and running. This post is going to cover how to get the [Azure CLI](Get started with Azure CLI | Microsoft Docs.html) installed. Microsoft primarily packages their tools for more mainstream distros like Ubuntu, RHEL, Fedora, and OpenSUSE. However, there is an option to install using an installation script which will be the option we will use, and you can find more [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?view=azure-cli-latest).

The first step is to make sure we meet the prerequisites. Manjaro comes with Python 3.7.4 installed, so that meets the Python requirement. The last two requirements are libffi and OpenSSL 1.0.2. Those are both available in the Manjaro repositories, so a quick install with Pacman is all that we need.

```Bash
$ sudo pacman -S libffi openssl-1.0
resolving dependencies...
looking for conflicting packages...

Packages (2) libffi-3.2.1-3  openssl-1.0-1.0.2.s-1

Total Installed Size:  5.93 MiB
Net Upgrade Size:      0.00 MiB

:: Proceed with installation? [Y/n] y
(2/2) checking keys in keyring                                           [#########################################] 100%
(2/2) checking package integrity                                         [#########################################] 100%
(2/2) loading package files                                              [#########################################] 100%
(2/2) checking for file conflicts                                        [#########################################] 100%
(2/2) checking available disk space                                      [#########################################] 100%
:: Processing package changes...
(1/2) reinstalling libffi                                                [#########################################] 100%
(2/2) reinstalling openssl-1.0                                           [#########################################] 100%
:: Running post-transaction hooks...
(1/2) Arming ConditionNeedsUpdate...
(2/2) Updating the info directory file...
```

Now we have all the prerequisites resolved, and we can proceed with running the installation script. Two locations prompts happen during the installation. I like putting these in my *.local* folder, and this will hide the files by default. Hiding the files isn't required, and you can use the defaults if you want. 

**Run this command as a regular user**

```Bash
$ curl -L https://aka.ms/InstallAzureCli | bash
===> In what directory would you like to place the install? (leave blank to use '/home/username/lib/azure-cli'): /home/username/.local/lib/azure-cli
-- Creating directory '/home/username/.local/lib/azure-cli'.
-- We will install at '/home/username/.local/lib/azure-cli'.

===> In what directory would you like to place the 'az' executable? (leave blank to use '/home/username/bin'): /home/username/.local/bin

# installation happens here

===> Modify profile to update your $PATH and enable shell/tab completion now? (Y/n): Y

===> Enter a path to an rc file to update (leave blank to use '/home/username/.bashrc'): 
```

Now that the installation has completed, we need to reload our shell and test the *az* command.

```Bash
$ exec -l $SHELL
$ az --version
azure-cli                         2.0.73

command-modules-nspkg               2.0.3
core                              2.0.73
nspkg                              3.0.4
telemetry                          1.0.3

Python location '/home/username/.local/lib/azure-cli/bin/python'
Extensions directory '/home/username/.azure/cliextensions'

Python (Linux) 3.7.4 (default, Jul 16 2019, 07:12:58) 
[GCC 9.1.0]

Legal docs and information: aka.ms/AzureCliLegal


Your CLI is up-to-date.
```

That's it, and you now have the Azure CLI working on Manjaro. I have something fun planned that could make this easier.

Thanks for reading,

Jamie
