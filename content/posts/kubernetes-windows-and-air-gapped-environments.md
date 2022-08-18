---
title: "Kubernetes, Windows, and Air-gapped Environments"
date: 2022-08-18T02:37:47Z
tags:
- Open Source
- Kubernetes
- Windows
- Air-gapped
- Docker
- Crane
---

Air-gapped environments are always challenging to build solutions. Ensuring that you have all the dependencies documented and available is challenging enough for a simple application. More complex solutions like a container management platform for Kubernetes increases that challenge by 20-fold. 

You have to ensure that you have an OCI registry available, a certificate authority, and a list of images that both the platform and any applications are going to require. That gets even more complex if you have multiple architectures and/or multiple operating systems. That can easily grow your storage requirements and loading time exponentially. This challenge is further increased by having to get all the images on a disk to then get them inside the air-gapped environment. I am going to focus on what needs to be considered when preparing to support Windows in this scenario. 

## Loading Images

This one is extra tricky when it comes to Windows. The choice of tooling can make this a challenge and the trickiest part comes down to the [foreign layers](https://docs.microsoft.com/en-us/virtualization/windowscontainers/about/faq#how-do-i-make-my-container-images-available-on-air-gapped-machines-) that are often in Microsoft base images. These foreign layers are pulled from the Microsoft MCR regardless if you are using your registry. This means that you will need to process all Windows images with care. Many tools handle this in different ways and we will cover this with both [Crane](https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane.md) and [Docker](https://www.docker.com). Both have the necessary options for working with foreign layers. The biggest difference is that Crane doesn’t require you to use Windows to do the work whereas Docker has difficulties if the image doesn’t match the host. This also comes into play since you need often pull multiple Windows versions.

### Using Docker 

When you are using Docker you need to ensure that you set the `allow-nondistributable-artifacts` in the Docker *daemon.json* file. Here is an example:

```JSON
{
 "allow-nondistributable-artifacts": ["myairgapregistry.com"]
}
```

Once that is configured, restart Docker, then pull your image.

```Bash
docker pull mcr.microsoft.com/windows:ltsc2022

docker tag mcr.microsoft.com/windows:ltsc2022 myairgapregistry.com/windows:ltsc2022

docker push myairgapregistry.com/windows:ltsc2022
```

All of this assumes that you are running on Windows machine. Here is a list of other articles with more information about the topic.

* https://goharbor.io/docs/2.1.0/working-with-projects/working-with-images/pulling-pushing-images/#pushing-windows-images
* https://docs.docker.com/engine/reference/commandline/dockerd/#allow-push-of-nondistributable-artifacts
* https://docs.docker.com/registry/deploying/#considerations-for-air-gapped-registries

### Using Crane

Crane is an awesome tool for working with container images. It provides a ton of functionality like the ability to work with images regardless of architecture or operating system. It also supports working with the different versions of Windows containers. Crane supports the ability to work with foreign layers also. 

Let’s look at an example:

```Bash
crane pull mcr.microsoft.com/windows:ltsc2022 windowlstc2022 /
 --allow-nondistributable-artifacts /
 --platform windows/amd64 

crane push windowlstc2022 myairgapregistry.com/windows:ltsc2022 /
 --allow-nondistributable-artifacts /
 --platform windows/amd64 
```

## Certificates

Certificates are tricky anyway and this is compounded by the fact that many Linux distros ship with many CAs included like Let’s Encrypt. Windows doesn’t so using a CA that would require Windows to dial out to verify isn’t going to work well. Keep this in mind when testing and validating environments.

## Wrapping Up

I hope you found this useful. This is just a really quick post that covers some of the areas that you need to consider when creating an air-gapped environment and you are using Windows and Windows containers. If you have any questions please reach out on GitHub or LinkedIn.

Thanks for reading,

Jamie
