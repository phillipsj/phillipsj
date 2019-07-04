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

[Grafana](https://grafana.com/) is an open source platform for creating dashboards and analyzing time series data. Grafana is written in Go and provides a feature rich paltform for visualizing any time series data from sources like Azure Monitor, Azure Application Insights, OpenTSDB, Prometheus, InfluxDB, and many more. It has a wealth of plugins to provide visualization and source enhancements. Grafan can be purchased through Grafana Cloud or it can be self-hosted.

In this post, we are going to deploy Grafana using the [container](https://hub.docker.com/r/grafana/grafana/) to Azure App Service for Linux. We are going to use Azure Storage for hosting our *var/lib/grafana* folder which is the home for our plugins and [SQLite](https://www.sqlite.org/index.html) database. Finally, we will provide authentication to our Grafana instance using Azure Active Directory. Azure App Service for Linux allows running containers, which explains the first step. Azure App Service also allows mounting of [Azure Storage](https://docs.microsoft.com/en-us/azure/app-service/containers/how-to-serve-content-from-azure-storage), either blob or file, to an Azure App Service, which can then be mapped to a location on your container. The last thing to do is to wire Grafana up to Azure Active Directory, fortunately Grafana provides OAuth support and provides the [documenation](https://grafana.com/docs/auth/generic-oauth/#set-up-oauth2-with-azure-active-directory) for the configuration.

I posted a poll on Twitter to see what type of examples to provide for infrastructure as code. It seems that providing an PowerShell, Bash, and Terraform example was desired to I have included all three. I have a repository in the [BlueGhost Labs](https://github.com/BlueGhostLabs) organization GitHub called [grafana-container-on-azure](https://github.com/BlueGhostLabs/grafana-container-on-azure) that has all the code organized by langauge. Scripts for both creation and cleanup exist. Below is a walkthrough of what all of these scripts are doing if you want to take a deeper dive.

## Getting Started

Based on the language you want to use you will need one of the following installed.


https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/CustomContainerSpecs.md
https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/BootstrapSpecs.md

#### Bash

These scripts require the Azure CLI version >= 2.0.68 and was written using Bash 5, but it should be compatabile with older versions.

#### PowerShell

These scripts require PowerShell Core version >= 6.2.1 and was written using the new [Azure Az Module](https://docs.microsoft.com/en-us/powershell/azure/overview?view=azps-2.4.0#about-the-new-az-module) version >= 2.2.0.

#### Terraform

These scripts require Terraform verson 0.12. It uses the AzureRM, AzureAD, and Random providers.

Once you have picked the environment and have gotten everything configured we can get started creating our scripts. If you need any assistance with installation or run into any issues reach out on GitHub, Twitter, or LinkedIn using the links to the right of this post.

## Initial Configuration

We need to perform some initial 

Thanks for reading,

Jamie
