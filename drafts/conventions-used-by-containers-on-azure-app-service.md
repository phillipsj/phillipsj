---
Title: "Conventions used by Containers on Azure App Service"
Published: 03/15/2019 21:50:54
Tags: 
- Azure App Service
- Azure
- Microsoft
- Containers
---
# Conventions used by Containers on Azure App Service

If you have been planning to use containers on Azure App Service, there are some conventions used that helps you get up and running. I have found that they are not all consolidated in one place and there isn't any dedicate documentation for those conventions. I have found they are sprinkled throught out the various docs, and this is an attempt to consolidate that information and learn all of the conventions myself.

## Expected Exposed Port

Azure App Service for Linux expects that the container runs and exposes it's service on port **80** by default. If your application isn't running on port 80, then you need to the **WEBSITES_PORT** app setting in your App Service to the port that you are exposing. You can do this wil the Azure CLI or with the Azure Portal.

## Enabling SSH for the container

You have to configure SSH in your App Service by following these [instructions](https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-custom-docker-image#connect-to-web-app-for-containers-using-ssh). Keep in mind that you have to make sure you *EXPOSE* port **2222**, this is only available from the Kudu portal.

## App Settings

Here is a collection of different pieces of info that is good to know about running containers.

### Setting Environment Variables in Container

This one isn't a suprise, environment variables are set for your containers by using app settings.

### Nested Strucutres like JSON

Typically you use nested JSON keys using the colon like this:

```
MySetting:MySubSetting
```

However, if you are using Linux or contianers you need to replace that with a double underscore like so.

```
MySetting__MySubSetting
```

### Accessing App Settings as Environment Variables

Two environment variables are created for each app setting when using PHP, Python, Java, and Node. One will be the name of the setting and the other will be prefixed with **APPPSETTING_SETTING**.

## Limitations 

This one is kind of hidden, due to a documented limitation, you cannot run both Windows and Linux apps in the same resource group. I don't know if I fully understand this one, but it is good to know. If you are having issues be aware of this one.



Thanks for reading,

Jamie

**If you enjoy the content then consider [buying me a coffee](https://www.buymeacoffee.com/aQPnJ73O8).**
