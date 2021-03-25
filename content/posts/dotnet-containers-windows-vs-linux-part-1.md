---
title: ".NET Containers: Windows vs. Linux Part 1"
date: 2021-03-24T21:15:27-04:00
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

This topic will be at least two parts, with the first part focusing on the developer experience of the two different container options for .NET. I haven't spent a lot of time looking at Windows containers for a couple of years. The biggest reason I have not spent much time with them was always due to the images' size. They always took longer to pull and deploy due to the size. I decided that I would like to look at the current state as a developer of the two different platforms. I am going to look at just two aspects, size and build time. These are two of the most significant factors from my point of view as a developer.

## Methodology

The following hardware executed all tests:

```
CPU: Ryzen 5 3600, 6 cores/12 threads
RAM: 32GB DDR4 3200Mhz RAM
SSD: 512GB NVMe Gen3 x4
 OS: Windows 10 20H2
```

I ran the latest version of Docker Desktop for Windows with WSL2 integration enabled with the default WSL2. I used the following [repo](https://github.com/phillipsj/dotnet-container-showdown) on GitHub with the following Dockerfile.

```Dockerfile
FROM mcr.microsoft.com/dotnet/sdk:5.0 as build

WORKDIR /src

COPY Example.sln .
COPY Example/Example.csproj ./Example/
RUN dotnet restore

COPY Example/. ./Example/

RUN dotnet publish -c release -o /app --no-restore

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:5.0

WORKDIR /app

COPY --from=build /app ./
ENTRYPOINT ["dotnet", "Example.dll"]
```

Sizes are taken directly from the output of the *docker images* command. Linux containers are built with BuildKit by default, and Windows containers don't support it.  So I executed the Linux container builds with both Buildkit enabled and disabled. Finally, since Windows containers don't support BuildKit, I measured the build times with the PowerShell *Measure-Command* commandlet averaging three runs. Here is precisely what I executed using the lastest PowerShell Core:

```PowerShell
Measure-Command { docker build . -t example:0.1.0 --no-cache | Out-Host }
```

I didn't have a custom WSL configuration in use, and I kept additional activities on the system to the minimum needed to perform the testing.

## Results

These are the results for looking at the default image size and build performance.

### Image Size

Here are the sizes of the default images for the SDK and ASP .NET runtime for Windows and Linux. I settled on just using the defaults as that is what most will probably do. Comparing the default images is fair, considering the .NET team chose these as the defaults for each platform.

.NET Info             | Container  | OS              | Size  | 
----------------------|------------|-----------------|-------|
.NET 5 SDK            | sdk:5.0    | NanoServer 20H2 | 840MB |
.NET 5 SDK            | sdk:5.0    | Debian 10       | 626MB |
.NET 5 ASPNET Runtime | aspnet:5.0 | NanoServer 20H2 | 352MB |
.NET 5 ASPNET Runtime | aspnet:5.0 | Debian 10       | 205MB |

I found it interesting that the SDK was only a 214MB difference. I expected that it would be much more significant, with the image being more than 1GB. The ASP .NET runtime image was even more surprising as it is only a 147MB difference which is fantastic and unexpected. That is a competitive size, in my opinion, and makes the size not a concern.

### Build Performance

Here are the build times with no-cache enabled and the images already pulled locally. As stated above, I ran the Linux container builds with both BuildKit enabled and disabled.

Platform     | BuildKit | Time (no cache) |
-------------|----------|-----------------|
Windows      | No       | 11.98s          |
Linux (WSL2) | No       | 8.92s           |
Linux (WSL2) | Yes      | 5.91s           |

The biggest takeaway is that if you are on Linux, you should be using BuildKit. Outside of that, when comparing builds without BuildKit, there is roughly a three-second difference on average. I want to run these on macOS and Linux on the same hardware to see if the WSL2 and filesystem-related penalties.

## Conclusion

From developer experience, I feel Windows containers have caught up to Linux containers in two of the biggest concerns. It does seem that Microsoft is listening and working on decreasing these gaps between the two. I would like to see BuildKit come for Windows containers and what difference that could make.

I have at least one more post planned to look at one more aspect.

Thanks for reading,

Jamie
