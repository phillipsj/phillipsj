---
title: "K3s: Enable NFS Storage"
date: 2021-08-03T20:40:26-04:00
tags:
- YAML
- k8s
- Kubernetes
- K3s
- Kubernetes Storage
---

Today, I had a few people ping me about someone who was frustrated configuring a [K3s](https://k3s.io/) cluster to enable [NFS](https://kubernetes.io/docs/concepts/storage/storage-classes/#nfs) storage provisioner. Out of the box, K3s ships with the [local path](https://github.com/rancher/local-path-provisioner) storage provisioner, which uses storage local to the node. If you want storage that can be shared across multiple nodes if you are running them, you will need to use a different solution which the NFS storage provisioner is one of them. I like the aspects of the dynamic provisioning provided by [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes) and how it describes the different storage options, so that is what the focus of this post will be. If you want to follow along, you will need a VM or a Raspberry PI running K3s and an [NFS server](https://doc.opensuse.org/documentation/leap/reference/html/book-reference/cha-nfs.html) serving your storage. I will be building the K3s with a local VM running [openSUSE](https://get.opensuse.org) Leap 15.3. This should work the same with other Linux operating systems. Let's get started with installing K3s. I will be using my QNAP NAS as my NFS Server as it is convenient.

#### Watch out

K3s ships with Kubernetes components that rely on the apparmor parser library if apparmor is enabled in the kernel. openSUSE happens to be one of the distros that require the apparmor parser library to be installed. You can do that with the following command.

```
$ zypper install apparmor-parser
```

## Installing K3s

First step is to connect to the system you want to install K3s and run the following.

```Bash
$ curl -sfL https://get.k3s.io | sh -
```

Once that completes, wait about a minute, then run the kubectl command to get the nodes to ensure everything is working as expected.

```Bash
$ k3s kubectl get node

NAME     STATUS   ROLES                  AGE   VERSION
k3snfs   Ready    control-plane,master   33s   v1.21.3+k3s1
```

Our K3s node has come up. Let's check out what storage classes we already have.

```Bash
$ k3s kubectl get storageclasses

NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  3h46m
```

We can see we have the local-path class, and it is set as our default. The next step is to get our NFS server up. If you already have an NFS server or plan to use a NAS, you are probably good to skip the next section.

## Verify NFS Access

Before deploying the NFS provisioner, we should verify that the K3s server can access and mount a share from your NFS server. I know that on openSUSE, you will need to install the nfs-client and utilities. Here is that command.

```Bash
$ zypper install nfs-utils
```

I then tested the mount by creating a temp folder and mounting it.

```Bash
$ mkdir /tmp/nfscheck
$ mount -t <server>:<path> /tmp/nfscheck
$ df -h /tmp/nfscheck

Filesystem        Size  Used Avail Use% Mounted on
<server>:<path>   1.8T  226G  1.6T  13% /tmp/nfscheck
```

If that reports back correctly, then we need to remove that mount.

```Bash
$ umount /tmp/nfscheck
```

At this point, hopefully, it all works. Now we can set up our provisioner.

## Deploying the NFS Provisioner

The Kubernetes docs outline that the NFS provisioner isn't internal and that an external provisioner needs to be installed. They list two options, and we will go with the [NFS subdir provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner). We have a few ways to install this since we are using K3s. We could install using Helm, just applying the manifests, or leverage the Helm Controller that ships with K3s. I like to use the tools native to what we are using, so we will go with the Helm Controller using the [K3s Helm CRD](https://rancher.com/docs/k3s/latest/en/helm/#using-the-helm-crd). This is basically a manifest that defines the Helm chart we want to deploy and the values we want to pass to the chart. In the NFS provisioner GitHub those show the Helm example, which provides all we need to know. Let's create our manifest using the info of your NFS server. We are setting the storage class name to NFS, and be aware that the default reclaim policy is *Delete*, so check out the reclaim policies [here](https://kubernetes.io/docs/concepts/storage/storage-classes/#reclaim-policy) and make a decision based on your use cases. If you are running storage you want to persist, then set this to *retain*. We determine the values that go in the set area from the [chart values](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/blob/master/charts/nfs-subdir-external-provisioner/README.md) in the README.

```YAML
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: nfs
  namespace: default
spec:
  chart: nfs-subdir-external-provisioner
  repo: https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
  targetNamespace: default
  set:
    nfs.server: x.x.x.x
    nfs.path: /exported/path
    storageClass.name: nfs
```

Now we need to create this helm chart manifest in */var/lib/rancher/k3s/server/manifests* on our k3s server, and it will automatically be applied. I will be using vim as my editor. You can use whatever you are comfortable using to get the file created in the folder.

```Bash
$ vim /var/lib/rancher/k3s/server/manifests/nfs.yaml

apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: nfs
  namespace: default
spec:
  chart: nfs-subdir-external-provisioner
  repo: https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
  targetNamespace: default
  set:
    nfs.server: x.x.x.x
    nfs.path: /exported/path
    storageClass.name: nfs
```

Then save it and wait a few minutes for it to be deployed. Now we can get our storage classes to verify it was created.

```Bash
$ k3s kubectl get storageclasses

NAME                   PROVISIONER                                         RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path                               Delete          WaitForFirstConsumer   false                  4h59m
nfs                    cluster.local/nfs-nfs-subdir-external-provisioner   Delete          Immediate              true                   14m
```

Awesome! We now have an NFS storage class we can use. Let's create a persistent volume claim to test our storage class.

## Deploying a Persistent Volume Claim

Now we can test our storage class by using a persistent volume claim or PVC.

```YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfsclaim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: nfs
  resources:
    requests:
      storage: 100Mi
```

Let's save that manifest as *pvc.yaml*, and we can then apply it.

```Bash
$ k3s kubectl apply -f pvc.yaml
persistentvolumeclaim/nfsclaim created
```

Now let's get that PVC.

```Bash
$ k3s kubectl get pvc nfsclaim

NAME       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
nfsclaim   Bound    pvc-b4516d14-bb5c-4b7d-ac18-db973c3e4aba   100Mi      RWO            nfs            84s
```

Great! We have now validated that we have a working NFS storage class. We could now deploy a pod using this PVC, and the files would be stored on our NFS server.

## Conclusion

Hopefully, you found this helpful with walking through at a high level all the steps required to set up NFS shares with K3s. If you have any questions or need any assistance, reach out to me using any of the social links listed on my blog, and I will try to assist you as time permits.

Thanks for reading,

Jamie
