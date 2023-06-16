---
title: "Azure App Service Certificate and Terraform"
date: 2023-06-15T21:24:53-04:00
tags: 
- Open Source
- OSS
- Terraform
- HashiCorp
- Azure
- Microsoft Azure
- Azure App Service
- AzAPI Provider
- AzureRM Provider
- SSL Certificate
- Azure App Service Certificate
- Azure Key Vault
---

I recently ran across an interesting issue with using Terraform to load an existing SSL certificate located in a key vault not in the same subscription or resource group to an Azure App Service. Here is an example of what was being used.

```HCL
resource "azurerm_app_service_certificate" "main" {
  name                = "test-eus-cert"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  key_vault_secret_id = "<key vault secret id>"
}
```

Here is the error I was receiving.

```
Unable to determine the Resource ID for the Key Vault at URL...
```

## Problem

After some digging, I discovered this [GitHub issue](https://github.com/hashicorp/terraform-provider-azurerm/issues/10824). The issue is that how the [AzureRM provider](https://registry.terraform.io/providers/hashicorp/azurerm/3.61.0) for Terraform works, it doesn't pass the key vault ID along with the secret. This causes it to search in the resource group and subscription where the app service is located which isn't the location of the key vault that I want to use. This could be fixed in the AzureRM provider as suggested in the issue it just hasn't yet. The common solution to solve the issue is to load the certificate manually and then the Terraform can run and resolve everything once it has been configured. That isn't great for automation as it requires that manual step to happen. I decided that I could work around this issue using just Terraform. Let's see what I came up with.

## Solution

The GitHub issue above describes exactly what needs to happen to resolve the issue. I decided that I would look into how to solve this using an [ARM template](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/overview) through the [ARM template resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) then I remembered that the [AzAPI provider](https://registry.terraform.io/providers/Azure/azapi/1.6.0) exists that can do just exactly what I needed to do since it just uses the REST API. After looking at a few examples I was able to create the app service certificate by referencing the key vault id and secret which is provided in the list of properties. 

Let's see what the resource is going to look like.

```HCL
resource "azapi_resource" "app_service_certificate" {
  type      = "Microsoft.Web/certificates@2022-03-01"
  name      = "test-eus-cert"
  parent_id = azurerm_resource_group.main.id
  location  = azurerm_resource_group.main.location
  
  body = jsonencode({
    properties = {
      keyVaultId         = "<key vault id>"
      keyVaultSecretName = "<key vault secret name>"
      serverFarmId       = azurerm_linux_web_app.main.id
    }
    kind = "string"
  })

  response_export_values = ["properties.thumbprint"]
}
```

Notice that we send the properties that are required for it to load the certificate which includes the key vault id. The other thing to note is the exporting of the thumbprint property which is needed by the app service binding resource.

Here is a complete example demonstrating how to use it.

```HCL
terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "1.6.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.61.0"
    }
  }
}

provider "azapi" {}

provider "azurerm" {}

resource "azurerm_resource_group" "main" {
  name     = "test-eus-rg"
  location = "East US"
}

resource "azurerm_service_plan" "main" {
  name                = "test-eus-asp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "main" {
  name                = "test-eus-app"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {}
}

resource "azapi_resource" "app_service_certificate" {
  type      = "Microsoft.Web/certificates@2022-03-01"
  name      = "test-eus-cert"
  parent_id = azurerm_resource_group.main.id
  location  = azurerm_resource_group.main.location
  
  body = jsonencode({
    properties = {
      keyVaultId         = "<key vault id>"
      keyVaultSecretName = "<key vault secret name>"
      serverFarmId       = azurerm_linux_web_app.main.id
    }
    kind = "string"
  })

  response_export_values = ["properties.thumbprint"]
}

resource "azurerm_app_service_custom_hostname_binding" "main" {
  hostname            = "<insert hostname>"
  app_service_name    = azurerm_linux_web_app.main.name
  resource_group_name = azurerm_resource_group.main.name
  ssl_state           = "SniEnabled"
  thumbprint          = jsondecode(azapi_resource.app_service_certificate.output).properties.thumbprint
}
```

## Wrapping Up

I hope someone finds this useful and that it helps them work through limitations and cases in which the AzureRM provider just doesn't work or behave as desired. In the past, I would just use the ARM template resource, however, with the AzAPI provider, I feel it provides a cleaner approach.

Thanks for reading,

Jamie