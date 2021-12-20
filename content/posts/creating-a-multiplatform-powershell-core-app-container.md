---
title: "Creating a Multiplatform Powershell Core App Container"
date: 2021-12-20T16:16:43-05:00
tags:
- Open Source
- PowerShell
- PowerShell Containers
- Microsoft And Linux
- Containers
- Docker
---

Having consistent tools makes debugging issues across Linux and Windows easier. PowerShell Core is that tool for the job, in my opinion. It can run on both Windows and Linux, which makes it a good candidate for building debugging tools, and keeping it all one thing reduces the cognitive overload.

The PowerShell team produces Core images for Windows and Linux. There are only two tags that exist are multiplatform, which are LTS and Latest tags. Unfortunately, they use Server Core instead of Nano Server for the base, at least on Windows. I want the smallest possible images, which means using Nano Server requires a touch more setup on my side.

Now that I need to do the extra work to make changes for the Windows side, I will also change the Linux side to leverage Alpine. 

## Basic Dockerfile

Here is our basic Dockerfile using the LTS tag.

```
FROM mcr.microsoft.com/powershell:lts

CMD ["pwsh", "-Command", "Get-Uptime"]
```

The first step is to add an ARG to our Dockerfile called `BASE`. Then we will change our tag from latest to using our build arg.

```
ARG BASE
FROM mcr.microsoft.com/powershell:${BASE}

CMD ["pwsh", "-Command", "Get-Uptime"]
```

## Tagging

The last step is to leverage a tagging standard and create our manifest for multiplatform support.

I suggest the following tagging standard for Linux:

```
<app version>-<os>-<architrctiture>
```

Linux example:

```
v1.0-linux-amd64
```

The Windows standard needs to add the OS version. 

```
<app version>-<os>-<os version>-<architecture>
```

Windows 2022 example:

```
v1.0-windows-ltsc2022-amd64
```

## Building

When we run our build, we will pass a build arg to it specifying which base image we would like to use based on OS and our tag using our naming standard above.

```Bash
# Linux
docker build --build-arg BASE=alpine-3.14 \
    -t phillipsj/myapp:v0.0.1-linux-amd64 .
    
docker push phillipsj/myapp:v0.0.1-linux-amd64

# Windows 2019
docker build --build-arg BASE=nanoserver-1809 \
    -t phillipsj/myapp:v0.0.1-windows-ltsc2019-amd64 .

docker push phillipsj/myapp:v0.0.1-windows-ltsc2019-amd64

# Windows 2022
docker build --build-arg BASE=nanoserver-ltsc2022 \
    -t phillipsj/myapp:v0.0.1-windows-ltsc2022-amd64 .
    
docker push phillipsj/myapp:v0.0.1-windows-ltsc2022-amd64
```

## Bringing it all together with the Manifest

Then we can create our manifest, which we will push tag as just version, and we will amend the images we built above. Let's make our manifest now.

```
docker manifest create phillipsj/myapp:v0.0.1 \
    --amend phillipsj/myapp:v0.0.1-linux-amd64 \
    --amend phillipsj/myapp:v0.0.1-windows-ltsc2019-amd64 \
    --amend phillipsj/myapp:v0.0.1-windows-ltsc2022-amd64
```

Next, we need to annotate our different versions to our manifest. 

```
export DOCKER_CLI_EXPERIMENTAL=enabled

docker manifest annotate --os windows --arch amd64 \
    --os-version "10.0.17763.1817" \
    phillipsj/myapp:v0.0.1 phillipsj/myapp:v0.0.1-windows-ltsc2019-amd64

docker manifest annotate --os windows --arch amd64 \
    --os-version "10.0.20348.169"\
    phillipsj/myapp:v0.0.1 phillipsj/myapp:v0.0.1-windows-ltsc2022-amd64
```

The last thing we need to do is push our manifest to our registry.

```
docker manifest push phillipsj/myapp:v0.0.1
```

Now we have a PowerShell Core App with multiplatform support leveraging the smallest official bases provided by upstream. We can use the following manifest without worrying about specifying our platform image.

```Bash
# On any supported platform in the manifest
docker pull phillipsj/myapp:v0.0.1
docker run --rm phillipsj/myapp:v0.0.1
```

## Wrapping Up

Now we can deploy the same app or tools using the same technology to both Windows and Linux Kubernetes nodes to make debugging less difficult.

Thanks for reading,

Jamie

