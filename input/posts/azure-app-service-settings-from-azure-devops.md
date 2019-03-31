---
Title: "Azure App Service settings from Azure DevOps"
Published: 03/09/2019 18:05:34
Tags: 
- Azure App Service
- Azure
- Microsoft
- .NET
---
# Azure App Service settings from Azure DevOps

This post is an interesting post to be writing, something that would seem straight forward has turned out not to be or else I wouldn't be writing about it. While trying to deploy a .NET full framework app to Azure App Service using Azure DevOps I needed to update a few app setting keys and a connection string. This task would seem to be something that would be straight forward, but it wasn't. I am going to start with the hard lessons I learned first.

## What doesn't work

A few of the app setting keys need set to an empty string along with a connection string. After several different attempts I discovered that regardless of the method, you can't configure a setting to an empty string using Azure DevOps, Azure Portal, or CLI tooling. Another lesson that I learned is that trying to set a connection string using the [Azure App Service Deploy Task](https://docs.microsoft.com/en-us/azure/devops/pipelines/targets/webapp?view=azure-devops&tabs=yaml) doesn't like whitespaces like the one that would be in a SQL Server connection string. Whitespace was causing the setting value to split across multiple lines. The Azure CLI has the same difficulty with the whitespace due to an escaping issue that I couldn't determine a way to mitigate.

## Sample Application

I have a sample application called [ado-ff-test](https://github.com/phillipsj/ado-ff-test) that I created with the following app settings and connection strings set. These are specific to the different ways we are going to configure each of these settings.

Here are the app settings.

```XML
<add key="TaskSettings" value="" />
<add key="XmlSub" value="" />
<add key="AzureCLI" value="" />
```

The connection string.

```XML
<add name="DefaultConnection" connectionString="" providerName="System.Data.SqlClient" />
```

I then configured a pipeline using the Azure Web App for ASP .NET build template.

![](/images/appset/webappforasp.png)

Now we can get started demonstrating the different techniques.

## Using the Azure App Service Deploy task

The default Azure App Service Deploy task allows you to set App Settings, but it doesn't let you configure connection strings in a .NET Full framework app. It will work fine for ASP .NET Core because it is JSON.

To set app settings using the task you need to open the *Application and Configuration Settings* section and add the setting to the *App Settings*. Here is what it looks like setting the **TaskSettings* key above.

![](/images/appset/tasksettings.png)

Now remember this doesn't work for connection strings, so let's see how to set those using the XML substitution.

### XML Variable Substitution

This only works for items in Application Settings, App Settings, and Connection Strings section of your configuration file. It took me a few passes at reading it before it clicked with me how it works.

The first step is to turn it on in the Azure App Service Deploy task by going to the *File Transforms and Variable Substitution Options* section and checking the box next to the **XML variable substition**.

![](/images/appset/xmlsub.png)

Then add a build variable to your build that matches the key and connection string you want to replace and bam!

![](/images/appset/buildvar.png)

When it deploys, you will see the following in your build output for that step. These types of changes will not be displayed directly in the Azure Portal, but if you look, you will see those in the *web.config* on the server.

## Azure CLI

If you don't want to make these changes in your web.config, but you want to see these in the Azure Portal as overrides, then you can make this change with the Azure CLI. You need to add the Azure CLI task and use the following command. However, know that this will not work for connection strings that have spaces in their names.

Add an Azure CLI task to your build.

```Bash
$ az webapp config appsettings set -g FreeRG -n ado-ff-test --settings AzureCLI=SetByCLI
```

And your task should look like this.

![](/images/appset/webappforasp.png)

## PowerShell

This method isn't going to be all that different, so I will not be showing it. However, at the time of this post, version 4 of the Azure PowerShell task hasn't been released so you will need to use the AzureRM module, not the newer Azure Az Module set of commands.

## Final Results

Here is what is located on the server side *web.config*.

![](/images/appset/serverset.png)

And this is what shows in the portal.

![](/images/appset/portalset.png)

So as you can see the items set with the Task or with the Azure CLI get added to the Azure Portal as override values. If you use the XML substitution, you will not see those in the portal, but you can see those changes if you look at the *web.config* on the server.

## Conclusion

That's it, and this is just a quick overview of the different ways to configure your app settings and or connection strings in Azure App Service using Azure DevOps. Learning these different options was a necessity, and something that I wouldn't have thought would have been so difficult, alas it was difficult.

Thanks for reading,

Jamie
