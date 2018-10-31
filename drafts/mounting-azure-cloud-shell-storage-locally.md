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

If you haven't had a chance to use [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) you are really missing out on a really cool feature in Azure. Cloud Shell provides you a terminal based environment in your browser. You can choose Bash or PowerShell and it comes pre-installed with many tools like the Azure CLI, Terraform, Ansible, tmux, vim, VSCode, etc. The full list can be found [here](https://docs.microsoft.com/en-us/azure/cloud-shell/features#tools). Cloud Shell is backed by an Azure Storage account so you can access your scripts, environments, etc. from a central location using a web browser, Azure Mobile App, etc. However, sometimes you would like to be able to pull or push files from your local machine to the cloud storage account so they can be accessed in your Cloud Shell. You could easily pull and push files with some like [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/), however, sometimes you would like to be able to pull or push files from your local machine to the cloud storage account so they can be accessed in your Cloud Shell. Cloud Shell stores the files in Azure Storage using [Azure Files](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction) which uses the [SMB](https://en.wikipedia.org/wiki/Server_Message_Block) 3.0. Microsoft was kind enough to provide instructions for mounting an Azure Files storage on [Windows](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-windows), [MacOS](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-mac) and [Linux](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux). In this tutorial we are going to explore all the options for mounting Azure Files storage on Ubuntu 18.x and make sure there aren't any gotchas in the directions.  Let's get started.

## Microsoft Directions

Let's get started with the directions provided. I will be changing the commands a little, but the commands provided by the instructions will work too. We will need to know the following:

* Storage Account Name
* Storage Account Key
* File permissions you want to use, we will give full permissions by using 0777
* Make sure port 445 is open on your firewall

First step is to install the cifs-util.

```Bash
$ sudo apt install cifs-util
```

Now let's create the mount point we want to use. I want to mount mine in my home directory as I think that is cleaner.

```Bash
$ mkdir /home/phillipsj/cloud-shell
```

Now we can mount the cloud shell drive.

```Bash

```

