---
Title: "Why use Packer"
date: 2018-10-24T18:00:53
Tags: 
- Open Source
- PowerShell
- Microsoft And Linux
- Bash 
- Azure
- Azure DevOps
- Packer
---
# Why use Packer

I get asked this question a couple times every few months when I am talking about [Packer](https://www.packer.io/). Especially when it comes to using Packer in tandem with [Terraform](https://www.terraform.io/). Terraform allows you to use the provisioning mechanisms native to cloud providers like AWS User data or Azure script extensions. The question comes up that with these mechanisms in place, why would I want to go through the trouble of creating an image with Packer. That is a fair question and we are going to explore some items to consider when deciding if you need to pre-bake your image or provision it on the fly.

## Faster

If you are deploying VMs to host your application a good practice would be to run those VMs in an AWS Auto Scale group or in Azure a Scale set. These both allow you to ensure that you have at least one instance running and that you can scale up the number of instances based on demand. If you are using a provisioning mechanism when creating this VMs, when you need to add another instance the time it takes to provision the new instance is going impact how long it takes to get the new instance in the group/set. So if the provisioning takes 10 minutes, that is just 10 additional minutes that you will need to wait before your additional resources get added. If you were to pre-bake your image using Packer, then your group/set would just need to run your image and whatever light provisioning that may need to occur. This will speed up quickly you can scale.

## Consistency

Using pre-baked images provides a great consistency as everyone knows to use that image. Using provided images are fine, however, sometimes configuration may change or updates get applied that you may not know, which may cause issues. Another advantage is that your dev and/or QA team doesn't have to guess, when spinning up a new VM to do testing, if they grabbed the correct image and/or provisioning script. They just know to grab this pre-baked image with the latest timestamp to start doing testing.

Also, since Packer has the concept of multiple builders that can be ran against one set of provisioning. This will allow you to create consistent images for any cloud provider, Docker, and on-premise virtualization that you may be using. Now your Ops, QA, and Dev team can all use consistent images for creating their development, QA, and production environments. This will remove lots of pain as there will not be any guessing to how a VM was configured and what was installed. This can really save your bacon by narrowing down where you can focus if an issue does occur. In addition, since it will be sourced controlled all changes will be easily discoverable when troubleshooting.

## Conclusion

These are the two biggest advantages that I find in using Packer to create VM images instead of just using provisioning mechanisms. There isn't a "one right way" to do it and there are definitely multiple considerations when deciding if this is the approach you need to take. If you are fine with the provisioning time and how it impacts your scaling response then pre-baking your images may be more overhead than you need. If you are not supporting multiple clouds, Docker, and on-premise virtualization then it may not be the best fit for you. If your teams are not creating lots of VMs then again, this may not be a solution that is worth the investment.

However, if you are doing any of these things or have these concerns then I would encourage you to take a look at Packer. It provides a lots of features and it is pretty easy to get started. If you have questions about Packer please ask on Twitter or open an issue on my GitHub repo for this site.

Thanks for reading,

Jamie
