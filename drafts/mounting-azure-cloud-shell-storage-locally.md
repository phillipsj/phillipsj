---
Title: "Mounting Azure Cloud Shell Storage Locally"
Published: 10/27/2018 21:14:11
Tags: 
- Open Source
- Microsoft And Linux
- Azure
- Ubuntu
- Rclone
- Cloud Shell
---
# Mounting Azure Cloud Shell Storage Locally

If you haven't had a chance to use [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) you are really missing out on a really cool feature in Azure. Cloud Shell provides you a terminal based environment in your browser. You can choose Bash or PowerShell and it comes pre-installed with many tools like the Azure CLI, Terraform, Ansible, tmux, vim, VSCode, etc. The full list can be found [here](https://docs.microsoft.com/en-us/azure/cloud-shell/features#tools). Cloud Shell is backed by an Azure Storage account so you can access your scripts, environments, etc. from a central location using a web browser, Azure Mobile App, etc. However, sometimes you would like to be able to pull or push files from your local machine to the cloud storage account so they can be accessed in your Cloud Shell. You could easily pull and push files with some like [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/), however, I am going to show you have to do that using [Rclone](https://rclone.org/). In a previous [post](https://www.phillipsj.net/posts/using-onedrive-with-linux), I covered how to install it on Ubuntu 18.04 so I will not be covering that. What I will be covering is how to configure it for mounting your Cloud Shell storage account on both Ubuntu, including other Linux distros, and Windows. Let's get started.

## Configuration on Linux

