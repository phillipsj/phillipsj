---
Title: "How to handle unsupported Azure features in Terraform"
date: 2018-09-22T21:26:39
Tags: 
- Open Source
- Terraform
- HashiCorp
- Microsoft
- Azure
- Cloud
---
# How to hanlde unsupported Azure features in Terraform

I am a big fan and user of [Terraform](https://www.terraform.io/). I have been using it for almost a year now with both Azure and AWS clouds. While it isn't a *write once, run everywhere* tool, it is a tool that provides a consistent workflow and language for creating infrastructure that is independent of a specific vendor. However, the one big issue with any *third-party* tool is that new features may not always be available right away. With that said, Terraform had day zero support for both Kubernetes on Azure and Kubernetes on AWS, which I assume is because both Microsoft and Amazon worked closely with them to make sure it was possible.

Now that you have a little intro, how do you go about supporting features within Terraform that isn't supported in the provider. Initially, I believed that I would need to create a wrapper script that would wrap my terraform execution, then follow up using the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) or PowerShell commandlets to do the extra processing. While that is one way to solve the issue, that puts the logic in both Terraform and the wrapper script. This can be confusing with multiple team members and it would be nice if this was all in the Terraform template. Well, I have discoverd that it all can be located in the template. There are a few different ways of achieving the goal, but I am going to show one of the more basic ways.

For the example, we are going to create an Azure App Service using Terraform. There is support for adding a custom domain name, however there isn't support for adding your SSL certificate. We are going to use a technique in Terraform that will allow you to use the Azure CLI to add the SSL certificate.

Okay, lets get started. First step is add the creation of the Azure App Service to the Terraform file.

```HCL
resource "azurerm_resource_group" "demo" {
  name     = "demo-resource-group"
  location = "East US"
}

resource "azurerm_app_service_plan" "demo" {
  name                = "demo-app-service-plan"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "demo" {
  name                = "demo-app-service"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  app_service_plan_id = "${azurerm_app_service_plan.demo.id}"
}
```

Now after the *azurerum_app_service* resouce add the custom domain name.

```HCL
resource "azurerm_app_service_custom_hostname_binding" "demo" {
  hostname            = "demo.website.com"
  app_service_name    = "${azurerm_app_service.demo.name}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
}
```

Now that we have the basics in place, we can add the step that adds the SSL certificate to the App Service.

Terraform has a resource call a [null_resource](https://www.terraform.io/docs/providers/null/resource.html). We are going to use the *null_resource* with a [local-exec](https://www.terraform.io/docs/provisioners/local-exec.html) provisioner that will execute the necessary Azure CLI commands. The last piece is to make sure to add the [depends_on](https://www.terraform.io/intro/getting-started/dependencies.html#implicit-and-explicit-dependencies) attribute to link it to the domain name getting added so that everything gets created in the correct order.

```HCL
resource "null_resource" "azure-cli" {
  
  provisioner "local-exec" {
    # Call Azure CLI Script here
    command = "ssl-script.sh"

    # We are going to pass in terraform derived values to the script
    environment {
      webappname = "${azurerm_app_service.demo.name}"
      resourceGroup = ${azurerm_resource_group.demo.name}
    }
  }

  depends_on = ["azurerm_app_service_custom_hostname_binding.demo"]
}
```

Now that we have this added to our Terraform template, let's create the Bash script we are going to execute. Luckily, we can grab what we need from [here](https://docs.microsoft.com/en-us/azure/app-service/scripts/app-service-cli-configure-ssl-certificate). Note that I hard coded a password and SSL certificate path. The can be passed in from Terraform environment variables like the names are or it can be pulled from environment variables. I do not recommend hard coding.

Add the below to a file called *ssl-script.sh*.

```Bash
#!/bin/bash

# Upload the SSL certificate and get the thumbprint.
thumbprint=$(az webapp config ssl upload --certificate-file /my.cert \
--certificate-password myPassword --name $webappname --resource-group $resourceGroup \
--query thumbprint --output tsv)

# Binds the uploaded SSL certificate to the web app.
az webapp config ssl bind --certificate-thumbprint $thumbprint --ssl-type SNI \
--name $webappname --resource-group $resourceGroup
```

Here is what the complete Terraform template will look like:

```HCL
provider "azurerm" { }

resource "azurerm_resource_group" "demo" {
  name     = "demo-resource-group"
  location = "East US"
}

resource "azurerm_app_service_plan" "demo" {
  name                = "demo-app-service-plan"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "demo" {
  name                = "demo-app-service"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  app_service_plan_id = "${azurerm_app_service_plan.demo.id}"
}

resource "azurerm_app_service_custom_hostname_binding" "demo" {
  hostname            = "demo.website.com"
  app_service_name    = "${azurerm_app_service.demo.name}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
}

resource "null_resource" "azure-cli" {
  
  provisioner "local-exec" {
    # Call Azure CLI Script here
    command = "ssl-script.sh"

    # We are going to pass in terraform derived values to the script
    environment {
      webappname = "${azurerm_app_service.demo.name}"
      resourceGroup = ${azurerm_resource_group.demo.name}
    }
  }

  depends_on = ["azurerm_app_service_custom_hostname_binding.demo"]
}
```

That is it, it may seem a little like a hack, but it gets the job done until the functionality is added natively to Terraform.

Thanks for reading.
