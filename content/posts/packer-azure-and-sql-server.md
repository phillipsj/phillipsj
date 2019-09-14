---
Title: "Packer, Azure, and SQL Server"
date: 2018-08-27T19:29:40
Tags: 
- Open Source
- Packer
- HashiCorp
- Azure
- SQL Server
---
# Packer, Azure, and SQL Server

I have been using [Packer](https://www.packer.io), by [HashiCorp](https://www.hashicorp.com/), for the last few months. I have used it starting with AWS and I am now using it with Azure. Packer is a great way to automate the creation of Virtual Machine images for your prefered cloud or hypervisor. Packer has a a few concepts, but the key  ones are *builders* and *provisioners*. Builders are the target environments for your image output, like AMI, AzureRM, VMWare, VirtualBox, Docker, Digital Ocean, etc. and Provisioners are how you want configure/install software on the system. Examples of provisioners are Ansible, Chef, Shell, PowerShell, etc. I am planning a future post that is more in depth, but I wanted to cover an interesting discovery.

I was creating an image using an Azure Marketplace image for SQL Server. However, when trying to execute commands against SQL Server using the PowerShell provisioner, I kept getting an error.

```
azure-rm: User does not have permission to perform this action.
```

I just figured it was a weird PowerShell, WinRM, and SQL Server permission issue. Turns out, when the Marketplace SQL Server image spins up, the account you configure as part of creating the VM isn't immediately available in SQL Server. Since it only has access as part of the *BUILTIN\Users*, it actually doesn't have the permissions to peform the action. Can you believe that? An error message that is actually true, it wasn't until I was rubberducking with someone else and walking that person through the issue when the command worked. It then hit me, the user is now added as a login to SQL Server with the correct permissions. 

Now, how do you solve that. If you read about the [PowerShell Provisioner](https://www.packer.io/docs/provisioners/powershell.html) you will not see any settings that indicate you can pause or wait to run a command. I spent sometime digging into the Packer documentation and discovered on another page that there is property you can set called [pause_before](https://www.packer.io/docs/templates/provisioners.html#pausing-before-running). This property is available on all provisioners and can be used to make Packer wait before executing that command. So I added it to my PowerShell provisioner to add in a pause that was long enough for the start-up scripts to run and get the user account added to SQL Server.  Here is an example:

```
{
  "type": "powershell",
  "script": "script.ps1",
  "pause_before": "1m"
}
```

It is good to note that *m* is used for minutes, *s* is used for seconds. 

Additionally, there are a ton of extra provisioner settings that can be found in this [documentation](https://www.packer.io/docs/templates/provisioners.html) that are not referenced in the individual provisioners' documentation.

Thanks for reading and hope this helps.
