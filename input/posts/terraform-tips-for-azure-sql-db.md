---
Title: "Terraform tips for Azure SQL DB"
Published: 02/21/2019 19:57:17
Tags: 
- Open Source
- Terraform
- HashiCorp
- Azure
- SQL Server
---
# Terraform tips for Azure SQL DB

Here are a few specific tips for using Terraform with Azure SQL DB. Most of this is in the HashiCorp documentation, but it isn't always obvious. Without any further discussion, let's jump into these.

## 1. Allowing Azure Services

When using the Azure Portal, you have the option to enable allowing Azure Services access. Here is the location.

![](/images/other-posts/AllowAzureServices.png)

However, Terraform doesn't enable this feature by default which is great as it makes it something you have to define it explicitly. There is a note section located in the Terraform docs [here](https://www.terraform.io/docs/providers/azurerm/r/sql_firewall_rule.html#argument-reference). And this is what that will look like in Terraform.

```HCL
resource "azurerm_sql_firewall_rule" "allow_all_azure_ips" {
  name                = "AllowAllAzureIps"
  resource_group_name = "${azurerm_resource_group.terraform_tips.name}"
  server_name         = "${azurerm_sql_server.terraform_tips.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
```

Now when you run a Terraform template for Azure SQL DB with this rule the settings in the Azure Portal will be marked as **ON** instead of **OFF**. I would suggest using the same name, so it is obvious when reviewing your template that it serves that purpose and isn't opening up your SQL Server to the world.

## 2. Connecting Azure SQL DB to a VNET

There are instances when you would like to connect Azure SQL DB to a VNET, so all your traffic stays inside of Azure and your VNET. This feature requires multiple steps which need you to enable the service endpoint for SQL Server on the subnet you want to use. The value is **Microsoft.Sql**, and it allows all Microsoft supported databases to connect to your VNET. The service endpoint includes MariaDB, MySQL, and PostgreSQL.

The first step is to make sure you enable the service endpoint in on your subnet. The last one is the property that needs to be added to your subnet resource.

```HCL
resource "azurerm_subnet" "terraform_tips" {
  name                 = "mydbapp"
  resource_group_name  = "${azurerm_resource_group.terraform_tips.name}"
  virtual_network_name = "${azurerm_virtual_network.terraform_tips.name}"
  address_prefix       = "10.1.0.0/24"
  service_endpoints    = ["Microsoft.Sql"]
}
```

Now we can add the network rule for SQL Server that allows the traffic. Both have to be in place, or it will not work.

```HCL
resource "azurerm_sql_virtual_network_rule" "sql_subnet_rule" {
  name                = "MyDBAppRule"
  resource_group_name = "${azurerm_resource_group.terraform_tips.name}"
  server_name         = "${azurerm_sql_server.terraform_tips.name}"
  subnet_id           = "${azurerm_subnet.terraform_tips.id}"
}
```

Now the order of execution may cause an issue, and you can always set the [ignore_missing_vnet_service_endpoint](https://www.terraform.io/docs/providers/azurerm/r/sql_virtual_network_rule.html#ignore_missing_vnet_service_endpoint) property on the network rule. However, since we are referencing the *subnet_id* it shouldn't cause an error. If you are using a data resource or setting your subnet id manually to use an existing subnet, then you may need to enable this property just in case you haven't allowed that setting on your subnet. Also, you don't want to include the firewall rule above as that would defeat the purpose.

## 3. Passing in the Administrator Login Password

If you are creating Azure SQL Server in your Terraform script, you do not want to put your password directly in your Terraform template. One solution is to create a variable and pass it in on the command line. Here is how you accomplish that.

```HCL
variable "sql_password" {
    type = "string"
    description = "Azure SQL Server Password"
}

resource "azurerm_sql_server" "terraform_tips" {
  name                         = "MySqlDB"
  administrator_login_password = "${var.sql_password}"
}
```

Now you can use your CI server to send in your password like this.

```Bash
$ terraform apply -var 'sql_password=<insert password here>'
```

Alternatively, you can leverage Azure Key Vault for storing your password. Terraform can use a data resource to get your password from the vault. You will need to make sure that the account you are using to execute Terraform has permission. Here is how you do it.

```HCL
data "azurerm_key_vault_secret" "sql_password" {
  name      = "SqlPassword"
  vault_uri = "https://terraformtips.vault.azure.net/"
}

resource "azurerm_sql_server" "terraform_tips" {
  name                         = "MySqlDB"
  administrator_login_password = "${data.azurerm_key_vault_secret.sql_password.value}"
}
```

There you go, two ways to keep your Azure SQL Server password secure while still using Terraform.

## 4. Building connection strings in Terraform

If you need a connection string in your Terraform template, you can build it using either the resources that you use to create it or using data resources. Let's start with the assumption you are using resources inside of your template. I will abbreviate these and only include the essential pieces.

```HCL
resource "azurerm_sql_server" "terraform_tips" {
}

resource "azurerm_sql_database" "terraform_tips" {
}

resource "azurerm_app_service" "terraform_tips" {
  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.terraform_tips.fully_qualified_domain_name Database=${azurerm_sql_database.terraform_tips.name};User ID=${var.username};Password=${var.password};Trusted_Connection=False;Encrypt=True;"
  }
}
```

## Conclusion

These are just a few tips and examples for performing specific tasks in Terraform when working with Azure SQL DB. As I discover more of these, I will make additional posts.

Thanks for reading,

Jamie

**If you enjoy the content then consider [buying me a coffee](https://www.buymeacoffee.com/aQPnJ73O8).**
