---
Title: "Getting started using Azure AD Auth with an Azure SQL Database"
Published: 03/25/2019 19:19:13
Tags: 
- Azure SQL
- Azure AD
- Azure
- SQL Server
---
# Getting started using Azure AD Auth with an Azure SQL Database

If you don't know, you can use Azure Active Directory Authentication with Azure SQL Database. The [documentation](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-control-access#authentication) includes the basics, but I wanted to outline the steps and additional information that I have learned. You can connect using SQL Server Management Studio, Azure Data Studio, and SQL Server Data Tools if you use the AD with MFA options. Here are my recommendations for setup and some watch outs.

## Setting Azure AD Admin on the SQL Server

To start using Azure AD authentication, you need to the **Azure AD Admin** on the server. This will not impact the SQL Auth and the original admin account you used to create the SQL Server. I recommend that you create an Azure AD Security Group and assign that group to the Azure AD Admin. That way you can dynamically add users to that group, making management easier.

## Adding Azure AD Users or Group to an Azure SQL Database

You will need to login into the SQL Server using your Azure credentials to create users for Azure AD. You cannot do it without using an Azure account so be aware. Any user accounts you will be what is called a [contained database user](https://docs.microsoft.com/en-us/sql/relational-databases/security/contained-database-users-making-your-database-portable?view=sql-server-2017) which means that the user will need to be created on every single database that the user needs access to using their Azure AD credentials. I like this because it is explicit. As before, I would encourage you to assign Azure AD groups, so you don't have to do the work in the database, you can just manage access through Azure AD memberships. Also, be aware, that just because you created a user, doesn't mean they have any access.

```SQL
CREATE USER [me@phillipsj.net] FROM EXTERNAL PROVIDER; -- To create a user with Azure Active Directory
```

**Warning: Each user that will use Azure AD needs to have their User Principal Name (UPN) set to be the same domain as the primary domain in Azure AD. I haven't tested if this is dictated by the Azure AD Admin's domain, just know to check UPNs if there are issues. If I have missed an option that can make this work, please let me know.**

## Granting Permissions

Users will not have permissions by default, you will need to assign permissions. Since users will only have access to the master database, they will not be able to list all databases when trying to connect. They will need to specify which database they want to connect. You can mitigate this by creating the user in the master database and assigning *data_reader*. I find this useful, so users get the behavior they expect and can see other databases so they can request access if desired.

```SQL
-- Master Database
ALTER ROLE db_datareader ADD MEMBER [me@phillipsj.net];

-- Development Database
ALTER ROLE db_owner ADD MEMBER [me@phillipsj.net];
```

These are all my quick tips for getting started with Azure AD auth and Azure SQL Database.

Thanks for reading,

Jamie
