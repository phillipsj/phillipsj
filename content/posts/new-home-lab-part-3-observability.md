---
title: "New Home Lab Part 3: Observability"
date: 2025-03-02T12:46:47-05:00
tags:
- Home Lab
- MicroK8s
- MetalLB
- Ubuntu
- Linux
- Kubernetes
---

My new home lab is getting close to having the core setup complete. I want to run an observability platform in my home lab for learning so I took a brief hiatus on the home lab work to create two addons for MicroK8s. The first addon is one for [OpenTelemetry](https://opentelemetry.io) and the other addon is for [OpenObserve](https://openobserve.ai). You can find these addons in my new addons repository [here](https://github.com/phillipsj/microk8s-addons).  I showed how those are installed in the blog posts about each addon. I need to update my launch configuration to reflect these two new addons as part of the bootstrapping process.

```YAML
version: 0.2.0
addonRepositories:
  - name: phillipsj
    url: https://github.com/phillipsj/microk8s-addons
    reference: main
addons:
  - name: dns
  - name: rbac
  - name: ingress
  - name: hostpath-storage
  - name: cert-manager
  - name: dashboard
  - name: registry
  - name: metallb
    args: [192.168.1.231-192.168.1.245]
  - name: phillipsj/opentelemetry-operator
  - name: phillipsj/openobserve
extraKubeAPIServerArgs:
  --authorization-mode: RBAC,Node
extraKubeletArgs:
  --cluster-dns: 10.152.183.10
  --cluster-domain: cluster.local
```

With the cluster bootstrapped with this new config, I now have the OpenTelemetry-Operator running in my cluster and the OpenObserve platform. Now I need to expose my OpenObserve dashboard, fortunately, I went through the trouble configuring MetalLB, so I will put it to use. I only need to create a service of type `LoadBalancer` and assign it an IP from the pool of IPs I defined in my launch configuration. I get the selector label from my OpenObserve installation and that is all that is required.

Here is what that service looks like:

```YAML
apiVersion: v1
kind: Service
metadata:
  name: openobserve-lb
  namespace: openobserve
  annotations:
    metallb.universe.tf/address-pool: default-addresspool
spec:
  selector:
    app: openobserve
  type: LoadBalancer
  loadBalancerIP: 192.168.1.231
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 5080
```

Now I can navigate to that IP address and I should see the OpenObserve dashboard. I'm not stopping here though as a consistent reader of this blog is going to know that I don't like using IP addresses, I much prefer using human-readable names. So I went into my DNS servers that I set up and added an `A record` that mapped the IP address to `dashboard.home.arpa`. Now I can easily get to the dashboard without having to remember IP addresses.

Here is the current state of my cluster:

```Bash
$ kubectl get pods -A
NAMESPACE                NAME                                         READY   STATUS    RESTARTS        AGE
cert-manager             cert-manager-cainjector-fd9bf654b-wf6gm      1/1     Running   5 (5d15h ago)   44d
cert-manager             cert-manager-ff4b94468-fdlgs                 1/1     Running   5 (5d15h ago)   44d
cert-manager             cert-manager-webhook-7749797f6-smdth         1/1     Running   5 (5d15h ago)   44d
container-registry       registry-579865c76c-qxczs                    1/1     Running   5 (5d15h ago)   44d
ingress                  nginx-ingress-microk8s-controller-8fp4m      1/1     Running   5 (5d15h ago)   44d
kube-system              calico-kube-controllers-5947598c79-fpwz2     1/1     Running   5 (5d15h ago)   44d
kube-system              calico-node-tjtgc                            1/1     Running   5 (5d15h ago)   44d
kube-system              coredns-79b94494c7-n2g9s                     1/1     Running   5 (5d15h ago)   44d
kube-system              dashboard-metrics-scraper-5bd45c9dd6-fsvr5   1/1     Running   5 (5d15h ago)   44d
kube-system              hostpath-provisioner-c778b7559-rjxqx         1/1     Running   7 (5d15h ago)   44d
kube-system              kubernetes-dashboard-57bc5f89fb-9wglp        1/1     Running   5 (5d15h ago)   44d
kube-system              metrics-server-7dbd8b5cc9-vggkd              1/1     Running   5 (5d15h ago)   44d
metallb-system           controller-7ffc454778-v4r68                  1/1     Running   5 (5d15h ago)   44d
metallb-system           speaker-g86j5                                1/1     Running   5 (5d15h ago)   44d
openobserve              openobserve-0                                1/1     Running   0               5d15h
opentelemetry-operator   opentelemetry-operator-64dc8845fd-2pcnb      2/2     Running   8 (5d15h ago)   34d
```

The remaining item is to set up the cluster and host level telemetry which will be coming shortly.

Thanks for reading,

Jamie
