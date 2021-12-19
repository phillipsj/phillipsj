---
title: "How to Install Modules in a Windows Powershell Core Container"
date: 2021-12-19T12:34:18-05:00
tags:
- Open Source
- PowerShell
- PowerShell Containers
- Microsoft And Linux
- Containers
- Windows Containers
- Docker
---

I ran into this issue where I was trying to containerize a small [Polaris](https://www.phillipsj.net/posts/powershell-rest-api-with-polaris/) app for testing using the Nano Server PowerShell Core container. While performing the Docker build, I kept getting an `Access Denied` error. 

```Bash
Step 3/6 : SHELL ["pwsh", "-Command"]
 ---> Running in f8e2ee2c6efd
Removing intermediate container f8e2ee2c6efd
 ---> 21cd481c5cdf
Step 4/6 : RUN Install-Module -Name Polaris -Scope CurrentUser -Force
 ---> Running in 162e6d8ae570
Install-Package: Access is denied.

Removing intermediate container 162e6d8ae570
 ---> 237c5b4ff86a
Step 5/6 : COPY app.ps1 app.ps1
 ---> 8ac6e117a58c
```

This works fine in the Linux containers; it just fails in Windows. I figured it must be using a different user, so I tried scoping it to the current user, which again worked on Linux and failed on Windows. I dug in and found the [Dockerfiles](https://github.com/PowerShell/PowerShell-Docker) used to create the official images and found [this](https://github.com/PowerShell/PowerShell-Docker/blob/41c59e4b844cec8678df8118e231f8cd6e4188bd/release/7-1/nanoserver1809/docker/Dockerfile#L57-L69):

```Dockerfile
### Begin workaround ###
# Note that changing user on nanoserver is not recommended
# See, https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-base-images#base-image-differences
# But we are working around a bug introduced in the nanoserver image introduced in 1809
# Without this, PowerShell Direct will fail
# this command sholud be like this: https://github.com/PowerShell/PowerShell-Docker/blob/f81009c42c96af46aef81eb1515efae0ef29ad5f/release/preview/nanoserver/docker/Dockerfile#L76
USER ContainerAdministrator


# This is basically the correct code except for the /M
RUN setx PATH "%PATH%;%ProgramFiles%\PowerShell;" /M


USER ContainerUser
### End workaround ###
```

It seems there are ContainerAdministrator and ContainerUser users. I changed the user to the administrator user before the module install and then changed it back for continuing, which solved the issue. These users are only in Windows containers won't work on Linux. Here is my Dockerfile for Windows now:

```Dockerfile
FROM mcr.microsoft.com/powershell:nanoserver-ltsc2022

SHELL ["pwsh", "-Command"]

USER ContainerAdministrator

RUN Install-Module -Name Polaris -Force  

USER ContainerUser

COPY app.ps1 app.ps1

CMD ["pwsh", "-File", "app.ps1"]
```

I hope this helps someone that's running into a similar issue. 

Thanks for reading,

Jamie
