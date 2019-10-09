---
title: "Azure Database for MySQL and Grafana"
date: 2019-10-08T20:13:17-04:00
tags:
- Open Source
- Azure
- Grafana
- MySQL
---

I have done a previous [post](https://www.phillipsj.net/posts/an-easy-grafana-setup-using-azure-app-service-for-linux/) about running the Grafana container on Azure App Service for Linux and hosting the SQLite database in Azure Blob Storage that mounts to the container. SQLite may not be what you are seeking, and if you would like to step up to a truly hosted database solution. You have two choices for Grafana, PostgreSQL, and MySQL. If you head over to the official Grafana docs about [PostgreSQL](https://grafana.com/docs/features/datasources/postgres/) you will see a note at the top of the page saying that a bug prevents the usage of those specific versions of PostgreSQL. Let's check this list against the Azure Database for PostgreSQL [supported versions](https://docs.microsoft.com/en-us/azure/postgresql/concepts-supported-versions) page. The listed versions running in Azure are the ones Grafana says we cannot use. Not running a supported version of PostgreSQL makes it a natural choice if you want to keep it all in Azure, Azure Database for MySQL it is. We will use version 8 as it is supported. Let's create our Azure Database for MySQL.

```Bash
# Creating resource group
$ az group create --location eastus --n grafana-database-rg

# Create your MySQL Server, default enables SSL encryption which we want
$ az mysql server create --location eastus /
--resource-group grafana-database-rg /
--name grafana-eus-db /
--sku-name B_Gen5_1 /
--admin-password 8cI54yfTpHmzOLDFzhaL /
--admin-user grafanaadmin /
--version 8.0

# Create your MySQL Database, we will use the expected default name of grafana
$ az mysql db create /
--resource-group grafana-database-rg /
--name grafana /
--server-name grafana-eus-db

# Add your IP to the database firewall
$ az mysql server firewall-rule create /
--resource-grup grafana-database-rg /
--server-name grafana-eus-db /
--name home /
--start-ip-address xxx.xx.xx.xxx /
--end-ip-address xxx.xx.xx.xxx
```

Now that we have our MySQL database with SSL enabled and our firewall rule, we will be able to connect.  Let's pull down our Grafana container and get the connection info set up correctly. The Grafana container allows you to pass in environment variables to perform the configuration. These are easily converted to Application Settings in Azure App Service for Linux when you are ready to take it there.

```Bash
$ docker pull grafana/grafana
```

Now that we have the grafana image pulled down, we need to configure the docker run command to have the correct environment variables for MySQL. This configuration was the frustrating part. Converting grafana configuration values to environment variables is pretty easy. Add GF_, then SECTION name, followed by the setting, so GF_DATABASE_TYPE. So we will need the following information to make this work.

* DB User created above
* DB Password created above
* Fully qualified hostname from Azure.
* CA Certificate Path
* Server Certificate name

The first three are pretty easy to determine using the commands and the Azure Portal. The last two are the more difficult ones to work out. Now Microsoft has in their documentation that you need to use the [Baltimore Cyber Trust Root](https://docs.microsoft.com/en-us/azure/mysql/howto-configure-ssl#step-1-obtain-ssl-certificate) certificate. Now I spent more time than I like to share figuring this out. However, if you just run the grafana container and enter Bash we can find it.

```Bash
$ docker run -it --entrypoint bash grafana/grafana
bash-5.0$ cd /etc/ssl/certs
bash-5.0$ ls | grep "Balt"
ca-cert-Baltimore_CyberTrust_Root.pem
```

Look what we found already installed on the container, the Baltimore Cyber Trust Root certificate. Now we just need to keep track of that file path and use that for the GF_DATABASE_CA_CERT_PATH environment variable. The last item we need is the server certification name. Again this is easier than I thought it was; its just database server name without the name, so *.mysql.database.azure.com.

Let's create our full docker command to make this all work.

```Bash
$ docker run /
 -d /
 -p 3000:3000 /
 -e "GF_SECURITY_ADMIN_PASSWORD=secret" /
 -e "GF_DATABASE_TYPE=mysql" /
 -e "GF_DATABASE_HOST=grafana-eus-db.mysql.database.azure.com:3306" /
 -e "GF_DATABASE_USER=grafanaadmin@grafana-eus-db" /
 -e "GF_DATABASE_PASSWORD=8cI54yfTpHmzOLDFzhaL" /
 -e "GF_DATABASE_SSL_MODE=true" /
 -e "GF_DATABASE_CA_CERT_PATH=/etc/ssl/certs/ca-cert-Baltimore_CyberTrust_Root.pem" /
 -e "GF_DATABASE_SERVER_CERT_NAME=*.mysql.database.azure.com" /
 grafana/grafana
```

Now open up MySQL Workbench, and you should see your newly created Grafana schema.

![image of grafana schema](/images/other-tutorials/azure-mysql/created-grafana-schema.png)

Thanks for reading,

Jamie
