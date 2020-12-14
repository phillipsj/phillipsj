---
title: "How to Reconcile Configuration Drift in Terraform"
date: 2020-12-13T14:05:46-05:00
tags:
- Open Source
- Terraform
- HashiCorp
- Microsoft
- Azure
- Cloud
---

Configuration drift can be a big issue when managing systems. Small changes are made, and before anyone knows, the system is configured very differently than what was documented or discussed. Moving to configuration/infrastructure as code assists greatly with having systems configured slightly differently and provides a level of documentation that may not have existed. Some of these tools are stateless, while others maintain some form of state. Terraform is one of these tools that preserve the state of the successfully applied configuration. However, this doesn't prevent changes from occurring outside of Terraform. The next time Terraform is executed, it will detect this drift and try to reconfigure the system to match the Terraform. This wouldn't be an issue unless the manual change was required to fix a bug or an emergency tweak. The good thing is that Terraform offers the **plan** command that will compare the state, code, and current configuration to determine what changes will be required. Let's dive in and learn how to reconcile configuration drift with Terraform using the **plan** command.

## Initial Starting State

We need to start out with a basic configuration. While I will use Azure, this will work with any Terraform provider as the process is the same. We will create a resource group and a storage account with some tags and a specific configuration.

```HCL
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.39.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  tags = {
    environment = "Production"
    Application = "MyApp"
    BillingCode  = "0001"
  }
}


resource "random_pet" "app_name" {
  separator = ""
}

resource "azurerm_resource_group" "main" {
  name     = "${random_pet.app_name.id}-eus-rg"
  location = "East US"
}

resource "azurerm_storage_account" "main" {
  name                     = "${random_pet.app_name.id}eusst"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_kind             = "Storage"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}
```

Let's run **apply** to create these resources.

```Bash
$ terraform apply -auto-approve

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

## Now the Configuration Drift

Let's introduce some configuration drift. We just got a few urgent requests. The accounting department has requested that we updated the billing code on the *MyApp* storage account to be 0002 for a report that has to be updated and turned in within the hour. Security has also called and informed you that an audit returned that you were using TLS 1.0 instead of TLS 1.2, which could cost you a sensitive customer. Finally, you received a notice from Azure that you need to upgrade the storage account to the StorageV2 version. You decide to quickly just perform these in the portal. Here is a script that simulates the changes for you using the Azure CLI, or you can use the portal.

```Bash
$ az storage account update --tags BillingCode=0002 --name <insert name here> --resource-group <insert resource group>
$ az storage account update --min-tls-version TLS1_2 --name <insert name here> --resource-group <insert resource group>
$ az storage account update --set kind=StorageV2 --name <insert name here> --resource-group <insert resource group>
```

Now our current production environment has drifted from our Terraform configuration. 

## Reconciling Configuration Drift in Terraform

Okay, we know that our production configuration has drifted because we had to make some changes quickly, and that was how we chose to do it. You may not always know that drift has occurred, so this is where the **plan** command really helps. Let's run a **plan** to see what Terraform is telling us has drifted.

```Bash
$ terraform plan
------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # azurerm_storage_account.main must be replaced
-/+ resource "azurerm_storage_account" "main" {
      ~ access_tier                      = "Hot" -> (known after apply)
      ~ account_kind                     = "StorageV2" -> "Storage" # forces replacement
    }
    
Plan: 1 to add, 0 to change, 1 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

Wow! Terraform has detected that we made an account kind change, which is one of those changes that force a replacement. Let's fix this first significant issue: update our Terraform to have *StorageV2* as the account kind.

```HCL
resource "azurerm_storage_account" "main" {
  name                     = "${random_pet.app_name.id}eusst"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}
```

With that update, let's rerun our apply.

```Bash
------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # azurerm_storage_account.main will be updated in-place
  ~ resource "azurerm_storage_account" "main" {
        access_tier                    = "Hot"
        account_kind                   = "StorageV2"
        account_replication_type       = "LRS"
        account_tier                   = "Standard"
        is_hns_enabled                 = false
        location                       = "eastus"
      ~ min_tls_version                = "TLS1_2" -> "TLS1_0"
      ~ tags                           = {
          + "Application" = "MyApp"
          - "BillingCode" = "0002" -> "0001"
          + "environment" = "Production"
        }

    }

Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

This is much better as we now have just changes that need to occur. Those changes are the tag for the *BilingCode* and the TLS version. Let's update the TLS version first.

```HCL
resource "azurerm_storage_account" "main" {
  name                     = "${random_pet.app_name.id}eusst"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = local.tags
}
```

Once again, let's run a plan.

```Bash
------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # azurerm_storage_account.main will be updated in-place
  ~ resource "azurerm_storage_account" "main" {
        access_tier                    = "Hot"
        account_kind                   = "StorageV2"
        account_replication_type       = "LRS"
        account_tier                   = "Standard"
        is_hns_enabled                 = false
        location                       = "eastus"
        min_tls_version                = "TLS1_2"
      ~ tags                           = {
          + "Application" = "MyApp"
          - "BillingCode" = "0002" -> "0001"
          + "environment" = "Production"
        }

    }

Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

One last change to handle. We should update our global tags to update the *BillingCode*.

```HCL
locals {
  tags = {
    environment = "Production"
    Application = "MyApp"
    BilingCode  = "0002"
  }
}

resource "azurerm_storage_account" "main" {
  name                     = "${random_pet.app_name.id}eusst"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = local.tags
}
```

Let's run what we hope will be the last **plan** command.

```Bash
$ terraform plan
------------------------------------------------------------------------

No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and the real physical resources that exist. As a result, no
actions need to be performed.
```

This time the plan doesn't show any changes that need to be applied. This means that we got our Terraform file synced with our production environment. However, we are not finished. We need to run an **apply** to ensure that our state is updated with the changes.

```Bash
$ terraform apply

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

That's it. Our Terraform file and state are now aligned with all the manual changes that had to be made.

## Conclusion 

I hope you find this helpful. This is the process that I follow to bring everything back in alignment. It is a constant cycle of *plan --> chance --> plan --> change* until the plan returns either no changes or a limited set of changes that I expect. Once I get that resolved, I run an apply to get everything squared up with the state.

Thanks for reading,

Jamie
