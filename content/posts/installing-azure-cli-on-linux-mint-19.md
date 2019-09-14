---
Title: "Installing Azure CLI on Linux Mint 19"
date: 2018-09-15T21:22:03
Tags: 
- Azure
- Linux
- Microsoft And Linux
- Open Source
- Tools
---
# Installing Azure CLI on Linux Mint 19

Installing the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) on Linux Mint 19 isn't much different that what is required for Ubuntu. The biggest difference of note is that the command *lsb_release -cs* cannot be relied upon at all because it will not return an Ubuntu distro name, but a Linux Mint distro name. Start by modifying the directions found [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest) to match what is below. Make sure to add the key in the directions above, if my previous blog post about [].NET tools on Linux Mint 19](https://www.phillipsj.net/posts/linux-mint-19-and-dotnet-development) was followed, then adding the key isn't necessary as it will already exist, that is the same if Visual Studio Code is already installed too.

```
$ echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ bionic main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
$ sudo apt update
$ sudo apt install azure-cli
```

After executing those steps with putting *bionic* in as the distro name the Azure CLI should be working. Thanks for reading.
