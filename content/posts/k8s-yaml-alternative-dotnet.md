---
title: "K8s YAML Alternative: .NET"
date: 2020-02-15T21:39:36-05:00
tags:
- YAML
- k8s
- Kubernetes
- .NET
---

In a previous [post](https://www.phillipsj.net/posts/k8s-yaml-alternative-json/) I showed how to use JSON instead of YAML. This post is going to show another alternative using .NET. This example will be displayed using both C# and F#. I will be using the same Kubernetes object to allow comparison.

## YAML Object

We are going to create a busybox pod. This manifest isn't a super simple example, nor is it a complex example. This manifest should allow demonstrating the differences. Here is the pod YAML.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  containers:
  - image: busybox
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
    name: busybox
  restartPolicy: Always
```

Now we can save this as *busybox.yaml* and create it on our cluster. 

```bash
$ kubectl apply -f busybox.yaml
pod/busybox created
```

Now let's take a look at this in JSON.

## C# Object

This example is going to leverage the official [Kubernetes Client for .NET](https://github.com/kubernetes-client/csharp). Let's create a C# project and install the Kubernetes client for .NET.

```bash
$ dotnet new console -o k8scsharp && cd k8scsharp
$ dotnet add package KubernetesClient
```

Now we can connect our client, create our object, and deploy the object.

```csharp
using System;
using System.Collections.Generic;
using k8s;
using k8s.Models;

namespace k8scsharp {
    class Program {
        static void Main(string[] args) {
            var config = KubernetesClientConfiguration
                .BuildConfigFromConfigFile(Environment.GetEnvironmentVariable("KUBECONFIG"));
            var client = new Kubernetes(config);

            var pod = new V1Pod() {
                ApiVersion = "v1",
                Kind = "Pod",
                Metadata = new V1ObjectMeta {
                    Name = "busybox-cscharp"
                },
                Spec = new V1PodSpec() {
                    Containers = new List<V1Container>() {
                        new V1Container() {
                            Image = "busybox",
                            Command = new List<string>() {
                                "sleep",
                                "3600"
                            },
                            ImagePullPolicy = "IfNotPresent",
                            Name = "busybox"
                        }
                    },
                    RestartPolicy = "Always"
                }
            };

            client.CreateNamespacedPodWithHttpMessagesAsync(pod, "default").Wait();
            Console.WriteLine("Pod deployed.");
        }
    }
}
```

Now run this application with *dotnet run*, and you should have a pod in our cluster.

```bash
$ dotnet run
Pod deployed
```

Now, if we get all pods, we should see it running.

```bash
$ kubectl get pods 
NAME              READY   STATUS    RESTARTS   AGE
busybox-cscharp   1/1     Running   0          30m
```  

Let's clean up before we wrap up.

```bash
$ kubectl delete pod busybox-cscharp
pod "busybox-cscharp" deleted
```

## F# Object

Now we can create a new F# project and install the Kubernetes client for F#.

```bash
$ dotnet new console -lang F# -o k8sfsharp && cd k8sfsharp
$ dotnet add package KubernetesClient
```

Now we can connect our client, create our object, and deploy the object.

```fsharp
open System.Collections.Generic
open System
open k8s
open k8s.Models

[<EntryPoint>]
let main argv =
    let client =
        Environment.GetEnvironmentVariable("KUBECONFIG")
        |> KubernetesClientConfiguration.BuildConfigFromConfigFile
        |> fun config -> new Kubernetes(config)

    let command = (Array.ofList [ "sleep"; "3600" ]) :> IList<string>
    let containers =
        (Array.ofList
            [ V1Container(image = "busybox", command = command, imagePullPolicy = "IfNotPresent", name = "busybox") ])
        :> IList<V1Container>
    let pod =
        V1Pod
            (apiVersion = "v1", kind = "Pod", metadata = V1ObjectMeta(Name = "busybox-fscharp"),
             spec = V1PodSpec(containers = containers, restartPolicy = "Always"))
            
    client.CreateNamespacedPodWithHttpMessagesAsync(pod, "default").Wait()
    printfn "Pod deployed."
    0 // return an integer exit code
```

Now run this application with *dotnet run*, and you should have a pod in our cluster.

```bash
$ dotnet run
Pod deployed
```

Now, if we get all pods, we should see it running.

```bash
$ kubectl get pods 
NAME              READY   STATUS    RESTARTS   AGE
busybox-fscharp   1/1     Running   0          30m
```  

Let's clean up before we wrap up.

```bash
$ kubectl delete pod busybox-fscharp
pod "busybox-fscharp" deleted
```

## Wrap Up

The key take away from this is that you don't have to use YAML. YAML does save eight lines of code and over a complex manifest that can add up. As with any markup, an excellent tool goes a long way in making it more manageable. If .NET if your framework on of choice, then you can comfortably use C# or F# to create your Kubernetes objects. Combine this approach with a tool like Cake, Nuke, Bullseye, etc. and you can have an excellent deployment tool using the same tools that you create applications using.

Stay tuned for more alternatives.

Thanks for reading,

Jamie
