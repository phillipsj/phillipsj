---
Title: "Tips when using the Azure ARM resource in Terraform"
Published: 12/05/2018 21:51:18
Tags: 
- Open Source
- PowerShell
- Azure
- Microsoft
- Terraform
---
# Tips when using the Azure ARM resource in Terraform

[Terraform](https://www.terraform.io) is a great tool, occasionally you will run into instances where what you are trying to do isn't supported yet by the Azure provider. When a feature isn't supported you can always fall back to using the [PowerShell module](https://docs.microsoft.com/en-us/powershell/azure/overview?view=azurermps-6.13.0) or the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) as I outlined in this [post](https://www.phillipsj.net/posts/how-to-handle-unsupported-azure-features-in-terraform). There are times that those options don't really do what you are needed. When those cases arise, don't forget that Terraform does have the [Azure ARM Template Resource](https://www.terraform.io/docs/providers/azurerm/r/template_deployment.html) that can be used to execute an [ARM template](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates) that can do what you need. Using the template itself isn't as bad if you are used to using or types of templates in Terraform. Here are a few tips and tricks that can help you have more success. All the code can be found in this [repo](https://github.com/BlueGhostLabs/terraform-azure-samples) that I will be updating with more examples and modules as I have the time. The code of interest in that repo is located in the *tf-arm* directory in the examples directory. Okay, let's get started.

## Create a main.tf

The first thing we need to do is create our *main.tf*.

```Bash
$ touch main.tf
```

Now open that file and let's add our provider and resources.

```HCL
provider "azurerm" {
    version = "~>1.19"
}

resource "azurerm_resource_group" "main" {
}

resource "azurerm_template_deployment" "main" {
}
```

Okay, now that we have the basics let's add our name and location for our resource group.

```HCL
provider "azurerm" {
    version = "~>1.19"
}

resource "azurerm_resource_group" "main" {
      name     = "MyApp-RG"
      location = "East US"
}

resource "azurerm_template_deployment" "main" {
}
```

Now let's add the name, resource group, and deployment model for our ARM template resource.

```HCL
provider "azurerm" {
    version = "~>1.19"
}

resource "azurerm_resource_group" "main" {
      name     = "MyApp-RG"
      location = "East US"
}

resource "azurerm_template_deployment" "main" {
      name                = "MyApp-ARM"
      resource_group_name = "${azurerm_resource_group.main.name}"

      deployment_mode = "Incremental"
}
```

### Moving the ARM template of Terraform file

This is the first tip that will make your life easier and make your Terraform template much cleaner. The example on the Terraform website shows that ARM template inline, which works great for scripts that are a few lines, that isn't ARM templates.

Let's create our ARM template and put it in a directory to make it a little more organized.

```Bash
$ mkdir arm && cd $_
$ touch azuredeploy.json
```

Now that we have an ARM template created, let's reference that in our Terraform template.

```HCL
provider "azurerm" {
    version = "~>1.19"
}

resource "azurerm_resource_group" "main" {
      name     = "MyApp-RG"
      location = "East US"
}

resource "azurerm_template_deployment" "main" {
      name                = "MyApp-ARM"
      resource_group_name = "${azurerm_resource_group.main.name}"
      
      template_body = "${file("arm/azuredeploy.json")}"

      deployment_mode = "Incremental"
}
```

The template body section now uses the [file](https://www.terraform.io/docs/configuration/interpolation.html#file-path-) function to load the ARM template. You can use relative or absolute file paths and there are some guidelines on other helper functions.

Now, this example is great if your ARM template is static or doesn't need any inputs. I bet that your templates probably do. If that is the case keep reading.

## Passing parameters to ARM templates

Passing parameters is actually fairly straight-forward. You just put in a parameters block like the Terraform documentation, however, if you have an ARM parameter of type *array* then things get interesting. Most items in Terraform are strings and it seems to show here.

With parameter types of *array* proving challenging, of course, that is what I am going to cover. If you happen to know of a better way, please let me know.

The first step is to add a variable to our Terraform template that will represent our *list* item. I called it *myList* and gave it three items.

```HCL
provider "azurerm" {
    version = "~>1.19"
}

variable "myList" {
    type = "list"
    default = ["a", "b", "c"]
}

resource "azurerm_resource_group" "main" {
      name     = "MyApp-RG"
      location = "East US"
}

resource "azurerm_template_deployment" "main" {
      name                = "MyApp-ARM"
      resource_group_name = "${azurerm_resource_group.main.name}"
      
      template_body = "${file("arm/azuredeploy.json")}"

      deployment_mode = "Incremental"
}
```

Now that we have a variable to represent our list, let's add our parameter block in our Terraform template.

```HCL
provider "azurerm" {
    version = "~>1.19"
}

variable "myList" {
    type = "list"
    default = ["a", "b", "c"]
}

resource "azurerm_resource_group" "main" {
      name     = "MyApp-RG"
      location = "East US"
}

resource "azurerm_template_deployment" "main" {
      name                = "MyApp-ARM"
      resource_group_name = "${azurerm_resource_group.main.name}"
      
      template_body = "${file("arm/azuredeploy.json")}"
      
      parameters {
        "myList" = "${join(",", var.myList)}"
      }
      
      deployment_mode = "Incremental"
}
```

You can see that I added a parameter called *myList* and then you can see that I am using the [join](https://www.terraform.io/docs/configuration/interpolation.html#join-delim-list-) function to convert that to a string of comma separated values. Now you are saying, but Jamie I wanted an array. Ah, well we are not finished. Let's change gears and create a really simple ARM template in our *azuredeploy.json* file.

```JSON
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "myList": {
            "type": "string",
            "metadata": {
                "description": "The list of comma separated items."
            }
        }
    },
    "resources": []
}
```

So we have a parameter that was added of type string that takes in our comma-separated list. Now to convert that to an *array* type, let's add a *variables* section to our ARM template.

```JSON
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "myList": {
            "type": "string",
            "metadata": {
                "description": "The list of comma separated items."
            }
        }
    },
    "variables": {
        "myArray": "[split(parameters('myList'),',')]"
    },
    "resources": []
}
```

Now you can see that we created a variable called *myArray* that takes the *myList* parameter and using the [split](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-string#split) function to convert it to an *array*. Now you can avoid doing some weird gymnastics in Terraform to get a *list* to pass into an *array* parameter type.

## Conclusion

This took a little time to get worked out and I hope this saves you some time. I know I will be referencing this in the future. In addition to this just being useful, a much longer post is coming that will show how I put this technique to use to make a pretty complex script.