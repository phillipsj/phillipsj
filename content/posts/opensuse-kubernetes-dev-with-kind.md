---
title: "openSUSE Kubernetes Dev With kind"
date: 2020-12-29T21:29:40-05:00
tags:
- Open Source
- Linux
- openSUSE
- DevOps
- Kubernetes
- Arkade
- Kind
---

Yesterday I discussed getting openSUSE configured for doing DevOps and Kubernetes work. I ended with settling on [kind](https://kind.sigs.k8s.io/) as my solution for a local Kubernetes cluster. I have done a little research. It seems back in April, and there were some issues around kind and Btrfs, which has been closed with a fix. All that is left now is to create a cluster and deploy something to make sure that it works. Let's jump in.

## Configuring and Exploring the Cluster

The first step is to create our cluster.

```Bash
$ kind create cluster
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.19.1) 🖼 
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
```

Awesome! It's up and running and consuming about 500MB of RAM, which isn't all that intensive. Let's check out what our system looks like now. Let's first set our context, so we don't have to pass it in continually.

```Bash
$kubectl config set-context kind-kind
Context "kind-kind" modified.
```

Now we can run cluster-info without having to pass the context.

```Bash
$ kubectl cluster-info
Kubernetes master is running at https://127.0.0.1:45145
KubeDNS is running at https://127.0.0.1:45145/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

We can also check out what pods we have running on our entire cluster.

```Bash
$ kubectl get pods -A
NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE
kube-system          coredns-f9fd979d6-vkkv2                      1/1     Running   0          6m25s
kube-system          coredns-f9fd979d6-zz4lk                      1/1     Running   0          6m25s
kube-system          etcd-kind-control-plane                      1/1     Running   0          6m29s
kube-system          kindnet-dsq6j                                1/1     Running   0          6m25s
kube-system          kube-apiserver-kind-control-plane            1/1     Running   0          6m29s
kube-system          kube-controller-manager-kind-control-plane   1/1     Running   0          6m29s
kube-system          kube-proxy-mtmbm                             1/1     Running   0          6m25s
kube-system          kube-scheduler-kind-control-plane            1/1     Running   0          6m29s
local-path-storage   local-path-provisioner-78776bfc44-56t2c      1/1     Running   0          6m25s
```

It looks like it's using CoreDNS along kindnet for CNI and a local file provisioner. Everything else seems fairly typical. This is a pretty nice little setup for doing local development against Kubernetes.

## Deploying an App

We have a working cluster at this point, yet the configuration isn't complete for what we need to do. We will first need to delete the cluster.

```Bash
$ kind delete cluster
```

Now create a *kind.yaml* file that will be the configuration for our cluster and paste what is below there. This will tell kind to map the port 6000 on the host to the ingress controller port.

```YAML
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 6000
    protocol: TCP
```

Let's create a new cluster with the config.

```Bash
$ kind create cluster --config kind.yaml
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.19.1) 🖼
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Have a nice day! 👋
```

Now that the cluster is up, we can add our Nginx Ingress controller.

```Bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
```

We need to check that our ingress controller is running.

```Bash
$ kubectl get pod  --namespace ingress-nginx 
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-gq5tp        0/1     Completed   0          46s
ingress-nginx-admission-patch-g7n4p         0/1     Completed   0          46s
ingress-nginx-controller-55dccbb989-jzp6m   1/1     Running     0          46s
```

It looks like it's working. We can now deploy an app to test. We will use an echo server to keep it simple. Create *hello.yaml* with the following code.

```YAML
kind: Pod
apiVersion: v1
metadata:
  name: hello-app
  labels:
    app: hello
spec:
  containers:
  - name: hello-app
    image: hashicorp/http-echo:0.2.3
    args:
    - "-text=Hello from a kind cluster."
---
kind: Service
apiVersion: v1
metadata:
  name: hello-service
spec:
  selector:
    app: hello
  ports:
  # Default port used by the image
  - port: 5678
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: hello-ingress
spec:
  rules:
  - http:
      paths:
      - path: /hello
        backend:
          serviceName: hello-service
          servicePort: 5678
```

Apply *hello.yaml* to create our objects.

```Bash
$ kubectl apply -f hello.yaml 
pod/hello-app created
service/hello-service created
ingress.networking.k8s.io/hello-ingress created
```

All that is left is to call it.

```Bash
$ curl localhost:6000/hello
Hello from a kind cluster.
```

It works!

## Conclusion

I hope that you found this useful. One limitation that I am aware of that I wasn't originally is that these clusters are not persistent. My understanding is that it's by design for testing Kubernetes. In some ways, this is good as it will require you to push more of your setup into a single manifest to script it out, which is good. It can be frustrating to run through these steps every time.

Thanks for reading,

Jamie
