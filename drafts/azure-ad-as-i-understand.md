---
Title: "Azure AD as I understand"
Published: 02/08/2017 13:23:36
Tags: 
- Azure
- Cloud
---
# Azure AD as I understand

Azure Active Directory is an awesome feature, it enables identity in the cloud, extensible, and allows for easier third-party integrations without exposing your internal systems. With that comes some very difficult to understand concepts that leads to much confusion. I am going to attempt to explain the relationship between Azure AD tenants, Azure subscriptions and Office 365. This explanation may not be 100% accurate or technically correct, but I wanted to share how I understand it which helps me perform my job duties.

## Azure AD Tenants and subscriptions

As I understand it, the relationship between Azure AD tenants and subscriptions is a many to many relationship.  A subscription can have many tenants and a tenant can have many subscriptons.

*Diagram Here*

However, a subscription can only have one **Default Directory** associated with it. So in terms of **Default Directory** that is a one to one relationship.

*Diagram Here*  

On the flip side of that a tenant can be the **Default Directory** to many subscriptions, creating a one-to-many relationship.

*Diagram Here*

This can lead to a lot of confusion as the directory you have selected in the portal determines what subscriptions you have visible,not necessarily the account you are logged in as.  The account can belong to multiple tenants, but if that tenant isn't associated with the directory you will not see the resources in the subscription by default.

## Azure AD Tenants and Office 365

When you create your Office 365 subscription it will create an Azure AD tenant behind the scenes for your subscription. That relationship is a one-to-one relationship and to the best of my knowledge that is immuttable, you cannot change it. So, you may ask how do I use it with my Azure subscription. That is pretty easy once you know what to do.

**Warning:  Make sure you have a microsoft account as the admin account for subscriptions so you don't lose access**

1.  Make sure you have a global admin account in both O365 and Azure Subscriptions.
2.  Log into the Classic Azure Portal.
3.  Add a directory, select existing directory, then use your O365 Admin credentials.
4.  Now that directory should be pulled into your portal.
5.  **Optional** Set your O365 AD tenanat as your default directory for your subscriptions.

This is how you pull it into your Azure portal for management and to use as a *Default Directory* for your Azure subscriptions.

## How it all relates

These is a diagram that I created that explains how the Azure and Office 365 platforms are separate, how they relate to tenants, and how those tenants relate to an Azure subscription.

*Diagram here*

I hope this helps others at least be able to grok how these are related and how they work. It can get confusing as to why some accounts can see resources and subscriptions and others cannot. Now you know that it is related to the *Default Directory* assigned to subscriptions and which combination of those items are selected in the portal.

