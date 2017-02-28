---
Title: "Cake: One way to SFTP"
Published: 02/27/2017 20:45:43
Tags: 
- Open Source
- Cake
- Tutorials
---
# Cake: One way to SFTP

I am working on a project in which I need to SFTP a CSV file of data. I have been working on automating that task, more coming in a future post, with Cake and Jenkins. I am the author of [Cake.Ftp](https://github.com/phillipsj/Cake.Ftp), however SFTP isn't currently supported in the .NET framework. This meant I needed to turn to other solutions. There are a few Cake Addins that could do what I need.  

* [Cake.Putty](https://github.com/MihaMarkic/Cake.Putty)
* [Cake.WinSCP](https://github.com/ilich/Cake.WinSCP)

I decided that I wanted to learn a little more about Cake than I currently know, so I decided to consume [SharpSSH](https://sourceforge.net/projects/sharpssh/) directly in my Cake script to do the SFTP. Here is how I was able to get it to work. 

**Tune in to this week's Cake Crumbs to see a better way to achieve what is below.**

## Step 1
Install the correct NuGet packages and dependencies by adding the following *tool* directives.

```
#tool nuget:?package=Tamir.SharpSSH
#tool nuget:?package=DiffieHellman
#tool nuget:?package=Org.Mentalis.Security
```

That looks like a lot of files, the *DiffieHellman* and *Org.Mentalis.Security* are dependencies not referenced in the SharpSSH package.

## Step 2
Now we need to load these dependencies into the context of the Cake script by adding the *reference* directive.

```
#reference "tools/Org.Mentalis.Security/lib/net40/Org.Mentalis.Security.dll"
#reference "tools/DiffieHellman/lib/net40/DiffieHellman.dll"
#reference "tools/Tamir.SharpSSH/lib/Tamir.SharpSSH.dll"
```

## Step 3

Now that the dependencies are all registered with the context, it is time to put your using statement.

```
using Tamir.SharpSsh;
``` 

With all of these steps in place your script should look like the following:

```
//tools
#tool nuget:?package=Tamir.SharpSSH
#tool nuget:?package=DiffieHellman
#tool nuget:?package=Org.Mentalis.Security

#reference "tools/Org.Mentalis.Security/lib/net40/Org.Mentalis.Security.dll"
#reference "tools/DiffieHellman/lib/net40/DiffieHellman.dll"
#reference "tools/Tamir.SharpSSH/lib/Tamir.SharpSSH.dll"

using Tamir.SharpSsh; 
//////////////////////////////////////////////////////////////////////
// ARGUMENTS
//////////////////////////////////////////////////////////////////////

var target = Argument("target", "Default");
var configuration = Argument("configuration", "Release");

//////////////////////////////////////////////////////////////////////
// TASKS
//////////////////////////////////////////////////////////////////////
```

Now we are ready to create the SFTP task that we need. Everything past this point is pretty much just plain old C#.

```
Task("SFTP")
    .Does(() => {
        Information("Starting FTP upload...");
        var sftp = new Sftp(ftpUri, ftpUserName, ftpPassword);
        sftp.Connect();
        Information("FTP connected...");
        sftp.Put(new [] { fileToUpload }, ftpLocation);
        Information("File uploaded...");
});
```

Hope someone else finds this useful and remember that this week's Cake Crumbs will clean up this script a bit.

Thanks for reading,

Jamie