---
Title: "Installing Azure CLI on Linux Mint 19"
Published: 09/15/2018 10:22:03
Tags: 
- Azure
- Linux
- Open Source
- Tools
---
# Installing Azure CLI on Linux Mint 19


```
$ echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ bionic main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
$ sudo apt update
$ sudo apt install azure-cli
```