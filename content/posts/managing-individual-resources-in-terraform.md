---
title: "Managing Individual Resources in Terraform"
date: 2020-12-07T21:40:39-05:00
tags:
- Open Source
- Terraform
- HashiCorp
---

There is some nuance in working with Terraform, and many of the commands support more advanced usage. Typically, we end up just using the commands without many options since they cover most of the use cases. There are those times when you need to be more granular when destroying and applying new resources. There are times when the change you want to make will fail due to an underlying platform limitation, so allowing the natural destroy and replace that Terraform performs may not work. In those cases, you may want to destroy a specific resource by hand, then just run the apply as usual. There are other times that you are building out some new capabilities, and you may not be able to only run the apply command generically because you may need to stage some data. In those cases, applying a single resource before applying everything may be required. With those set, let's create some infrastructure and walk through just targeting individual resources for destroying and applying.

## The Example

Let's create a *main.tf*, and we are going to make the following Azure resources. Don't worry, as these resources do not have any cost associated with just creating them.

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

resource "random_pet" "storage" {
  separator = ""
}

resource "azurerm_resource_group" "main" {
  name     = "main"
  location = "East US"
}

resource "azurerm_storage_account" "main" {
  name                     = random_pet.storage.id
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "photos" {
  name                  = "photos"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "documents" {
  name                  = "documents"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "backups" {
  name                  = "backups"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
```

Here we have just a resource group, storage account, and three blob containers. We will use those to just practice performing different scenarios. We can go ahead and just create them all, and we will start with targeting a unique resource for destroying.

```Bash
$ terraform apply 

Plan: 6 to add, 0 to change, 0 to destroy.

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
```

## Destroying a Single Resource

Now let's say that we have discovered an issue that prevents us from changing a setting in our *documents* container. If we were to run an apply with the change we want to make, the platform prevents its due to a platform bug. Well, we can destroy the container as is and then run our apply to create it new.

If you look at the official [destroy](https://www.terraform.io/docs/commands/destroy.html) command docs, you will see that one of the options is **target**. What we can do with that is run the destroy command and pass the name of the resource to the target option to just destroy that individual resource. Let's give it a try.

```Bash
$ terraform destroy -target=azurerm_storage_container.documents
Refreshing state...
Plan: 0 to add, 0 to change, 1 to destroy.


Warning: Resource targeting is in effect

You are creating a plan with the -target option, which means that the result
of this plan may not represent all of the changes requested by the current
configuration.

The -target option is not for routine use and is provided only for
exceptional situations such as recovering from errors or mistakes, or when
Terraform specifically suggests to use it as part of an error message.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_storage_container.documents: Destroying... 
azurerm_storage_container.documents: Destruction complete after 1s

Warning: Applied changes may be incomplete

The plan was created with the -target option in effect, so some changes
requested in the configuration may have been ignored, and the output values may
not be fully updated. Run the following command to verify that no other
changes are pending:
    terraform plan

Note that the -target option is not suitable for routine use, and is provided
only for exceptional situations such as recovering from errors or mistakes, or
when Terraform specifically suggests to use it as part of an error message.


Destroy complete! Resources: 1 destroyed.
```

Great! It destroyed the one resource that we needed to destroy. Notice that it output a warning telling us the changes are incomplete and executing it with a target. Then it talks about that it's mainly for exceptional situations. If we had done this with the storage account, it would have told us before we approved it that it would delete more than just one of the resources because they are dependent. With that said, always double-check what you expect to happen with what it reports before approving.

Let's destroy everything and start from scratch before we move to the next one.

```Bash
$ terraform destroy 

Destroy complete! Resources: 5 destroyed.
```

To verify again, we destroyed 5 resources, not 6, because we had already destroyed a single one before.

## Applying a Single Resource

We now know how to destroy a single resource. Let's create one. I ran into this exact scenario this week. I ended up in a circular situation that required me to seed some data. After a little thinking, I realized that I could just pre-stage the resources to upload the data before applying the whole Terraform template. Just like the above, this technique is typically used in exceptional situations. This scenario wouldn't exist if I created everything from scratch; you have to use these lesser-traveled paths when working with existing resources.

We will create our *backups* container as required before our other containers need to be made. We will run *apply* again, passing in the **target** option. Since our random name, resource group, storage account, and container do not exist, I would expect four resources to be created. Remember, it will handle dependencies when running targets.

```Bash
terraform apply -target=azurerm_storage_container.backups  

Plan: 4 to add, 0 to change, 0 to destroy.

Warning: Resource targeting is in effect

You are creating a plan with the -target option, which means that the result
of this plan may not represent all of the changes requested by the current
configuration.

The -target option is not for routine use, and is provided only for
exceptional situations such as recovering from errors or mistakes, or when
Terraform specifically suggests to use it as part of an error message.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

Warning: Applied changes may be incomplete

The plan was created with the -target option in effect, so some changes
requested in the configuration may have been ignored and the output values may
not be fully updated. Run the following command to verify that no other
changes are pending:
    terraform plan

Note that the -target option is not suitable for routine use, and is provided
only for exceptional situations such as recovering from errors or mistakes, or
when Terraform specifically suggests to use it as part of an error message.


Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

Notice we are warned again and that the 4 resources that we expected to be created were created. This was a rare occurrence to target an apply. I think this may have been the first time I have had to do it. I am glad that I could. Don't forget to clean up after practicing these commands.

```Bash
$ terraform destroy 

Destroy complete! Resources: 5 destroyed.
```

## Conclusion

Most advanced features in Terraform are for exceptional situations, and that's why it is good to practice using them. You will come across cases when you need to leverage these features, so practicing them and becoming comfortable with them will help you in the future. You can also target a resource with the **plan** command, so keep that in mind if you prefer to run a plan before applying.

Thanks for reading,

Jamie
