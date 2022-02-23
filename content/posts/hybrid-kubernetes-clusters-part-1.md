---
title: "Hybrid Kubernetes Clusters Part 1"
date: 2022-02-22T20:33:16-05:00
tags:
- Kubernetes
- Windows
- Hybrid Clusters
- Guides
- Mixed Workloads
---

There are tons of articles about all aspects of Kubernetes. The one area that I don't feel gets enough coverage is all the considerations of the Kubernetes cluster that aren't uniform in the cluster operating system or architecture. These clusters are what people have been calling `hybrid` or `mixed workload` clusters. I prefer the `hybrid` designation. Let's define a hybrid cluster.

> **Hybrid Cluster**: A Kubernetes cluster that has nodes using multiple operating systems or architectures.

These clusters open up possibilities of optimizing different workloads based on the operating system or architecture and provide challenges. A great example would be if you needed to run a web application that runs on Windows Server and uses a SQL Server database. Microsoft SQL Server is only available as a Linux-based container so you would need at least a single Linux node to host the SQL Server container. There are other examples where you may have something that runs best on ARM64, so having a Linux ARM64 node along with a Linux AMD64 node may be the best solution. There are plenty of use cases for a hybrid cluster which I am glad we have that flexibility available.

There are some challenges when operating a hybrid cluster that needs to be considered. In my opinion, the two largest challenges all come down to deployment. Are their images available for my node operating system or architecture? If there aren't images available and my workload is scheduled on a node that isn't supported it will fail. The failure is typically an `ErrImagePull` which indicates that there is an error pulling the image due to an *unsupported* architecture or operating system. This leads exactly into the other challenge, if there aren't images then do the charts or manifests have `node selectors` or `node affinities` configured to prevent scheduling on unsupported node types? Usually, that answer to that is, not often. Many charts and manifests assume that the cluster only has a node type of Linux AMD64 which will cause a scheduling error. This is easily mitigated when consuming these if you are aware that you need to make the adjustment. Let's get into how to identify these scenarios before we even try to deploy.

## Are images available for my node type?

This one can be done using a browser, [Docker](https://www.docker.com/), or a tool like [Crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane). If using a browser you can navigate to a container registry, like Docker Hub, and view a tag to see what architectures and operating systems are supported. Using Crane it is just running the `manifest` command. Let's use Crane to take a look at a few images.

#### nginx Latest

Here is the crane command and the output is going to be JSON.

```Bash
crane manifest nginx:latest
```

I am just going to show the platform types from the JSON output. There are eight different combinations of architecture and operating systems supported by Nginx.

```JSON
{
  "manifests": [
    {
      "platform": {
        "architecture": "amd64",
        "os": "linux"
      }
    },
    {
      "platform": {
        "architecture": "arm",
        "os": "linux",
        "variant": "v5"
      }
    },
    {
      "platform": {
        "architecture": "arm",
        "os": "linux",
        "variant": "v7"
      }
    },
    {
      "platform": {
        "architecture": "arm64",
        "os": "linux",
        "variant": "v8"
      }
    },
    {
      "platform": {
        "architecture": "386",
        "os": "linux"
      }
    },
    {
      "platform": {
        "architecture": "mips64le",
        "os": "linux"
      }
    },
    {
      "platform": {
        "architecture": "ppc64le",
        "os": "linux"
      }
    },
    {
      "platform": {
        "architecture": "s390x",
        "os": "linux"
      }
    }
  ]
}
```

#### .NET SDK Latest

Let's look at an image that is going to have some different architectures and OSes listed that will include Windows.

```Bash
crane manifest mcr.microsoft.com/dotnet/sdk:latest
```

Notice that there is a new field in the platform section called `os.version`. This defines which version of the Windows container can be deployed.

```JSON
{
  "manifests": [
    {
      "digest": "sha256:e2f85f77cb925af2d854caca5f2537a3100fd1968a88dbe0be6877b42bdb8e4f",
      "platform": {
        "architecture": "amd64",
        "os": "linux"
      }
    },
    {
      "platform": {
        "architecture": "arm",
        "os": "linux",
        "variant": "v7"
      }
    },
    {
      "platform": {
        "architecture": "arm64",
        "os": "linux",
        "variant": "v8"
      }
    },
    {
      "platform": {
        "architecture": "amd64",
        "os": "windows",
        "os.version": "10.0.17763.2565"
      }
    },
    {
      "platform": {
        "architecture": "amd64",
        "os": "windows",
        "os.version": "10.0.19042.1526"
      }
    },
    {
      "platform": {
        "architecture": "amd64",
        "os": "windows",
        "os.version": "10.0.20348.524"
      }
    }
  ]
}
```

#### Haskell Latest

Haskell has a container image available that only supports a couple architectures and one OS, Linux.

```Bash
crane manifest gcr.io/go-containerregistry/crane:latest
```

Here is what is supported.

```JSON
{
  "manifests": [
    {
      "platform": {
        "architecture": "amd64",
        "os": "linux"
      }
    },
    {
      "platform": {
        "architecture": "arm64",
        "os": "linux",
        "variant": "v8"
      }
    }
  ]
}
```

## What do I do if my node type isn't supported?

We have looked into a few different images and we can see that the support varies widely between the three we looked at. Some don't support Windows and others don't support specific architectures for Linux. If we are running a hybrid cluster and one of our node types isn't present in that manifest we are probably going to run into an issue. There is a chance that Kubernetes will schedule the pod using that image to be deployed on the node that isn't supported. When that happens, that will cause a failure. We can prevent that by ensuring that we specify a [node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) or a [node affinity]https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) that can inform the Kubernetes scheduler when making decisions. Let's look at a few examples using the images above. [Here](https://kubernetes.io/docs/reference/labels-annotations-taints/) is the list of labels that you can use.

#### Nginx Latest

Since the `nginx:latest` image has a pretty comprehensive list of supported Linux architectures, we can do pretty well using a node selector.

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    kubernetes.io/os: linux
```

#### .NET SDK Latest

Now for something like the .NET SDK which has a few more options we can use an affinity. Let's say we have a hybrid cluster with Windows and Linux in both AMD64 and ARM64. However, we only want to deploy to AMD64 with a preference for Windows.

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: dotnet-sdk
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/arch
            operator: In
            values:
            - amd64
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: kubernetes.io/os
            operator: In
            values:
            - windows
  containers:
  - name: dotnet-sdk
    image: mcr.microsoft.com/dotnet/sdk:latest
```

## Wrapping Up

Hybrid clusters offer a lot of opportunities as long as you do a little planning in advance to understand what node types the workloads you plan to deploy support. If a node type isn't supported adding selectors or affinities to assist the scheduler is critical to ensuring that your deployments stay healthy. I plan to cover strategies to assist in each of these areas in more detail in additional posts.

Thanks for reading,

Jamie
