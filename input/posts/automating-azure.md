---
Title: "Automating Azure"
Published: 11/13/2017 15:34:38
Tags: 
- Azure
- Cloud
- Terraform
- Ansible
---
# Automating Azure

I have been recently experimenting with automating Azure using several tools. [Azure Resource Manager](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview), [Ansible](https://www.ansible.com/), and [Terraform](https://www.terraform.io/). 

## Ansible

We have started doing configuration management on my team using Ansible. Ansible does have support for Azure, but I was unable to find any Ansible modules for Azure PaaS services. This particular environment requires the creation of two Azure SQL databases, an Azure Service Bus, and a few other small PaaS services. It seems that Ansible does not currently support creating any of the PaaS services. There may be third party support, but nothing obvious was discovered in my searches. 

Even without being able to create PaaS services, it took a little tinkering to determine how to create even a basic set of services. The documentation is incorrect telling users to set *hosts: azure*, however it really needs to be set as *hosts: localhost*.

## Azure Resource Manager

My next stop was to use Azure Resource Manager to create my services before turning over the management of those services to Ansible. I have experimented with ARM before and now, it is really pretty terrible. I only briefly looked at the Azure Building Blocks. I think the part that makes it so tough to use is the JSON and the *API* in general. It seems they just exposed there internal tools for public use.

## Terraform

It took about 10 minutes to install Terraform and have a working example. I used Chocolatey to install Terraform, went to the documentation and started filling out my terraform file. A quick *terraform init* and *terraform apply* and I had a resource group with my service bus, SQL Server, and two Azure SQL databases showing up in the portal.

## Conclusion

It seems that after a few days I have decided, Terraform will be used for cloud asset creation and Ansible will be used to manage resources. If Ansible eventually adds support for PaaS services, I will revisit and reevaluate when that occurs. If I find that it meets our needs then we may switch for consistency. 

Thanks for reading.