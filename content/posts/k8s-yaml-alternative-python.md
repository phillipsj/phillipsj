---
title: "K8s YAML Alternative: Python"
date: 2020-02-27T21:39:36-05:00
tags:
- YAML
- k8s
- Kubernetes 
- Python
---

In a previous set of posts I have shown examples using [JSON](https://www.phillipsj.net/posts/k8s-yaml-alternative-json/), [.NET](https://www.phillipsj.net/posts/k8s-yaml-alternative-dotnet/), [Terraform](https://www.phillipsj.net/posts/k8s-yaml-alternative-terraform/), and [Java](https://www.phillipsj.net/posts/k8s-yaml-alternative-java/) instead of YAML. This post is going to show another alternative using Python. I will be using the same Kubernetes object to allow comparison.

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

Now let's take a look at this in Python.

## Python

This example is going to leverage the [Kubernetes Client](https://github.com/kubernetes-client/python/) for Python. Let's create a basic Python application.

```bash
$ mkdir k8spython && cd k8spython
$ touch create_pod.py
```

I will be using a virtual environment.

```bash
$ python3 -m venv .venv
$ source .venv/bin/activate
```

Now we can install the Kubernetes client.

```bash
$ pip install kubernetes
```

Now we can set up our client, create our object, and execute the Python.

```python
from kubernetes import client, config
from kubernetes.client.models import V1Pod, V1ObjectMeta, V1Container, V1PodSpec

def create_pod():
    config.load_kube_config()

    v1 = client.CoreV1Api()

    pod=client.V1Pod()
    pod.metadata=client.V1ObjectMeta(name="busybox-python")

    container=client.V1Container(name="busybox", image="busybox", image_pull_policy="IfNotPresent")
    container.args=["sleep", "3600"]

    spec=client.V1PodSpec(containers=[container], restart_policy="Always")
    pod.spec = spec

    v1.create_namespaced_pod(namespace="default",body=pod)
    print("Pod deployed.")


if __name__ == "__main__":
    create_pod()
```

Now we can execute our Python app.

```bash
$ python create_pod.py
Pod deployed.
```

Now, if we get all pods, we should see it running.

```bash
$ kubectl get pods
NAME                READY   STATUS    RESTARTS   AGE
busybox-python      1/1     Running   0          20m
```  

Don't forget to clean up your cluster by deleting the object.

```bash
$ kubectl delete pod busybox-python
pod "busybox-python" deleted
```

## Wrap Up

The key take away from this is that you don't have to use YAML. As with any markup, an excellent tool goes a long way in making it more manageable. If you are already using Python in your environment, then I would recommend you trying out the Kubernetes client to see if it meets your needs or not. Combine this approach with something like [mypy](http://mypy-lang.org/), and you would have a solid choice.

Stay tuned for more alternatives.

Thanks for reading,

Jamie
