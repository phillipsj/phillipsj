---
title: "New Home Lab Part 2: MicroK8s"
date: 2025-01-18T18:11:38-05:00
tags:
- Home Lab
- MicroK8s
- MetalLB
- Ubuntu
- Linux
- Kubernetes
---

My last post I had an outline of the steps I wanted to take. I completed all the hardware configuration and setup of Ubuntu. This leaves just getting [MicroK8s](https://microk8s.io) installed and configured. I said that I was going to have automation of my cluster, and that is exactly how I set it up. I took a deep dive into [launch configurations](https://microk8s.io/docs/explain-launch-config) which I successfully used to create my MicroK8s cluster. The only tricky part was figuring out how to pass arguments to addons like MetalLB, and it wasn't that challenging. Here is how I set it up.

First step was to create a launch configuration with the various addons that I wanted. I started with the standard launch configuration and just added the addons.

```YAML
version: 0.1.0
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
extraKubeAPIServerArgs:
  --authorization-mode: RBAC,Node
extraKubeletArgs:
  --cluster-dns: 10.152.183.10
  --cluster-domain: cluster.local
```

The `args` section for MetalLB is the one item that I would like to focus on. That is how you pass arguments to an addon. That is where I set the IP address range that I want to use for my load balancer resources. After you have your launch configuration defined, you need to copy or create it here:

```Bash
sudo mkdir -p /var/snap/microk8s/common/
sudo cp microk8s-config.yaml /var/snap/microk8s/common/.microk8s.yaml
```

After it has been copied, you can run the installation command for the MicroK8s snap. I chose to pin it to a specific version since they auto update.

```Bash
sudo snap install microk8s --channel=1.32/stable --classic
```

Once it has finished, you should be able to get all your pods and see that all the things are up and running as expected.

```Bash
sudo microk8s kubectl get pod -A
NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE
cert-manager         cert-manager-cainjector-fd9bf654b-wf6gm      1/1     Running   0          70s
cert-manager         cert-manager-ff4b94468-fdlgs                 1/1     Running   0          70s
cert-manager         cert-manager-webhook-7749797f6-smdth         1/1     Running   0          70s
container-registry   registry-579865c76c-qxczs                    1/1     Running   0          27s
ingress              nginx-ingress-microk8s-controller-8fp4m      1/1     Running   0          67s
kube-system          calico-kube-controllers-5947598c79-fpwz2     1/1     Running   0          75s
kube-system          calico-node-tjtgc                            1/1     Running   0          75s
kube-system          coredns-79b94494c7-n2g9s                     1/1     Running   0          75s
kube-system          dashboard-metrics-scraper-5bd45c9dd6-fsvr5   1/1     Running   0          28s
kube-system          hostpath-provisioner-c778b7559-rjxqx         1/1     Running   0          72s
kube-system          kubernetes-dashboard-57bc5f89fb-9wglp        1/1     Running   0          29s
kube-system          metrics-server-7dbd8b5cc9-vggkd              1/1     Running   0          29s
metallb-system       controller-7ffc454778-v4r68                  1/1     Running   0          25s
metallb-system       speaker-g86j5                                1/1     Running   0          25s
```

There is a tutorial that covers most of this on the MicroK8s website called [How to use launch configurations](https://microk8s.io/docs/add-launch-config). I have also published my launch configuration to a repo called [my-home-lab-config](https://github.com/phillipsj/my-home-lab-config) on GitHub. I will be posting more to that repo as I add more to my cluster. I will also use it to store configuration for any tools that I install.

If you're curious as to how the single resource usage on the host is going, here is a screenshot from [btop](https://github.com/aristocratos/btop).

![BTOP output showing system resource usage](/images/home-lab/btop.png)

Not too bad running all of these services. Let's see what impact my plans have in the long term.

Thanks for reading,

Jamie
