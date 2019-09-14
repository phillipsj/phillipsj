---
Title: "Mounting Azure Blob Storage Locally"
date: 2018-10-29T21:14:11
Tags: 
- Open Source
- Microsoft And Linux
- Azure
- Ubuntu
- Rclone
- Azure Storage
---
# Mounting Azure Blob Storage Locally

If you are using [Azure Blob Storage](https://azure.microsoft.com/en-us/services/storage/blobs/) you know how frustrating it can be to push and pull down blobs when you are doing development or supporting a production issue. You could easily pull and push blobs with something like [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/), however, I am going to show you have to do that using [Rclone](https://rclone.org/) since it makes the process much smoother with more rapid feedback. In a previous [post](https://www.phillipsj.net/posts/using-onedrive-with-linux), I covered how to install it on Ubuntu 18.04 so I will not be covering that. What I will be covering is how to configure it for mounting an Azure Blob Storage account on both Ubuntu, including other Linux distros, and Windows. Let's get started.

## Blob Storage Info

Before we start configuring Rclone we will need two a couple of pieces of information to be at hand.

* Storage Account Name
* Storage Access Key

These can be found on the *Access Keys* section on the Storage account blade in the Azure Portal or with the Azure CLI with this command.

```Bash
$ az storage account keys list --account-name rcloneexample --resource-group Examples --output table
KeyName    Permissions    Value
---------  -------------  ----------------------------------------------------------------------------------------
key1       Full           86AMVMmFdHM4HWupS7MiEIfb2oM71ptOFWrwVKp3Fwnbdsh1sGupG75O4e4XHMMnibE6+wnI6koZbysYDO8LSg==
key2       Full           eSytJThzhYLt4Kb76q/JLWXxNFC+By7h2JWuTq56sClKyUc9FjAqMNkFTC0nwLPNF8K7cVO1jebD3PhxGG5adA==
```

## Configuration on Linux

With the two pieces of info at our side, lets' start running through configuring Rclone.

Just like what the results on the installation tells us we are going to run *rclone config*.

```Bash
$ rclone config
```

This will prompt us to enter what we want to do, we want to enter **n** here as that will setup a new remote.

```Bash
No remotes found - make a new one
n) New remote
s) Set configuration password
q) Quit config
n/s/q> n
```

Now it will prompt you for a name, I am going to call mine **blob**.

```Bash
name> blob
```

Now it is going to ask you what kind of storage you are configuring for the new remote. We are going to enter **17** for Azure Blob Storage.

```Bash
17 / Microsoft Azure Blob Storage
   \ "azureblob"
storage> 17
** See help for azureblob backend at: https://rclone.org/azureblob/ **
```

New it is going to prompt for **Storage Account name** just enter the name of the account.

```Bash
Storage Account Name (leave blank to use connection string or SAS URL)
Enter a string value. Press Enter for the default ("").
account> rcloneexample
```

Now you will be prompted for the **Storage Account Key** which we have too.

```Bash
Storage Account Key (leave blank to use connection string or SAS URL)
Enter a string value. Press Enter for the default ("").
key> 86AMVMmFdHM4HWupS7MiEIfb2oM71ptOFWrwVKp3Fwnbdsh1sGupG75O4e4XHMMnibE6+wnI6koZbysYDO8LSg==
```

We are not going to provide a SAS URL for access so leave it the default which is blank.

```Bash
SAS URL for container level access only
(leave blank if using account/key or connection string)
Enter a string value. Press Enter for the default ("").
sas_url> 
```

Now it is going to ask to do an advanced config, I would encourage you don't do this initially. I answer **n**.

```Bash
Edit advanced config? (y/n)
y) Yes
n) No
y/n> n
```

Now the last question is going to show use your config and ask use to validate if it is correct, I am answering yes as it looks right to me.

```Bash
Remote config
--------------------
[blob]
type = azureblob
account = rcloneexample
key = 86AMVMmFdHM4HWupS7MiEIfb2oM71ptOFWrwVKp3Fwnbdsh1sGupG75O4e4XHMMnibE6+wnI6koZbysYDO8LSg==
--------------------
y) Yes this is OK
e) Edit this remote
d) Delete this remote
y/e/d> y
```

Finally it will list out your list of remotes. Just type **q** so we can quit the confiuguration.

```Bash
Current remotes:

Name                 Type
====                 ====
blob                 azureblob
onedrive             onedrive

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> q
```

Now let's see if we can access the storage.

```Bash
$ rclone lsd blob:
-1 2018-10-29 14:14:24        -1 rclone
```

And it looks like we have connectivity. Now we can mount it to our system and work with it directly.

```Bash
$ rclone mount blob:rclone /home/phillipsj/rclone-container --daemon
```

![](/images/rclone-blob/blob-linux.png)

That's it, if you want to mount automatically with system startup, you will need to create a systemd service which I explain in my [OneDrive](https://www.phillipsj.net/posts/using-onedrive-with-linux) post.

## Configuration on Windows

On Windows you have two options for getting Rclone.  You can get it using [Chocolatey](https://chocolatey.org/search?q=rclone) or you can download it and put in in a folder that is on your path. I opted for the latter and here is how I did it.

```PowerShell
$ [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ Invoke-WebRequest https://downloads.rclone.org/rclone-current-windows-amd64.zip -Outfile rclone.zip
$ Expand-Archive rclone.zip
$ Move-Item -Path .\rclone\**\rclone.exe -Destination C:\tools\rclone.exe
```

Now we can see if Rclone is working as expected.

```PowerShell
$ rclone --version
rclone v1.44
- os/arch: windows/amd64
- go version: go1.11
```

```PowerShell
$ rclone config
```

This will prompt us to enter what we want to do, we want to enter **n** here as that will setup a new remote.

```PowerShell
No remotes found - make a new one
n) New remote
s) Set configuration password
q) Quit config
n/s/q> n
```

Now it will prompt you for a name, I am going to call mine **blob**.

```PowerShell
name> blob
```

Now it is going to ask you what kind of storage you are configuring for the new remote. We are going to enter **17** for Azure Blob Storage.

```PowerShell
17 / Microsoft Azure Blob Storage
   \ "azureblob"
storage> 17
** See help for azureblob backend at: https://rclone.org/azureblob/ **
```

New it is going to prompt for **Storage Account name** just enter the name of the account.

```PowerShell
Storage Account Name (leave blank to use connection string or SAS URL)
Enter a string value. Press Enter for the default ("").
account> rcloneexample
```

Now you will be prompted for the **Storage Account Key** which we have too.

```PowerShell
Storage Account Key (leave blank to use connection string or SAS URL)
Enter a string value. Press Enter for the default ("").
key> 86AMVMmFdHM4HWupS7MiEIfb2oM71ptOFWrwVKp3Fwnbdsh1sGupG75O4e4XHMMnibE6+wnI6koZbysYDO8LSg==
```

We are not going to provide a SAS URL for access so leave it the default which is blank.

```PowerShell
SAS URL for container level access only
(leave blank if using account/key or connection string)
Enter a string value. Press Enter for the default ("").
sas_url> 
```

Now it is going to ask to do an advanced config, I would encourage you don't do this initially. I answer **n**.

```PowerShell
Edit advanced config? (y/n)
y) Yes
n) No
y/n> n
```

Now the last question is going to show use your config and ask use to validate if it is correct, I am answering yes as it looks right to me.

```PowerShell
Remote config
--------------------
[blob]
type = azureblob
account = rcloneexample
key = 86AMVMmFdHM4HWupS7MiEIfb2oM71ptOFWrwVKp3Fwnbdsh1sGupG75O4e4XHMMnibE6+wnI6koZbysYDO8LSg==
--------------------
y) Yes this is OK
e) Edit this remote
d) Delete this remote
y/e/d> y
```

Finally it will list out your list of remotes. Just type **q** so we can quit the confiuguration.

```PowerShell
Current remotes:

Name                 Type
====                 ====
blob                 azureblob
onedrive             onedrive

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> q
```

Now let's see if we can access the storage.

```PowerShell
$ rclone lsd blob:
-1 2018-10-29 14:14:24        -1 rclone
```

The basics of Rclone is now working on your system. If you want to mount it on your local Windows box like we did on Linux, we will need to install [WinFsp](http://www.secfs.net/winfsp/) which provides a filesystem proxy for Windows much like Fuse for Linux.

We will install it using Chocolatey:

```PowerShell
$ choco install winfsp -y
```

After WinFsp is installed, let's see if we can get it mounted.

```PowerShell
$ rclone mound blob:rclone C:\Users\cphil\rclone-container --daemon
```

![](/images/rclone-blob/blob-windows.png)

That's it, if you want to mount automatically with system startup, there are a few options, I will point you to [NSSM](https://nssm.cc/) as an easy way to create a Windows Service.

## Conclusion

I find this stuff very cool and exciting. I have been able to use one simple tool for working with multiple storage solutions in a cross-platform way. Don't get me wrong, all the additional pieces like running as a service and mounting wasn't always straightfowward, but the mileage that I am able to get out of a single tool like Rclone is just amazing to me.

Thanks for reading,

Jamie
