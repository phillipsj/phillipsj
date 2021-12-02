---
title: "Creating Windows Container Images Without Docker"
date: 2021-11-30T20:15:32-04:00
tags:
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
- .NET
- Containers
- Docker
- Kubernetes
- Windows Containers
---

[Crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane) is a tool created by Google for working with images and registries. Crane has a lot of excellent functionality, and the one that is the most interesting is the [append](https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane_append.md) command. With the append command, we can add a layer to a container image. This feature means that we can create a layer with our application and append it to an existing base image. What this does is allow us to create a container regardless of the OS or requiring Docker. Let's see how that is accomplished by adding a .NET App to the ASP .NET Runtime Nano server 2022 image on a Linux workstation. You can install Crane as a binary or run:

```
go install github.com/google/go-containerregistry/cmd/crane@latest
```

## Example .NET App

First, we need to create a new ASP .NET application using the dotnet CLI.

```Bash
dotnet new mvc --output craneapp
```

Now let's publish the application to generate our compiled application.

```Bash
cd craneapp/
dotnet publish -c release -o ./app
```

We have a project published to the `app` directory that we can bundle for adding to the base image.

## Creating the bundle

The bundle required for the append command is a tar file. On Linux, that could be a tar of the output of the publish command. However, on Windows, the layers are required to have a specific structure. Windows Layers are required to have a Files and a Hives directory. Inside of the Files directory is where you would place your published output. Then those directories need to be bundled together in a tar file. Fortunately, the lastest crane handles that complexity for us so we can just tar up our app directory.

```Bash
# creating the tar file
tar -cf layer.tar app/
```

We should have a *layer.tar* file in our that we can use when we run the crane command to create our image.

## Appending

The Crane append command, by default, wants to push to a registry. I am using Docker Hub, so log into your registry first before executing the append command. Let's run the append making sure to set our base image, `mcr.microsoft.com/dotnet/aspnet:6.0-nanoserver-ltsc2019`.

```Bash
crane append /
--platform=windows/amd64 /
-f layer.tar /
-t phillipsj/craneapp:0.1.0 /
-b mcr.microsoft.com/dotnet/aspnet:6.0-nanoserver-ltsc2019
```

Once that finishes, we should have an image in Docker Hub. However, we are missing our entry point; fortunately, crane doesn't currently support mutating the entry point for Windows images. That means we will have to pass an entry point when executing the command which Kubernetes and Docker support.

## Executing on Windows

Okay, I have switched to my Windows box with Docker Desktop running Windows containers. Let's pull the image and run it.

```Bash
docker run -it -p 5000:80 phillipsj/craneapp:0.1.0 dotnet craneapp.dll
```

Now we can navigate to the app in our browser to make sure it works. You should see the default app at `http://localhost:5000`. 

## Wrapping Up

This capability is way cool and allows the creation of Windows container images without needing Docker Desktop or a Dockerfile. The append command does require that you are using something that doesn't require compilation in a container. Go, .NET, Java, JS, Python, and others will work just fine as long as you choose the appropriate base image. This command will not work if you need to leverage IIS and do a feature installation as that requires modifying the base Windows OS, not just adding your application files. Append also opens up a lot of other scenarios, like being able to build your Windows containers on Linux CI servers.

Thanks for reading,

Jamie
