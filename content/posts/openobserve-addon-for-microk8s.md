---
title: "OpenObserve Addon for Microk8s"
date: 2025-02-24T21:29:01-05:00
tags:
- OpenTelemetry
- K8s
- Open Source
- Home Lab
- MicroK8s
- Ubuntu
- Linux
- Kubernetes
---

In a previous post, I mentioned the [addons repository](https://github.com/phillipsj/microk8s-addons) that I had created for [MicroK8s](https://microk8s.io). There is the existing [OpenTelemetry Operator](https://opentelemetry.io/docs/platforms/kubernetes/helm/operator/) addon and now there is a new addon for [OpenObserve](https://openobserve.ai). I had looked at a few options and decided to try this out as my observability platform. Let's check out how to install it.

```Bash
$ microk8s addons repo add phillipsj https://github.com/phillipsj/microk8s-addons --reference main

Cloning into '/var/snap/microk8s/common/addons/phillipsj'...
remote: Enumerating objects: 48, done.
remote: Counting objects: 100% (48/48), done.
remote: Compressing objects: 100% (40/40), done.
remote: Total 48 (delta 11), reused 36 (delta 7), pack-reused 0 (from 0)
Unpacking objects: 100% (48/48), 21.73 KiB | 1.81 MiB/s, done.
```

Then you can install the OpenTelemetry addon:

```Bash
$ microk8s enable phillipsj/openobserve

Enabling openobserve
Infer repository core for addon hostpath-storage
Addon core/hostpath-storage is already enabled
The registry will be created with the size of 10Gi.
Default storage class will be used.
namespace/openobserve created
persistentvolumeclaim/openobserve-claim created
secret/openobserve created
service/openobserve created
statefulset.apps/openobserve created
Enabled openobserve. Password can be found in the openobserve secret by running `kubectl get -n openobserve secrets/openobserve --template={{.data.password}} | base64 -d`
```

We can see that the openobserve pod is up and running:

```Bash
$ microk8s kubectl get pods -n openobserve
NAME            READY   STATUS    RESTARTS   AGE
openobserve-0   1/1     Running   0          96s
```

You can get the password like this:

```Bash
microk8s kubectl get -n openobserve secrets/openobserve --template={{.data.password}} | base64 -d
```

The user name is `root@microk8s.local`, so all you need to do is expose your service which can easily be done using port forwarding.

```Bash
microk8s kubectl -n openobserve port-forward svc/openobserve 5080:5080
```

Navigate to <http://localhost:5080> and enter the credentials.

That's it, if there are any additional features or options I should support please open up an issue or submit a pull request.

Thanks for reading,

Jamie
