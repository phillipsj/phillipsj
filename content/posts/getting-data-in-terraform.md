---
title: "Getting Data in Terraform"
date: 2020-03-09T20:54:59-04:00
tags:
- Open Source
- Terraform
- HashiCorp
---

After my post on [discussing Terraform backends](https://www.phillipsj.net/posts/discussion-of-terraform-backends/), someone asked if I could do a post on the topic of accessing data in your remote state. I thought that was an excellent idea, and here I am writing a post that will discuss that and access other data. Luckily in Terraform, both of those use the same concept, which is a [data source](https://www.terraform.io/docs/configuration/data-sources.html). A data source is a particular type of resource that can query external sources and return data. Most providers in Terraform have data sources that allow retrieving data from the target of the provider, and an example would be the data sources in the Azure Provider that allows querying an Azure subscription for all kinds of data about resources in Azure. Now let's dive into the differences between data sources from providers and the one for the remote state.

## Data Sources from providers

Let's take a look at the data source for [Azure Resource Group](https://www.terraform.io/docs/providers/azurerm/d/resource_group.html). If you want to know what you can retrieve, look at the [Attribute Reference](https://www.terraform.io/docs/providers/azurerm/d/resource_group.html#attributes-reference) section. It lists that you can retrieve the **id**, **location**, and **tags** using it. All data sources have the list of returned attributes for referencing in other parts of your Terraform. You then can use that resource like any other resource in Terraform. Here is an example of how to use it.

```hcl
data "azurerm_resource_group" "my_rg" {
  name = "my_resource_group"
}

resource "azurerm_storage_account" "my_st" {
  name                     = "mystorageaccount"
  resource_group_name      = data.azurerm_resource_group.my_rg.name
  location                 = data.azurerm_resource_group.my_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = data.azurerm_resource_group.my_rg.tags
}
```

That's all there is to use this type. Now lets' discuss data source for the remote state.

## Data Source for remote state

Overall, this data source works similarly to the data sources found in the providers. The most significant difference is that you will need to plan and make sure that you define any data that you want to retrieve from the remote state as a root-level [output](https://www.terraform.io/docs/configuration/outputs.html). You may be asking, "What is a root-level output?". That is an output that exists in the outputs of a Terraform template that creates the state. This requirement means that if a module outputs data, then you would have to define an output in your template that reads the module output and returns it as a new output. I like this explicitness as it tightly controls what data someone could get access to in your remote state. Let's look at what this looks like in Terraform.

### Root-level outputs

```hcl
resource "azurerm_app_service" "my_app_service" {
  name                = "my-app-service"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  app_service_plan_id = azurerm_app_service_plan.my_rg.id
}

output "site_hostname" {
  value = azurerm_app_service.my_app_service.default_site_hostname 
}
```

Now let's see an example leveraging a module and creating a root-level output.

```hcl
module "my_module" {
  source = "../my_module"
}

output "my_output" {
  value = module.my_module.my_output
}
```

## Conclusion

There you go, a quick intro to data sources in Terraform. I just showed you a few examples using the more obvious ones. There are over 100+ providers for Terraform, and most of them support data sources. There is one in particular that I would like to call out since you made it this far, and that is the [HTTP Provider](https://www.terraform.io/docs/providers/http/index.html) and the [HTTP Data Source](https://www.terraform.io/docs/providers/http/data_source.html). With this data source, you could pretty much query HTTP endpoint and retrieve data that could then be parsed in Terraform to use in your templates. Let's take a look at one last sample.

```hcl
provider "http" {
}

data "http" "weather" {
  url = "https://www.metaweather.com/api/location/search/?lattlong=36.03,-84.03"

  request_headers = {
    "Accept" = "application/json"
  }
}

output "nashville" {
    value = jsondecode(data.http.weather.body)[0]
}
```

Now we can run it, and here is the output.

```bash
$ terraform apply
data.http.weather: Refreshing state...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

nashville = {
  "distance" = 247221
  "latt_long" = "36.167839,-86.778160"
  "location_type" = "City"
  "title" = "Nashville"
  "woeid" = 2457170
}
```

I will put this on my list of future posts and combine this with a few others one to do some fun things.f

Thanks for reading,

Jamie
