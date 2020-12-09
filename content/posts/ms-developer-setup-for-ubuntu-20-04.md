---
title: "MS Developer Setup for Ubuntu 20.04"
date: 2020-12-08T22:25:01-05:00
tags:
- Open Source
- Dotnet Core
- Microsoft And Linux
- Tools
- Ubuntu
- .NET Core
- PowerShell
---

Do you need to work with Microsoft related tech, but you want to run Ubuntu 20.04 or a flavor of 20.04? There are many steps to get all the software that you may need to work with .NET, PowerShell, or Azure. I decided to create a script that will install most Microsoft-related tools that you may need to do so. The one item that hasn't yet been standardized like the other tools is Azure Data Studio, so it isn't included. Here is the script, and it is in a [gist](https://gist.github.com/phillipsj/535c633e2aa8137de3a8e3420356cb62) too.

```Bash
sudo apt-get update

sudo apt-get install -y wget curl ca-certificates curl apt-transport-https lsb-release gnupg build-essential git docker.io docker-compose 

wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

# Add Repos
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/

sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main" > /etc/apt/sources.list.d/teams.list'
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'


sudo apt-get update
sudo add-apt-repository universe

sudo apt-get install -y powershell dotnet-sdk-3.1 code azure-cli teams microsoft-edge-dev

# Snaps
sudo snap install storage-explorer
```

I just save it as *msdev-setup.sh* and then I can execute it like so:

```Bash
$ sh msdev-setup.sh
```

I probably could have pulled Storage Explorer instead of the snap. However, I have found this is the best option due to some of the past dependency issues. This script will look a little different from what each product may have on its web page instructions. I don't know why Microsoft has so much variation in how they say to set up the repositories.

I hope you find this helpful, and thanks for reading,

Jamie
