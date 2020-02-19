---
title: "K8s YAML Alternative: Terraform"
date: 2020-02-17T20:39:36-05:00
tags:
- YAML
- k8s
- Kubernetes 
- Java
---

In a previous set of posts I have shown examples using [JSON](https://www.phillipsj.net/posts/k8s-yaml-alternative-json/), [.NET](https://www.phillipsj.net/posts/k8s-yaml-alternative-dotnet/), and [Terraform](https://www.phillipsj.net/posts/k8s-yaml-alternative-terraform/) instead of YAML. This post is going to show another alternative using Java. I will be using the same Kubernetes object to allow comparison.

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

Now let's take a look at this in Java.

## Java

This example is going to leverage the [Kubernetes Client](https://www.terraform.io/docs/providers/kubernetes/index.html) for Java. Let's create a basic Java console application.

```bash
$ 
```

Now we can setup our client, create our object, and execute the Java.

```java
package net.phillipsj.k8sjava;

import io.kubernetes.client.openapi.ApiClient;
import io.kubernetes.client.openapi.ApiException;
import io.kubernetes.client.openapi.Configuration;
import io.kubernetes.client.openapi.apis.CoreV1Api;
import io.kubernetes.client.openapi.models.V1Pod;
import io.kubernetes.client.openapi.models.V1PodBuilder;
import io.kubernetes.client.util.Config;

import java.io.IOException;

public class Main {

    public static void main(String[] args) throws IOException, ApiException {
        ApiClient client = Config.defaultClient();
        Configuration.setDefaultApiClient(client);

        CoreV1Api api = new CoreV1Api();

        V1Pod pod =
                new V1PodBuilder()
                        .withNewMetadata()
                        .withName("busybox-java")
                        .endMetadata()
                        .withNewSpec()
                        .addNewContainer()
                        .addToCommand("sleep", "3600")
                        .withImage("busybox")
                        .withImagePullPolicy("IfNotPresent")
                        .withName("busybox")
                        .endContainer()
                        .withRestartPolicy("Always")
                        .endSpec()
                        .build();

        api.createNamespacedPod("default", pod, null, null, null);
    }
}
```

Now, if we get all pods, we should see it running.

```bash
$ kubectl get pods 
NAME              READY   STATUS    RESTARTS   AGE
busybox-java      1/1     Running   0          30m
```  

Don't forget to clean up your cluster by deleting the object.

```bash
$ kubectl delete pod busybox-java
pod "busybox-java" deleted
```

## Wrap Up

The key take away from this is that you don't have to use YAML. As with any markup, an excellent tool goes a long way in making it more manageable. If you are already using Java in your environment, then I would recommend you trying out the Kubernetes client to see if it meets your needs or not. I am not a big fan of Java, I do have to save the builder syntax is pretty nice. You don't have to use the builder syntax if you don't want. 

Stay tuned for more alternatives.

Thanks for reading,

Jamie
