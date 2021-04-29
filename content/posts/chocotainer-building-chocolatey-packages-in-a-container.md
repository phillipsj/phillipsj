---
title: "Chocotainer: Building Chocolatey Packages in a Container"
date: 2021-04-28T22:31:13-04:00
tags:
- Open Source
- .NET Core
- Microsoft
- Tools
- .NET
- Containers
- Docker
- Chocolatey
- Windows Containers
---

I am working on packaging an app for [Chocolatey](https://chocolatey.org/). I want to make it as simple as possible for my teammates who may not be familiar with building Chocolatey packages. I decided that creating a Dockerfile that installs Chocolatey, copies all the files necessary, then packs and pushes would be a nice approach. It saves them from having to install Chocolatey, and it keeps the entire environment clean and contained. Let's walk through doing this together. 

## Create your Chocolatey Package

We will first need to create a Chocolatey package using the built-in template.

```PowerShell
$ choco new --built-in --name=TestingPackage --version=0.1.0 --maintainer=phillipsj

Chocolatey v0.10.15
Creating a new package specification at ..\TestingPackage
Generating template to a file
 at '..\TestingPackage\testingpackage.nuspec'
Generating template to a file
 at '..\TestingPackage\tools\chocolateyinstall.ps1'
Generating template to a file
 at '..\TestingPackage\tools\chocolateybeforemodify.ps1'
Generating template to a file
 at '..\TestingPackage\tools\chocolateyuninstall.ps1'
Generating template to a file
 at '..\TestingPackage\tools\LICENSE.txt'
Generating template to a file
 at '..\TestingPackage\tools\VERIFICATION.txt'
Generating template to a file
 at '..\TestingPackage\ReadMe.md'
Generating template to a file
 at '..\TestingPackage\_TODO.txt'
Successfully generated TestingPackage package specification files
 at '..\TestingPackage'
```

Now that we have a simple package, we can do a quick test by running the *pack* command inside the *TestingPackage* directory.

```PowerShell
$ choco pack
Chocolatey v0.10.15
Attempting to build package from 'testingpackage.nuspec'.
Successfully created package '..\TestingPackage\testingpackage.0.1.0.nupkg'
```

Great! Let's get into the Docker setup next.

## Docker Setup

Let's create a **Dockerfile** and **.dockerignore** in the directory with our *TestingPackage* directory.

```PowerShell
$ New-Item -Path Dockerfile -Type file
$ New-Item -Path .dockerignore -Type file
```

Open the *.dockerignore* file first and add the following to ignore any locally created NuGet packages.

```
*.nupkg
```

Finally, we can get to our Dockerfile. We start with the 4.8 runtime image, set a build argument to require your Chocolatey API key, and set our default shell to PowerShell. Then we install Chocolatey, copy our package, and switch to our working directory. Finally, we pack and push.

```Dockerfile
FROM mcr.microsoft.com/dotnet/framework/runtime:4.8

# Pass in your API Key
ARG CHOCO_API_KEY

# Set default shell to PowerShell
SHELL ["PowerShell", "-Command"]

# Install Chocolatey
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Copy over the package directory
COPY ./TestingPackage ./TestingPackage

# Work in the package directory
WORKDIR /TestingPackage

# Create the package
RUN choco pack

# Set API key and push package
RUN choco apikey -k $env:CHOCO_API_KEY -source https://push.chocolatey.org/ 
RUN choco push package-name.1.1.0.nupkg -s https://push.chocolatey.org/ 
```

You can run the below command to see if it works.

```PowerShell
$ docker build . --build-arg CHOCO_API_KEY=<Your API Key>
```

## Conclusion

This post was just something that I was thinking about, and I decided to bring everyone else along for the journey. 

Thanks for reading,

Jamie