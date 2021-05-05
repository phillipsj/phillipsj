---
title: "Use an Azure VM Script Extension to Run a Container"
date: 2021-05-04T19:39:12-04:00
tags:
- Open Source
- PowerShell
- Microsoft
- Containers
- Windows Containers
- Azure
- Terraform
---

Windows Server doesn't support anything like [cloud-init](https://cloud-init.io/) for executing commands when building the server. Yes, there are other mechanisms that can be used. Yet those are difficult to leverage. Microsft makes an image in Azure called *Windows Server 2019 with Containers* that comes with Docker EE preinstalled so that solves that one hurdle. The next is how to execute a Docker *run* command. We can leverage the [Custom Script Extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows) for VMs in Azure to execute a PowerShell script that will make sure that Docker is running, it isn't by default, and if it isn't start the service. Once Docker is running we will execute our Docker *run* command.  The script will take our Docker command as an argument. Here is the script.

```PowerShell
[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $Command
)

if (Get-Service 'Docker' -ErrorAction SilentlyContinue) {
    if ((Get-Service Docker).Status -ne 'Running') { Start-Service Docker }
    while ((Get-Service Docker).Status -ne 'Running') { Start-Sleep -s 5 }

    Start-Process -NoNewWindow -FilePath "docker.exe" -ArgumentList "$($Command)"
    exit 0
}
else {
    Write-Host "Docker Service was not found!"
    exit 1
}
```

This script will need to be available for downloading by the script extension. I already have it available as a gist [here](https://gist.githubusercontent.com/phillipsj/7f5b012e8107c7d95f00bf3fbe261116/raw/7134abb33aa78c2856e77af3dc74e6ee798177dc/init.ps1).

Now the script extension can be defined in Terraform. This can easily be translated to an ARM template if needed. The key is the *commandToExecute* to 

```HCL
resource "azurerm_virtual_machine_extension" "init" {
  name                 = "init"
  virtual_machine_id   = ""
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "fileUris": ["https://gist.githubusercontent.com/phillipsj/7f5b012e8107c7d95f00bf3fbe261116/raw/7134abb33aa78c2856e77af3dc74e6ee798177dc/init.ps1"],
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File init.ps1 -Command '${var.docker_cmd}'",
    }
SETTINGS

}
```

Now we can put this all together in the Terraform file to execute it. Make note that we are defining a variable that has the Docker command we want to execute.

```HCL
terraform {
  required_version = "~> 0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.56"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "docker_cmd" {
  type    = string
  default = "run -d mcr.microsoft.com/windows/nanoserver:1809 ping -t localhost"
}

resource "azurerm_resource_group" "extension" {
  name     = "extension-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "extension" {
  name                = "extension-net"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.extension.location
  resource_group_name = azurerm_resource_group.extension.name
}

resource "azurerm_subnet" "extension" {
  name                 = "extension-sub"
  resource_group_name  = azurerm_resource_group.extension.name
  virtual_network_name = azurerm_virtual_network.extension.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "random_pet" "my_name" {
  length = 2
}

resource "azurerm_public_ip" "extension" {
  name                = "extension-pip"
  resource_group_name = azurerm_resource_group.extension.name
  location            = azurerm_resource_group.extension.location
  allocation_method   = "Dynamic"
  domain_name_label   = random_pet.my_name.id
}

resource "azurerm_network_interface" "extension" {
  name                = "extension-nic"
  location            = azurerm_resource_group.extension.location
  resource_group_name = azurerm_resource_group.extension.name

  ip_configuration {
    name                          = "Primary"
    subnet_id                     = azurerm_subnet.extension.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.extension.id
  }
}

resource "azurerm_windows_virtual_machine" "extension" {
  name                = random_pet.my_name.id
  computer_name       = random_pet.my_name.id
  resource_group_name = azurerm_resource_group.extension.name
  location            = azurerm_resource_group.extension.location
  size                = "Standard_A1_v2"
  admin_username      = "adminuser"
  admin_password      = "jG8R66LmGsGdW!"

  network_interface_ids = [
    azurerm_network_interface.extension.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-with-Containers"
    version   = "17763.1879.2104151558"
  }
}

resource "azurerm_virtual_machine_extension" "init" {
  name                 = "init"
  virtual_machine_id   = azurerm_windows_virtual_machine.extension.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "fileUris": ["https://gist.githubusercontent.com/phillipsj/7f5b012e8107c7d95f00bf3fbe261116/raw/7134abb33aa78c2856e77af3dc74e6ee798177dc/init.ps1"],
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File init.ps1 -Command '${var.docker_cmd}'"
    }
SETTINGS

}
```

After that is complete, we can log into the server and see if our container is running.

```Bash
$ docker ps
CONTAINER ID        IMAGE                                       COMMAND               CREATED             STATUS              PORTS               NAMES
8ed6689cedae        mcr.microsoft.com/windows/nanoserver:1809   "ping -t localhost"   9 seconds ago       Up 4 seconds                            objective_goldberg
```

