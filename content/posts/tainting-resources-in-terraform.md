---
title: "Tainting Resources in Terraform"
date: 2020-12-09T20:03:20-05:00
tags:
- Open Source
- Terraform
- HashiCorp
- Azure
---

I am back with another post on another Terraform command that you should know but will not use all that often. Much like the post on [managing individual resources](https://www.phillipsj.net/posts/managing-individual-resources-in-terraform/), we are going to learn about the [taint](https://www.terraform.io/docs/commands/taint.html) command. This comes in handy when you need to force a resource to be destroyed and recreated instead of doing an in-place update. These issues typically occur when a specific change is not allowed without creating a new resource by the underlying platform, and the provider doesn't really handle that scenario very well. If you tainted the resource, it would trigger a destroy, then recreate working around that limitation. Let's jump into a real-world scenario that is a bizarre case, that if you work with Azure, you will run into it. 

## The Scenario

When you deploy an Azure App service, you have to deploy that App Service to an Azure App Service Plan. An Azure App Sevice Plan is basically a virtual machine that hosts your App Service. Azure has this concept of a stamp. These stamps are scale units that map to a cluster of servers. When you deploy an Azure App Service plan, it is assigned to a web stamp associated with the region and resource group that the plan is deployed to. Typically, this isn't super important to the user until you need to move an App Service to a different App Service Plan. Moves are restricted by the web stamp that the App Service Plan is assigned, which means that you can only move an App Service between App Service Plans within the same web stamp and plan type. The only way to ensure that you can reallocate App Services across different plans is to always create them in the same region and resource group. 

You may be asking what this has to do with Terraform. If you change the App Service Plan of an existing App Service in Terraform, it will attempt to move the App Service to the new plan. When it does try to move it, if the new plan isn't in the same web stamp, Azure will error. In this situation, the only way to make that move is to destroy and recreate the App Service in the new web stamp. There is no way to get Terraform to do that quickly unless you leverage the taint command, which forces this behavior. Let's build out this scenario, execute it, then try to make a move. Once the action fails, we will leverage the taint command to get it to run without error.

## Creating the Scenario with Terraform

Let's create a *main.tf* with two resource groups, two App Service Plans, and one App Service.

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

resource "random_pet" "app_name" {
  separator = ""
}

# Resource Groups
resource "azurerm_resource_group" "number_one" {
  name     = "number-one-rg"
  location = "East US"
}


resource "azurerm_resource_group" "number_two" {
  name     = "number-two-rg"
  location = "East US"
}

# App Service Plans
resource "azurerm_app_service_plan" "number_one" {
  name                = "number-one-ap"
  location            = azurerm_resource_group.number_one.location
  resource_group_name = azurerm_resource_group.number_one.name

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service_plan" "number_two" {
  name                = "number-two-ap"
  location            = azurerm_resource_group.number_two.location
  resource_group_name = azurerm_resource_group.number_two.name

  sku {
    tier = "Free"
    size = "F1"
  }
}

# The single app service plan

resource "azurerm_app_service" "main" {
  name                = random_pet.app_name.id
  location            = azurerm_resource_group.number_one.location
  resource_group_name = azurerm_resource_group.number_one.name
  app_service_plan_id = azurerm_app_service_plan.number_one.id
}
```

Now we can apply it, which should create six resources. Our App Service should be on the App Service Plan named *number-one-ap*.

```Bash
$ terraform apply -auto-approve
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
```

Let's now edit our App Service to be on App Service Plan number two named *number-two-ap*.

```HCL
resource "azurerm_app_service" "main" {
  name                = random_pet.app_name.id
  location            = azurerm_resource_group.number_one.location
  resource_group_name = azurerm_resource_group.number_one.name
  app_service_plan_id = azurerm_app_service_plan.number_two.id
}
```

We should now execute a plan to see what is going to happen with the plan change.

```Bash
$ terraform plan
------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # azurerm_app_service.main will be updated in-place
  ~ resource "azurerm_app_service" "main" {}

Plan: 0 to add, 1 to change, 0 to destroy.
```

The plan says that this is going to be an in-place update to the App Service. Let's apply this change.

```Bash
$ terraform apply -auto-approve
Error: web.AppsClient#CreateOrUpdate: Failure sending request: StatusCode=0 -- Original Error: autorest/azure: Service returned an error. Status=<nil> <nil>

  on main.tf line 59, in resource "azurerm_app_service" "main":
  59: resource "azurerm_app_service" "main" {
```

Oh no! We got an error because this would be a move across a web stamp, which isn't allowed. Now we are in this funky place because we just want to make that move. As discussed above, we can leverage the *taint* command to force a destroy and recreate making the move.

```Bash
$ terraform taint azurerm_app_service.main
Resource instance azurerm_app_service.main has been marked as tainted.
```

Let's run a new plan and see what Terraform wants to do.

```Bash
$ terraform plan
------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # azurerm_app_service.main is tainted, so must be replaced
-/+ resource "azurerm_app_service" "main" {}

Plan: 1 to add, 0 to change, 1 to destroy.
```

Great! We have the outcome that we want, and we can apply it.

```Bash
$ terraform apply -auto-approve
Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

If you log into the Azure Portal, you can verify that it was moved to the new App Service Plan.

## Conclusion

After following along, you will now know how to use the *taint* command to force a destroy and recreate when you end up in these odd situations. As far as Azure goes, my general recommendation is to put all of your App Service Plans within a region in the same resource group separate from your other resources. That way, you can quickly move App Services between plans to balance out your resource usage.

Thanks for reading,

Jamie
