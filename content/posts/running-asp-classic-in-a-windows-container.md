---
title: "Running ASP Classic in a Windows Container"
date: 2021-10-31T13:46:13-04:00
tags:
- Open Source
- ASP Classic
- Microsoft
- Containers
- Docker
- Windows Containers
- Tools
---

This topic will hopefully be entertaining. People often ask, "Why Windows Containers?" often not realizing that there are many applications that can't migrate to .NET 5 to be able to run on Linux or won't be migrated to anything else. Some of these applications are .NET Full framework, and some are ASP Classic. Some depend on Windows-specific APIs. Many of these applications are often used internally within businesses to fill a need, and they have been working with minimal maintenance for years. Often it isn't justifiable from a business perspective to rewrite or migrate away, leaving teams to keep them running as-is. Keeping these applications running comes the need to at least keep the platforms they are running on patched and modernized. Part of that strategy can be containerizing these applications, ensuring that you can develop, test, and patch more efficiently. With that introduction out of the way, let's create an ASP Classic web page and containerize it.

## ASP Classic Web Page

Let's create a straightforward ASP Classic Web Page, and if I can find a more complex example floating around that is open source, I will do an additional post on that. Until then, we can at least try a basic sample.

```ASP
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Hello from ASP</title>
</head>

<body>
    <% Response.Write("Yes, this is classic ASP running in an IIS Windows Container.") %>
</body>

</html>
```

Now let's save that to a directory called **content** with the name **default.asp** and create our Dockerfile.

## ASP Classic Dockerfile

Now in the directory with the content directory, create your Dockerfile. We will use the Windows Server 2019 base image for IIS.

```Dockerfile
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019
```

Let's set our default shell for the **RUN** command to be PowerShell.

```Dockerfile
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
```

Next, we should remove any files placed in **wwwroot**.

```Dockerfile
RUN Remove-Item -Recurse C:\inetpub\wwwroot\*
```

At this point, this shouldn't be anything new if you have worked with an IIS container or looked at other IIS container examples. To run an ASP Classic application in IIS, you will need the **ASP** and **ISAPI Extension** features enabled. These Windows features are allowed inside containers, so we need to install those features.

```Dockerfile
RUN Install-WindowsFeature -Name Web-ASP; Install-WindowsFeature -Name Web-ISAPI-Ext
```

The final two things left to do is to set our working directory to **wwwroot** and copy our ASP Classic page in it.

```Dockerfile
WORKDIR /inetpub/wwwroot

COPY content/ .
```

With those two lines, our Dockerfile should look like this:

```Dockerfile
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Remove-Item -Recurse C:\inetpub\wwwroot\*
RUN Install-WindowsFeature -Name Web-ASP; Install-WindowsFeature -Name Web-ISAPI-Ext

WORKDIR /inetpub/wwwroot

COPY content/ .
```

## Building our container

Great! We have all the necessary pieces in place we can build our container.

```Bash
docker build . -t asp-classic
```

Once that is complete, it could take some time if you haven't pulled down an IIS container image before. We should run our ASP Classic page.

```Bash
docker run -d -p 8000:80 asp-classic
```

After it boots up, you should be able to navigate to [http://localhost:8000](http://localhost:8000) to see an ASP Classic page running from within a container.

![ASP Classic app from a container](/images/other-posts/aspcontainer.png)

Just like that, we now have a basic ASP Classic page running in a container.

## Wrapping Up

Hopefully, this is useful for those wanting to know if migrating an ASP Classic application to a container is feasible. Or, maybe provide some inspiration to take that ASP Classic application you have and put it in a container. If you have any questions, please reach out to me through GitHub, Twitter, or LinkedIn, and I can assist.

Thanks for reading,

Jamie
