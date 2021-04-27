---
title: "Using Packer to Create Docker Windows Image for Azure"
date: 2021-04-26T21:43:09-04:00
tags:
- Open Source
- PowerShell
- Microsoft And Linux
- Docker
- Azure
- Packer
---

I need to have Docker installed on Windows Server 2019. There doesn't appear to be one that exists in the Azure Marketplace that I could find. Bootstrapping the installation of Docker during VM creation takes some time and requires a reboot as part of the process. There are few solutions to accomplish that, so I decided to create a shared image using [Packer](https://www.packer.io/). Before we can dive into the Packer configuration, we need to create a resource group and shared image gallery. If you have existing ones that you would like to use, then substitute them.

## Pre-Configuration

Here is the Terraform for creating the resource group, the shared image gallery, and the shared image.

```HCL
terraform {
  required_version = "~> 0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.56"
    }
  }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "shared_gallery" {
  name     = "shared-gallery-rg"
  location = "East US"
}

resource "azurerm_shared_image_gallery" "shared_gallery" {
  name                = "sharedimagegallery"
  resource_group_name = azurerm_resource_group.shared_gallery.name
  location            = azurerm_resource_group.shared_gallery.location
  description         = "Shared images for Windows with Docker."
}

resource "azurerm_shared_image" "shared_image" {
  name                = "WindowsDocker"
  gallery_name        = azurerm_shared_image_gallery.shared_gallery.name
  resource_group_name = azurerm_resource_group.shared_gallery.name
  location            = azurerm_resource_group.shared_gallery.location
  os_type             = "Windows"

  identifier {
    publisher = "MyPublisher"
    offer     = "WindowsDocker"
    sku       = "2019"
  }
}
```

## Packer Azure Configuration

Now we can start with our Packer configuration. I will be using the HCL version now, and I am glad that the support is improved. I will be using the Azure CLI authentication option, which you can read about [here](https://www.packer.io/docs/builders/azure/arm#use_azure_cli_auth).

```HCL
variable "subscription_id" {
  description = "Subscription ID to use."
  type        = string
  default     = "00000000-0000-0000-0000-00000000000"
}

source "azure-arm" "docker" {
  use_azure_cli_auth = true
  
  shared_image_gallery_destination {
    subscription        = var.subscription_id
    resource_group      = "shared-gallery-rg"
    gallery_name        = "sharedimagegallery"
    image_name          = "WindowsDocker"
    image_version       = "0.1.0"
    replication_regions = ["East US"]
  }
  managed_image_name                = "Windows2019Docker"
  managed_image_resource_group_name = "shared-gallery-rg"

  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2019-Datacenter"

  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "3m"
  winrm_username = "packer"
  
  location = "East US"
  vm_size  = "Standard_A1_v2"
}
```

Now we need to set up our provisioners. The first one will install Docker using the PowerShell provider. The next one restarts the machine for good measure, and the last one executes the sysprep step.

```HCL
build {
  sources = ["sources.azure-arm.docker"]

  provisioner "powershell" {
    pause_before = "5m"
    inline = [
      "Write-Host 'Starting Docker installation...'",
      "Write-Host 'Installing NuGet Provider...'",
      "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force",     
      "Write-Host 'Installing Docker Provider...'",
      "Install-Module -Name DockerMsftProvider -AllowClobber -Confirm:$false -Force",
      "Write-Host 'Installing Package...'",
      "Install-Package -Name docker -ProviderName DockerMsftProvider -Confirm:$false -Force",
      "Write-Host 'Completed Docker installation...'"
    ]
  }

  provisioner "windows-restart" {
    pause_before = "1m"
  }  
  
  provisioner "powershell" {
     pause_before = "3m"
     inline = [
          "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
          "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
          "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
          "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
     ]
  }
}
```

Now we can save this all as *docker-windows.pkr.hcl* and execute it.

## The build

We need to log in using the Azure CLI.

```bash
$ az login
```

Now we can initialize Packer.

```bash
$ packer init
```

Now execute the build, and don't forget to either set your subscription variable to your subscription or pass it in on the command line. The build should take about 30 minutes with the VM size I have entered. A larger VM will be quicker.

```bash
$ packer build docker-windows.pkr.hcl
```

Once that is complete, you should see a version in your image gallery.

## Conclusion

Now you can use this new image as the base image for creating virtual machines in Azure that you require to have Docker installed. This effort will become helpful for container-based workflows, which I will hopefully demonstrate in a later post.

Thanks for reading,

Jamie
