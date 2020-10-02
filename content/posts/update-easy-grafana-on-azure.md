---
title: "Update: Easy Grafana on Azure"
date: 2020-10-01T19:49:16-04:00
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
# Update: Easy Grafana on Azure

This post almost didn't happen as I was ready to give up. A little over a year ago, I wrote a post called [An easy Grafana setup using Azure App Service for Linux](https://www.phillipsj.net/posts/an-easy-grafana-setup-using-azure-app-service-for-linux/). Since then, there have been a few changes that I needed to implement in the [GitHub repository](https://github.com/BlueGhostLabs/grafana-container-on-azure) that I created. These changes have been general improvements. However, there was one major issue that has developed. I mounted Azure Blob storage to the container as the persistent storage for the database file and plugins in the previous post. Azure Blob storage shortly after was changed to a read-only storage option, and you can no longer use it to store your database file. That is a long story as to why that change came about. What happened was Microsoft released an update to the platform and changed the behavior of the mounted blob storage that caused files, like the SQLite database, to get deleted and recreated when the container was restarted. Due to the nature of the issue, that has now become a read-only storage option. This was discovered from a support request with Azure way back at this point. This now leaves the only easy option is to leverage Azure Files that are part of Azure Storage. Unfortunately, this [GitHub Issue](https://github.com/grafana/grafana/issues/20549#issuecomment-584857241) outlines the next major issue, which is the journaling issue that is preventing SQLite from working correctly on an Azure file share. You can use the workaround listed through the links on that issue, and I feel that it just seems like a lot of extra work. So really, there are two options, run it in the container and configure backups or run a database as a service using Azure MySQL or Azure PostgreSQL. If you go the PostgreSQL, check the documentation [here](https://grafana.com/docs/grafana/latest/installation/requirements/#supported-databases) to make sure you select a supported version.

## Other Solutions I tested

If you made it this far, you might as well no that I tried the above with Azure Files and ran into the database locked issue. I then tried to use the persistent storage on the app service, which I found out is backed with something similar to Azure Files. You get the same result as a locked SQLite database. I finally tried leveraging the multi-container option to host the database as a container. However, this is listed in a random piece of documentation that isn't recommended or really supported. What do you think happened? It didn't work. This leads me to the final solution that I could figure out.

## The final solution

I have updated all the scripts in the repository to leverage this new solution. What I decided to do was to just run the SQLite database inside of the container. This still leaves the backup issue to address, and I was able to find a tool called [Grafana backup tool](https://github.com/ysde/grafana-backup-tool/), which uses the Grafana API to export out all of your data to the storage account. This tool can run as a function, which will keep the cost down as the free tier should be plenty to execute the tool. This piece is still left to be completed, and I will post back when I get that up and tested.

## Conclusion

Thank you to all the contributors to that repo and for all the people that have referenced the work. I think having these low-cost solutions are essential. Hopefully, Azure will add back the ability to write with Azure Blob storage.

Thanks for reading,

Jamie
 
