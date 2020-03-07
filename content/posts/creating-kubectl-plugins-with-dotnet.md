---
title: "Creating Kubectl Plugins With .NET"
date: 2020-03-07T12:57:16-05:00
tags:
- .NET 
- .NET Core
- Microsoft
- Open Source
- Kubernetes
- kubectl
- kubectl-plugins
---

[Kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) is the CLI tool for working with the [Kubernetes](https://kubernetes.io/) API. [Kubectl plugins](https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/) provide us a way to extend the Kubectl to include more complex commands or enhanced functionality. There are two requirements for creating a plugin, and the requirements are as follows.

1. Must be named **kubectl-<plugin-name>**.
2. Must be on your path.

I would guess that golang is one of the more popular choices for creating plugins. Any language that can create a single executable binary would be a great choice as it makes it easier to manage and distribute. Depending on the type of plugin you are developing, choosing a language that has a [Kubernetes Client](https://kubernetes.io/docs/reference/using-api/client-libraries/) would be wise too. Traditionally, .NET isn't a language that comes to mind when speaking about producing a single executable binary. As .NET Core has gained momentum, the ability has been introduced with the latest 3.1 release to support creating a single executable binary. In this post I will show you how to use .NET Core 3.1 to create a plugin for Kubectl. Let's get started.

## Creating the plugin

I am assuming you have .NET Core installed. If not, head to the official site. I will be doing this on Linux. Let's create our .NET Core console application.

```bash
$ dotnet new console -o kubectl-dotnet && cd kubectl-dotnet
The template "Console Application" was created successfully.

Processing post-creation actions...
Running 'dotnet restore' on kubectl-dotnet/kubectl-dotnet.csproj...
  Restore completed in 149.95 ms for ../code/kubectl-dotnet/kubectl-dotnet.csproj.

Restore succeeded.
```

Now let's open our project file called *kubectl-dotnet.csproj* and add the following to the *PropertyGroup*.

```xml
<PublishTrimmed>true</PublishTrimmed>
<PublishReadyToRun>true</PublishReadyToRun>
<PublishSingleFile>true</PublishSingleFile>
```

Let's do a quick recap of what each of these properties provides. The *PublishedTrimmmed* performs tree shaking on your code and removes any unused assemblies, making your executable smaller. The *PublishReadyToRun* allows a form of ahead-of-time or AOT compilation. This allows shipping of some native code along with the IL reducing the work of the JIT compiler. The final settings, *PublishSingleFile* says that we one want a single executable binary. Here is what the complete project file should look like once added.

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>netcoreapp3.1</TargetFramework>
    <RootNamespace>kubectl_dotnet</RootNamespace>
    <PublishTrimmed>true</PublishTrimmed>
    <PublishReadyToRun>true</PublishReadyToRun>
    <PublishSingleFile>true</PublishSingleFile>
  </PropertyGroup>

</Project>
```

Now let's open up the *Program.cs* and make a small change to the line we are going to write out to the console.

```csharp
using System;

namespace kubectl_dotnet {
    class Program {
        static void Main(string[] args) {
            Console.WriteLine("Hello from the .NET Core plugin!");
        }
    }
}
```

Great, we a straightforward plugin. We can finally compile it, which will require us to specify the runtime identifier of our target OS. In this case, the target OS will be Linux x64.

```bash
$ dotnet publish -c Release --runtime linux-x64
Microsoft (R) Build Engine version 16.4.0+e901037fe for .NET Core
Copyright (C) Microsoft Corporation. All rights reserved.

  Restore completed in 42.04 ms for ../code/kubectl-dotnet/kubectl-dotnet.csproj.
  kubectl-dotnet -> ../code/kubectl-dotnet/bin/Release/netcoreapp3.1/linux-x64/kubectl-dotnet.dll
  Optimizing assemblies for size, which may change the behavior of the app. Be sure to test after publishing. See: https://aka.ms/dotnet-illink
  Some ReadyToRun compilations emitted warnings, indicating potential missing dependencies. Missing dependencies could potentially cause runtime failures. To show the warnings, set the PublishReadyToRunShowWarnings property to true.
  kubectl-dotnet -> ../code/kubectl-dotnet/bin/Release/netcoreapp3.1/linux-x64/publish/
```

That's it, and we now have a plugin built with .NET.

## Testing the plugin

Our plugin is sitting in the **bin/Release/netcoreapp3.1/linux-x64/publish/** directory. We need to move this to a location that is on our path. Since I am on Kubuntu Linux, I will move this to the local bin directory in my home directory.

```bash
$ mv bin/Release/netcoreapp3.1/linux-x64/publish/kubectl-dotnet ~/.local/bin
$ ls ~/.local/bin
kubectl-dotnet
```

Now let's see if this plugin works. We can start by running the kubectl command to list plugins.

```bash
$ kubectl plugin list
~/.local/bin/kubectl-dotnet
```

The plugin was identified, now we can try to execute it.

```bash
$ kubectl dotnet
Hello from the .NET Core plugin!
```

Awesome! We successfully created a plugin using .NET Core.

## Distributing the plugin

We now have a plugin that is a single executable binary, and we want to share it with others. We could provide it, and the user could place it on their path. However, that approach isn't sustainable, and luckily there is a project that makes this easier called [Krew](https://krew.sigs.k8s.io/). You can create the YAML for your project and submit it to the [krew-index](https://github.com/kubernetes-sigs/krew-index/tree/master/plugins) which will allow users to install it using Krew.

## Conclusion

It's nice to know there are options out there for creating Kubectl plugins. One doesn't have to use golang, and knowing that you can use a language that you are comfortable with helps ease the transition with extending tools. .NET Core has dramatically improved over the last couple of years to get to this point.

Thanks for reading,

Jamie
