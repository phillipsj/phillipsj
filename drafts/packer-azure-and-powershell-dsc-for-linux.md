---
Title: "Packer, Azure, and PowerShell DSC for Linux"
Published: 09/15/2018 10:05:49
Tags: 
- Open Source
- Packer
- Azure
- PowerShell
- Linux
---
# Packer, Azure, and PowerShell DSC for Linux

I have been interested in [PowerShell DSC](https://docs.microsoft.com/en-us/powershell/dsc/overview) since I first heard about it a few years ago. I haven't really had the chance to check it out until lately as part of studying for my Azure certification. While watching a PluralSight video I discovered that the generated *mof* file can also be executed on Linux using the [PowerShell DSC for Linux](https://docs.microsoft.com/en-us/powershell/dsc/lnxgettingstarted). To make this all work Microsoft created the [Open Management Infrastructure](https://github.com/Microsoft/omi) or OMI for short. This is something that gets installed on your target machine that can process the *mof* that gets generated. 

In this blog post, I am going to walk through creating an environment for creating PowerShell DSCs for Linux and then demonstrating how Packer can be used to bootstrap creating an Azure Ubuntu 18.04 image with OMI already installed. I will finish up using Terraform to create and provision the VM in Azure using PowerShell DSC.

## Installing Tooling

To achieve the objective, I will need to have the following installed.

* Packer
* Terraform
* Azure CLI
* PowerShell