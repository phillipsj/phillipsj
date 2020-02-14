---
title: "K8s YAML Alternative: JSON"
date: 2020-02-13T21:39:36-05:00
tags:
- YAML
- k8s
- Kubernetes 
---

There seems to be a lot of dislike of YAML circling lately in tech social media channels. It wasn't until I started using YAML regularly that I started enjoying it. The [YAML Essentials](https://linuxacademy.com/course/yaml-essentials/) course on [Linux Academy](https://linuxacademy.com) was the exposure that I needed to get me over that hump. The *aha moment* for me was when I finally realized how it parses to JSON. After that, I had a much easier time creating it. 

Kubernetes makes heavy use of YAML for declaring resources. The YAML is parsed and sent to an API as JSON. This transformation means that you can also leverage JSON to define and create resources in Kubernetes. We are going to look at a basic example of a Kubernetes object in YAML. We then will produce the same object in JSON and deploy it, demonstrating that these formats are interchangeable.

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

## JSON Object

This example should look very familiar, just the above, with a few more curly braces and brackets.

```json
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "busybox-json"
  },
  "spec": {
    "containers": [
      {
        "image": "busybox",
        "command": [
          "sleep",
          "3600"
        ],
        "imagePullPolicy": "IfNotPresent",
        "name": "busybox"
      }
    ],
    "restartPolicy": "Always"
  }
}
```

Save this as *busybox.json* and create it in our cluster.

```bash
$ kubectl apply -f busybox.json 
pod/busybox-json created
```

Now, if we get all pods, we should see both running.

```bash
$ kubectl get pods 
NAME           READY   STATUS    RESTARTS   AGE
busybox        1/1     Running   0          14m
busybox-json   1/1     Running   0          3m6s
```  

Let's clean up before we wrap up.

```bash
$ kubectl delete -f busybox.yaml -f busybox.json
pod "busybox" deleted
pod "busybox-json" deleted
```

## Wrap Up

The key take away from this is that you don't have to use YAML. YAML does save eight lines of code and over a complex manifest that can add up. As with any markup, an excellent tool goes a long way in making it more manageable. JSON has existed longer, and the tools are a little more mature in that respect. If you don't like YAML, at least in Kubernetes, you don't have to use it. If you use JSON then you can leverage all kinds of tools for generating templates and still use *kubectl*.

Stay tuned for more alternatives.

Thanks for reading,

Jamie
