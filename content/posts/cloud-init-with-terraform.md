---
title: "Cloud-Init With Terraform"
date: 2021-01-25T19:42:07-05:00
tags:
- Open Source
- Terraform
- HashiCorp
- Linux
- Linode
- Cloud-Init
---

Did you know that you could use [cloud-init](https://cloud-init.io/) with Terraform? I didn't realize until recently. No, I am not talking about a template and passing it via user data, but defining a cloud-init template in Terraform. Let's get into it.

## The Plan

Pick your favorite cloud provider to try this, as all you need is a Linux VM. I will be using Azure to spin up an Ubuntu server and apply a cloud-init template. I will have cloud-init install the tool [HTTPie](https://httpie.io/).

## Initial Terraform

We are going to get started like we always do by defining a Terraform block and our provider.

```HCL
terraform {
  required_version = ">= 0.14.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.44.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

I am using the Azure CLI to login and set my subscription.

## Define our VM

Let's now create our VM.

```HCL
resource "azurerm_resource_group" "cloudinit" {
  name     = "cloudinit-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "cloudinit" {
  name                = "cloudinit-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.cloudinit.location
  resource_group_name = azurerm_resource_group.cloudinit.name
}

resource "azurerm_subnet" "cloudinit" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.cloudinit.name
  virtual_network_name = azurerm_virtual_network.cloudinit.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "cloudinit" {
  name                = "cloudinit-pip"
  location            = azurerm_resource_group.cloudinit.location
  resource_group_name = azurerm_resource_group.cloudinit.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "cloudinit" {
  name                = "cloudinit-sg"
  location            = azurerm_resource_group.cloudinit.location
  resource_group_name = azurerm_resource_group.cloudinit.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "cloudinit" {
  name                = "cloudinit-nic"
  location            = azurerm_resource_group.cloudinit.location
  resource_group_name = azurerm_resource_group.cloudinit.name

  ip_configuration {
    name                          = "cloudinit-nic-config"
    subnet_id                     = azurerm_subnet.cloudinit.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.cloudinit.id
  }
}

resource "azurerm_network_interface_security_group_association" "cloudinit" {
  network_interface_id      = azurerm_network_interface.cloudinit.id
  network_security_group_id = azurerm_network_security_group.cloudinit.id
}

resource "azurerm_linux_virtual_machine" "cloudinit" {
  name                = "cloudinit-machine"
  resource_group_name = azurerm_resource_group.cloudinit.name
  location            = azurerm_resource_group.cloudinit.location
  size                = "Standard_B1s"
  admin_username      = "cloudinit"
  admin_password      = "HKKRoD24XLBzxdD"


  # This is where we pass our cloud-init.
  custom_data = ""

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.cloudinit.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

output "public_ip" {
  value = azurerm_linux_virtual_machine.cloudinit.public_ip_address
}
```

## Creating our cloud-init

The resource documentation can be found [here](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config). We are going to create this in our Terraform after the provider since it is a data block, and that is the convention that I use.

```HCL
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content      = "packages: ['httpie']"
  }
}
```

Now we can go back to our VM resource and pass that to the *custom_data* property.

```HCL
resource "azurerm_linux_virtual_machine" "cloudinit" {
  name                = "cloudinit-machine"
  resource_group_name = azurerm_resource_group.cloudinit.name
  location            = azurerm_resource_group.cloudinit.location
  size                = "Standard_B1s"
  admin_username      = "cloudinit"
  admin_password      = "HKKRoD24XLBzxdD"


  # This is where we pass our cloud-init.
  custom_data = data.template_cloudinit_config.config.rendered

  disable_password_authentication = false
  
  # Abbreviated
}
```

That's it, and we can now execute it.

## Creating and validating the VM

Time to initialize our Terraform and apply.

```Bash
$ terraform init
Terraform has been successfully initialized!

$ terraform apply -auto-approve
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.
```

With our VM created successfully, we can use the Azure CLI to check to see if it has a status of running.

```Bash
$ az vm get-instance-view /
   -n cloudinit-machine /
   -g cloudinit-resources /
   --query instanceView.statuses[1] /
   -o table
   
Code                Level    DisplayStatus
------------------  -------  ---------------
PowerState/running  Info     VM running
```

Once the status reports that it's running, we need to ssh into the server and verify the *HTTPie* installation. We will need the public ip of the instance, which we can get from Terraform.

```Bash
$ terraform output publc_ip
"XX.XX.XXX.XXX"
```

Now we can SSH in and check HTTPie.

```Bash
$ ssh cloudinit@XX.XX.XXX.XXX

$ cloudinit@cloudinit-machine:~$ http --version
0.9.8

$ cloudinit@cloudinit-machine:~$ exit
logout
Connection to XX.XX.XXX.XXX closed.
```

## Conclusion

That's it; that is how you use cloud-init to configure your VM upon creation. Don't forget to clean up your resources.

Thanks for reading,

Jamie
