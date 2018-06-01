---
Title: ".NET Core: Application Publishing Overview"
Published: 05/31/2018 21:18:34
Tags: 
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
---
# .NET Core: Application Publishing

In this post I am not going to spend much time discussing publishing for Windows, there are a few options and most are understood.  What I will be focusing on, as an overview, are publishing solutions that are for other platforms.  

When it comes to cross platform publishing there are a few options:

1. Require .NET runtime to be installed. Then the user can just execute your app. This is called [Framework-dependent Deployments](https://docs.microsoft.com/en-us/dotnet/core/deploying/index#framework-dependent-deployments-fdd) with the short hand *FDD*.
2. Publish the runtime with your app, this creates a larger package and still may require dependencies to still be installed. This is called [Self-contained Deployments](https://docs.microsoft.com/en-us/dotnet/core/deploying/index#self-contained-deployments-scd) with the short hand *SCD*.
3. Native builds with [CoreRT](https://github.com/dotnet/corert). Now this option creates a native executable which is small and super fast because there is no JITing occurring. This requires building a specific executable for each OS platform.

When it comes to Linux you have a few additional options that alleviate issues with options 1 and 2. That would be using either [Flatpak](https://flatpak.org/) or [snap](https://snapcraft.io/) to package. Both of these options allow you to bundle all requirements including the runtime and any additional dependencies in an isolated package not effecting the user's system. What is extremely nice about these options are users will not even know it is a .NET based application which may help with adoption.

Native builds are relatively new and the CoreRT project is still in alpha phase. I have been using it for the past couple of weeks testing out some CLI apps and it has been working flawlessly. There isn't cross platform support so you have to build on the platform that you are targeting. There are also a few dependencies that have to be installed to get it all to work. I have been performing those builds on the [WSL](https://docs.microsoft.com/en-us/windows/wsl/about) using the [Ubuntu 18.04](https://www.microsoft.com/en-us/p/ubuntu-1804/9n9tngvndl3q) image. Now if we could get a *Windows Subsystem for Mac*, which would be nice in this use case.

Over the following month or so I will cover most of these options. I will also be pushing up examples to GitHub.

Thank you for reading.

