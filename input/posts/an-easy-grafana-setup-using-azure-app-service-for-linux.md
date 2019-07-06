---
Title: "An easy Grafana setup using Azure App Service for Linux"
Published: 07/04/2019 13:23:24
Tags: 
- Azure App Service
- Azure Active Directory
- Azure Storage
- Azure
- Microsoft and Linux
- Linux
- Grafana
- Azure CLI
- PowerShell
- Bash
- Terraform
---
# An easy Grafana setup using Azure App Service for Linux

[Grafana](https://grafana.com/) is an open source platform for creating dashboards and analyzing time-series data. Grafana is written in Go and provides a feature-rich platform for visualizing any time-series data from sources like Azure Monitor, Azure Application Insights, OpenTSDB, Prometheus, InfluxDB, and many more. It has a wealth of plugins to provide visualization and source enhancements. Grafana can be purchased through Grafana Cloud, or it can be self-hosted.

In this post, we are going to deploy Grafana using the [container](https://hub.docker.com/r/grafana/grafana/) to Azure App Service for Linux. We are going to use Azure Storage for hosting our *var/lib/grafana* folder which is the home for our plugins and [SQLite](https://www.sqlite.org/index.html) database. Finally, we will provide authentication to our Grafana instance using Azure Active Directory. Azure App Service for Linux allows running containers, which explains the first step. Azure App Service also allows mounting of [Azure Storage](https://docs.microsoft.com/en-us/azure/app-service/containers/how-to-serve-content-from-azure-storage), either blob or file, to an Azure App Service, which you can map to a location on your container. The last thing to do is to wire Grafana up to Azure Active Directory. Fortunately, Grafana provides OAuth support and provides the [documenation](https://grafana.com/docs/auth/generic-oauth/#set-up-oauth2-with-azure-active-directory) for the configuration.

I posted a poll on Twitter to see what type of examples to provide for infrastructure as code. An example in PowerShell, Bash, and Terraform was requested, so I have included all three. I have a repository in the [BlueGhost Labs](https://github.com/BlueGhostLabs) organization GitHub called [grafana-container-on-azure](https://github.com/BlueGhostLabs/grafana-container-on-azure) that has all the code organized by language. Scripts for both creation and cleanup exist. Below is a walkthrough of what all of these scripts are doing if you want to take a deeper dive.

## Getting Started

Based on the language you want to use, you will need one of the following installed.

#### Bash

These scripts require the Azure CLI version >= 2.0.68 and were written using Bash 5, but it should be compatible with older versions.

#### PowerShell

These scripts require PowerShell Core version >= 6.2.1 and was written using the new [Azure Az Module](https://docs.microsoft.com/en-us/powershell/azure/overview?view=azps-2.4.0#about-the-new-az-module) version >= 2.2.0.

#### Terraform

These scripts require Terraform version 0.12. It uses AzureRM, AzureAD, and Random providers.

Once you have picked the environment and have gotten everything configured, we can get started creating our scripts. If you need any assistance with installation or run into any issues, reach out on GitHub, Twitter, or LinkedIn using the links to the right of this post.

## Initial Configuration

We need to set some initial variables. I would urge you to change these to avoid naming conflicts in resources like the App Service.

#### Bash

```Bash
#! /bin/bash

# Initial Setup
resource_group_name="grafana-eus-rg"
location="eastus"
storage_account_name="grafanaeusst"
app_plan_name="grafana-eus-ap"
app_service_name="grafana-eus-as"

# Generating a Grafana password
gf_password=$(date +%s | sha256sum | base64 | head -c 12 ;)

# Getting tenant id for use later
tenant_id=$(az account show --query 'tenantId' --output tsv)
```

#### PowerShell

```PowerShell
#! /bin/env pwsh

# Initial Setup
$resourceGroupName="grafana-eus-rg"
$location="East US"
$storageAccountName="grafanaeusst"
$appPlanName="grafana-eus-ap"
$appServiceName="grafana-eus-as"

# Generating a Grafana and AD App password
$grafanaPassword = -join ((65..90) + (97..122) | Get-Random -Count 12 | % {[char]$_})
$clientSecret = New-Guid

# Getting tenant id for use later
$tenantId = (Get-AzTenant).Id
```

#### Terraform

Variables for your variables.tf file.

```HCL
# variables.tf
variable "app_name" {
  default = "grafana"
}

variable "location" {
  default = "East US"
}
```

In your main.tf, start with the following:

```HCL
provider "azurerm" {
  version = "=1.28.0"
}

provider "azuread" {
  version = "~>0.4"
}

provider "random" {
  version = "~>2.1"
}

locals {
  region_codes = {
    "East US" = "eus"
  }

  app_service_name = "${var.app_name}-${lookup(local.region_codes, var.location)}-as"
}

# Create Client Secret
resource "random_uuid" "client_secret" {}

# Create grafana password
resource "random_string" "grafana_password" {
  length = 16
}
```

## Creating our Resource Group

Now let's create our resource group.

#### Bash

```Bash
# Create Resource Group
az group create \
    --name $resource_group_name \
    --location $location \
--output none
```

#### PowerShell

```PowerShell
# Create Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location
```

#### Terraform

```HCL
resource "azurerm_resource_group" "main" {
  name     = "${var.app_name}-${lookup(local.region_codes, var.location)}-rg"
  location = "${var.location}"
}
```

## Create the Storage Account and Container

Now let's create the storage account we will use to store the plugins and SQLite database.

#### Bash

```Bash
# Create Storage Account
az storage account create \
    --name $storage_account_name \
    --resource-group $resource_group_name \
    --location $location \
    --sku Standard_LRS \
    --output none

# Get Storage Account Key
storage_account_key=$(az storage account keys list \
    --account-name $storage_account_name \
    --resource-group $resource_group_name \
    --query '[0].value' \
    --output tsv)

# Create Grafana Container
az storage container create \
    --name grafana \
--account-name $storage_account_name
```

#### PowerShell

```PowerShell
# Create Storage Account
$StorageAccountParams = @{
    ResourceGroupName = $resourceGroupName
    Name = $storageAccountName
    Location = $location
    SkuName = "Standard_LRS"
}

New-AzStorageAccount @StorageAccountParams

# Get Storage Account Key
$AccountKeyParams = @{
    ResourceGroupName = $resourceGroupName
    Name = $storageAccountName
}

$storageAccountKey = (Get-AzStorageAccountKey @AccountKeyParams).Value[0]

# Create Grafana Container
$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
New-AzStorageContainer -Name grafana -Context $storageContext
```

#### Terraform

```HCL
resource "azurerm_storage_account" "main" {
  name                     = "${var.app_name}${lookup(local.region_codes, var.location)}st"
  resource_group_name      = "${azurerm_resource_group.main.name}"
  location                 = "${azurerm_resource_group.main.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "main" {
  name                  = "${var.app_name}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  storage_account_name  = "${azurerm_storage_account.main.name}"
  container_access_type = "private"
}

```

## Create the App Service Plan

Now we can create our App Service Plan, not we have to define it as a Linux plan.

#### Bash

```Bash
# Create App Service Plan
az appservice plan create \
    --name $app_plan_name \
    --resource-group $resource_group_name \
    --sku B1 \
    --is-linux \
--output none
```

#### PowerShell

```PowerShell
# Create App Service Plan
$AppPlanParams = @{
    ResourceGroupName = $resourceGroupName
    ResourceName = $appPlanName
    Location = $location
    ResourceType = "microsoft.web/serverfarms"
    kind = "linux"
    Properties = @{reserved="true"}
    Sku = @{name="B1";tier="Basic"; size="B1"; family="B"; capacity="1"}
}

New-AzResource @AppPlanParams -Force
```

#### Terraform

```HCL
resource "azurerm_app_service_plan" "main" {
  name                = "${var.app_name}-${lookup(local.region_codes, var.location)}-ap"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}
```

## Bash and PowerShell: Create the App Service

This step is where the instructions start deviating a little as Terraform can figure out dependencies and it also allows you to configure the App Service with the creation whereas the scripting tools do not.

#### Bash

```Bash
# Create App Service
az webapp create \
    --resource-group $resource_group_name \
    --plan $app_plan_name \
    --name $app_service_name \
    --deployment-container-image-name grafana/grafana \
--output none
```

#### PowerShell

```PowerShell
# Create App Service
$AppServiceParams = @{
    ResourceGroupName = $resourceGroupName
    Name = $appServiceName
    AppServicePlan = $appPlanName
}

$webApp = New-AzWebApp @AppServiceParams
```

## Bash and PowerShell: Mount the Storage Account to the App Service

Again, this differs from the Terraform. This command will mount the Blob storage to the App Service.

#### Bash

```Bash
# Set the storage account and mount point
az webapp config storage-account add \
    --resource-group $resource_group_name \
    --name $app_service_name \
    --custom-id GrafanaData \
    --storage-type AzureBlob \
    --share-name grafana \
    --account-name $storage_account_name \
    --access-key $storage_account_key \
    --mount-path /var/lib/grafana/ \
--output none
```

#### PowerShell

```PowerShell
# Set the storage account and mount point
$StoragePathParams = @{
    Name = "GrafanaData"
    AccountName = $storageAccountName
    Type = "AzureBlob"
    ShareName = "grafana"
    AccessKey = $storageAccountKey
    MountPath = "/var/lib/grafana/"
}

$storagePath = New-AzWebAppAzureStoragePath @StoragePathParams
```

## Register Application with Azure Active Directory

#### Bash

```Bash
# Get the hostname
hostname=$(az webapp show \
    --name $app_service_name \
    --resource-group $resource_group_name \
    --query 'defaulthostname' \
    --output tsv)

client_secret=$(uuidgen)

# App Registration
# https://grafana.com/docs/auth/generic-oauth/#set-up-oauth2-with-azure-active-directory
application_id=$(az ad app create \
    --display-name Grafana \
    --reply-urls https://$hostname/login/generic_oauth \
    --password $client_secret \
    --query 'appId' \
    --output tsv)
```

#### PowerShell

```PowerShell
# App Registration
# https://grafana.com/docs/auth/generic-oauth/#set-up-oauth2-with-azure-active-directory
$SecureClientSecret = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
$AdAppParams = @{
    DisplayName = "Grafana"
    Password = $SecureClientSecret
    IdentifierUris = "http://Grafana"
    ReplyUrls = "https://$($webApp.DefaultHostName)/login/generic_oauth"
}
$adApp = New-AzADApplication @AdAppParams
```

#### Terraform

```HCL
resource "azuread_application" "main" {
  name            = "Grafana"
  homepage        = "https://${local.app_service_name}.azurewebsites.net"
  identifier_uris = ["https://Grafana"]
  reply_urls      = ["https://${local.app_service_name}.azurewebsites.net/login/generic_oauth"]
}

resource "azuread_application_password" "main" {
  application_id = "${azuread_application.main.id}"
  value          = "${random_uuid.client_secret.result}"
  end_date       = "2020-01-01T01:02:03Z"
}
```

## Terraform: Create the App Service with configuration

Now we have all the pieces. We can build out our App Service in Terraform. This resource doesn't support for mounting the blob storage to the App Service, so we will be using a *local-exec* provisioner to run the Azure CLI command.

#### Terraform

```HCL
resource "azurerm_app_service" "main" {
  name                = "${local.app_service_name}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  app_service_plan_id = "${azurerm_app_service_plan.main.id}"

  site_config {
    linux_fx_version = "DOCKER|grafana/grafana"
  }

  app_settings = {
    "GF_SERVER_ROOT_URL"                          = "https://${local.app_service_name}.azurewebsites.net"
    "GF_SECURITY_ADMIN_PASSWORD"                  = "${random_string.grafana_password.result}"
    "GF_INSTALL_PLUGINS"                          = "grafana-clock-panel,grafana-simple-json-datasource,grafana-azure-monitor-datasource"
    "GF_AUTH_GENERIC_OAUTH_NAME"                  = "Azure AD"
    "GF_AUTH_GENERIC_OAUTH_ENABLED"               = "true"
    "GF_AUTH_GENERIC_OAUTH_CLIENT_ID"             = "${azuread_application.main.id}"
    "GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET"         = "${random_uuid.client_secret.result}"
    "GF_AUTH_GENERIC_OAUTH_SCOPES"                = "openid email name"
    "GF_AUTH_GENERIC_OAUTH_AUTH_URL"              = "https://login.microsoftonline.com/$tenantId/oauth2/authorize"
    "GF_AUTH_GENERIC_OAUTH_TOKEN_URL"             = "https://login.microsoftonline.com/$tenantId/oauth2/token"
    "GF_AUTH_GENERIC_OAUTH_API_URL"               = ""
    "GF_AUTH_GENERIC_OAUTH_TEAM_IDS"              = ""
    "GF_AUTH_GENERIC_OAUTH_ALLOWED_ORGANIZATIONS" = ""
  }

  provisioner "local-exec" {
    command = "az webapp config storage-account add --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_app_service.main.name} --custom-id GrafanaData --storage-type AzureBlob --share-name ${var.app_name} --account-name ${azurerm_storage_account.main.name} --access-key ${azurerm_storage_account.main.primary_access_key} --mount-path /var/lib/grafana/"
  }

  depends_on = [
    "azurerm_storage_container.main"
  ]
}
```

## Bash and PowerShell: Configure the App Service

Now we can configure out App Service with Bash and PowerShell.

#### Bash

```Bash
# Configuring the settings that will become environment variables
az webapp config appsettings set \
    --resource-group $resource_group_name \
    --name $app_service_name \
    --settings \
    GF_SERVER_ROOT_URL=https://$hostname \
    GF_SECURITY_ADMIN_PASSWORD=$gf_password \
    GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource,grafana-azure-monitor-datasource \
    GF_AUTH_GENERIC_OAUTH_NAME="Azure AD" \
    GF_AUTH_GENERIC_OAUTH_ENABLED=true \
    GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP=true \
    GF_AUTH_GENERIC_OAUTH_CLIENT_ID=$application_id \
    GF_AUTH_GENERIC_OAUTH_client_secret=$client_secret \
    GF_AUTH_GENERIC_OAUTH_SCOPES="openid email name" \
    GF_AUTH_GENERIC_OAUTH_AUTH_URL=https://login.microsoftonline.com/$tenant_id/oauth2/authorize \
    GF_AUTH_GENERIC_OAUTH_TOKEN_URL=https://login.microsoftonline.com/$tenant_id/oauth2/token \
    GF_AUTH_GENERIC_OAUTH_API_URL="" \
    GF_AUTH_GENERIC_OAUTH_TEAM_IDS="" \
    GF_AUTH_GENERIC_OAUTH_ALLOWED_ORGANIZATIONS="" \
    --output none

```

#### PowerShell

```PowerShell
# Configuring the settings that will become environment variables
$settings = @{
    GF_SERVER_ROOT_URL = "https://$($webApp.DefaultHostName)"
    GF_SECURITY_ADMIN_PASSWORD = "$($grafanaPassword)"
    GF_INSTALL_PLUGINS = "grafana-clock-panel,grafana-simple-json-datasource,grafana-azure-monitor-datasource"
    GF_AUTH_GENERIC_OAUTH_NAME = "Azure AD"
    GF_AUTH_GENERIC_OAUTH_ENABLED = "true"
    GF_AUTH_GENERIC_OAUTH_CLIENT_ID = "$($adApp.Id)"
    GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET = "$($clientSecret)"
    GF_AUTH_GENERIC_OAUTH_SCOPES = "openid email name"
    GF_AUTH_GENERIC_OAUTH_AUTH_URL = "https://login.microsoftonline.com/$tenantId/oauth2/authorize"
    GF_AUTH_GENERIC_OAUTH_TOKEN_URL= "https://login.microsoftonline.com/$tenantId/oauth2/token"
    GF_AUTH_GENERIC_OAUTH_API_URL = ""
    GF_AUTH_GENERIC_OAUTH_TEAM_IDS = ""
    GF_AUTH_GENERIC_OAUTH_ALLOWED_ORGANIZATIONS = ""
}

$AppConfig = @{
    ResourceGroup = $resourceGroupName
    Name = $appServiceName
    AppSettings = $settings
    AzureStoragePath = $storagePath
    ContainerImageName = "grafana/grafana"
}

Set-AzWebApp @AppConfig
```

## Setting the outputs for the generated passwords and the address to your Grafana instance

#### Bash

```Bash
# Printing out information you will need to know
echo Grafana password is: $gf_password
echo Grafana address is: https://$hostname
echo Client Secret is: $client_secret
```

#### PowerShell

```PowerShell
# Printing out information you will need to know
Write-Host Grafana password is: $grafanaPassword
Write-Host Grafana address is: https://$($webApp.DefaultHostName)
Write-Host Client Secret is: $clientSecret
```

#### Terraform

Place these in a file called *output.tf*.

```HCL
output "grafana_password" {
  value = "${random_string.grafana_password.result}"
}

output "grafana_address" {
  value = "https://${azurerm_app_service.main.default_site_hostname}"
}

output "client_secret" {
  value = "${random_uuid.client_secret.result}"
}
```

## Execute the script

Now all that is left is to login to your Azure Account on the command line then execute the script that you created.

#### Bash

```Bash
$ chmod +x <script-name>.sh
$ ./<script-name>.sh
```

#### PowerShell

```PowerShell
$ ./<script-name>.sh
```

#### Terraform

```Bash
$ terraform plan
$ terraform apply
```

## Conclusion

After the method you chose has finished, you should be able to use the URL output from the execution to navigate to a running Grafan instance. You will be able to login as the admin or you can login using an Azure Active Directory account. The Azure AD login will have read-only permissions by default so you will need to log into your Grafan instance as admin to change that. If you navigate to your created Azure Storage container, you will see an SQLite database, plugins folders, and a few other files. A cool thing about this approach is the versioning built into Azure Storage, so if you make a mistake, you can revert your SQLite database. As far as performance is concerned, I think the site is fast and the database is responding quickly, which is impressive, in my opinion, to be running from blob storage. The last point that I find interesting is that all three of these solutions have an almost identical line count.

Let me know if you have any questions, and I will try to assist you as I can.

Thanks for reading,

Jamie
