---
title: "Terraform: Using Null and Dynamic Blocks with Azure VMs"
date: 2021-05-03T21:20:47-04:00
tags:
- Open Source
- Terraform
- HashiCorp
- Azure
- Dynamic Blocks
---

I have been doing some work creating a module for creating a Windows VM in Azure. I wanted the ability to allow the user to use the [source_image_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine#source_image_id) or [source_image_reference](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine#source_image_reference). You can't set both, so I needed a way to switch between the two different options. In Terraform 0.12, the [null](https://www.terraform.io/docs/language/expressions/types.html#null) type was introduced. The *null* type marks the property/attribute as being omitted or absent. If I set the variable's default value for the *source_image_id* to *null*, it will be omitted if not set. Here is what that would look like used in a variable.

```HCL
variable "image_id" {
    type        = string
    default     = null
}
```

As far as the *source_image_reference*, we will check to see if the *image_id* variable is *null*. If it's *null*, we will use a [dynamic block](https://www.terraform.io/docs/language/expressions/dynamic-blocks.html) to add the *source_image_reference* block to the VM. This block will also handle if a user tries to configure both as it will always use the *source_image_id*. Let's define the variable we are going to use for the *source_image_reference*.

```HCL
variable "image_info" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null
}
```

Now that we have variables defined, we can see them in action in the VM resource.

```HCL
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "myvm"
  resource_group_name = "<resource-group-name>"
  location            = "<resource-group-location>"
  size                = "Standard_A1_v2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    "<network-id>",
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = var.image_id

  dynamic "source_image_reference" {
    for_each = var.image_id == null ? list(1) : []
    content {
      publisher = var.image_info.publisher
      offer     = var.image_info.offer
      sku       = var.image_info.sku
      version   = var.image_info.version
    }
  }
}
```

If *image_id* is set to *null* then the *source_image_id* will not be set. When we get to the dynamic block, if the *image_id* is *null*, then we make a single item list that we can loop over. When we loop over then, we can set the values for the *source_image_reference*. These features will allow our module to handle setting either option for defining the image to use.

## Conclusion

There are plenty of new features introduced with the latest versions of Terraform that can help make your modules more flexible. It's a little tough to discover them and then leverage them in your solutions. I hope this helps provide some guidance on how to use these features.

Thanks for reading,

Jamie
