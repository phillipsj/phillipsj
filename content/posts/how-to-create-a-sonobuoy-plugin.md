---
title: "How to Create a Sonobuoy Plugin"
date: 2022-01-27T20:48:40-05:00
tags:
- Kubernetes
- Sonobuoy
- Testing
- Rancher
- PowerShell
- Windows on Kubernetes
- RKE2
- RKE2 on Windows
---

Today we are going to learn how to create a [Sonobuoy plugin](https://sonobuoy.io/docs/v0.56.0/plugins/). Sonobuoy plugins are some metadata in the form of a YAML file that deploys a container that has the actual code that is responsible for executing the test or tests. Plugins come in two types, a daemonset or a job. We will be building a job plugin.

## Description

We will create a plugin that will deploy the [pstools](https://github.com/phillipsj/pstools) container as a daemonset. This will ensure that it is deployed to every node in the cluster. This doesn't seem like much a a test, except this is a mixed workload cluster running both Windows and Linux nodes. This will test that our container is compatible with all the nodes that we have in our cluster. I will be running my cluster using Rancher with a downstream cluster that is RKE2 v1.22.4 using Calico for CNI. My nodes will be openSUSE Leap 15.3 for the control plane, linux worker, and Windows 2019 for the other worker node. That's it for the high level of what we are going to achieve.

## Creating the Plugin

The first step is to create our directory.

```Bash
mkdir mixed-workload-e2e 
cd mixed-workload-e2e
```

We can now use the Sonobuoy CLI to generate our plugin YAML file.

```Bash
sonobuoy gen plugin -n mixed-workload-e2e \
-f junit \
-i phillipsj/mixed-workload-e2e:latest > mixed-workload-e2e.yaml
```

We will need to do a little modification like specifying the node selector and architecture we want to support. In addition to that we can add some metadata.

```YAML
podSpec:
  nodeSelector:
    kubernetes.io/os: linux
    kubernetes.io/arch: amd64
  containers: []
  restartPolicy: Never
  serviceAccountName: sonobuoy-serviceaccount
sonobuoy-config:
  driver: Job
  plugin-name: mixed-workload-e2e
  result-format: junit
  source_url: https://raw.githubusercontent.com/phillipsj/my-sonobuoy-plugins/main/mixed-workload-e2e/mixed-workload-e2e.yaml
  description: A plugin for deploying a mixed OS workload for ensuring that your image deploys correctly.
spec:
  image: phillipsj/mixed-workload-e2e:latest
  name: plugin
  resources: {}
  volumeMounts:
  - mountPath: /tmp/sonobuoy/results
    name: results
```

Next we need to create the manifest file for the pstools daemonset workload. 

```YAML
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: mixed-workload
  labels:
    app: mixed-workload
spec:
  selector:
    matchLabels:
      name: mixed-workload
  template:
    metadata:
      labels:
        name: mixed-workload
    spec:
      tolerations:
        # this toleration is to have the daemonset runnable on master nodes
        # remove it if your masters can't run pods
        - key: node-role.kubernetes.io/master
          operator: Exists
          effect: NoSchedule
      containers:
        - name: mixed-workload
          image: phillipsj/pstools:v0.2.0
```


We need a way to execute our manifest and then generate our results. The default plugin has a reference to a `run.sh` so we will use that to execute our tests and move our results file. 

```Bash
#! /bin/bash

sh ./t/workload.t -j
mv /t/workload.t-tests.xml /tmp/sonobuoy/results
```

We are going to just use Bash, kubectl, and [osht](https://github.com/coryb/osht) to create our tests. We will do a really basic test by using kubectl get to the number of nodes we have. Then we will apply our manifest and wait for it to be deployed succesfully. Finally, we will use kubectl to get our pods and verify that the number of pods match the number of nodes. We will need to create a directroy called `t` and our test file called `workload.t`. In our `workload.t` file we place our code.

```Bash
#!/bin/bash
set -eu
. osht.sh

PLAN 3

nodes=$(kubectl get nodes -o json | jq -r '.items[] | select(.status.phase = "Ready") | .metadata.name' | wc -l)
echo -e "Nodes: $nodes"
RUNS kubectl apply -f manifest.yaml
RUNS kubectl rollout status daemonsets/mixed-workload
pods=$(kubectl get pod -l "name=mixed-workload" -o json | jq -r '.items[] | select(.status.phase = "Running") | .metadata.name' | wc -l)
echo -r "Pods: $pods"

IS $nodes == $pods
```

Finally, we can create the last piece which is our `Dockerfile` for creating our container. We will use the SUSE [SLE Base Container Image](https://registry.suse.com/static/suse/sle15sp3/index.html) which we will install kubectl, osht, and our files.

```Dockerfile
FROM registry.suse.com/suse/sle15:latest

COPY . /

RUN zypper --non-interactive install curl jq \
    && curl -LO https://dl.k8s.io/release/v1.23.0/bin/linux/amd64/kubectl \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/kubectl \
    && cd t \
    && curl -LO https://raw.githubusercontent.com/coryb/osht/master/osht.sh

WORKDIR /
ENTRYPOINT ["sh", "run.sh"]
```

Let's build, tag, and push our container.

```Bash
docker build . -t phillipsj/mixed-workload-e2e:latest -t phillipsj/mixed-workload-e2e:v0.1.0
docker push phillipsj/mixed-workload-e2e --all-tags
```

We now have everything in place that we can run our plugin.

## Running our Sonobuoy Plugin

The Sonobuoy CLI can be used to execute our plugin and make sure to include a node selector or the aggregator since it is a mixed OS cluster.

```Bash
$ sonobuoy run --plugin mixed-workload-e2e.yaml --aggregator-node-selector kubernetes.io/os=linux
INFO[0000] create request issued name=sonobuoy namespace= resource=namespaces
INFO[0000] create request issued name=sonobuoy-serviceaccount namespace=sonobuoy resource=serviceaccounts
INFO[0000] create request issued name=sonobuoy-serviceaccount-sonobuoy namespace= resource=clusterrolebindings
INFO[0000] create request issued name=sonobuoy-serviceaccount-sonobuoy namespace= resource=clusterroles
INFO[0000] create request issued name=sonobuoy-config-cm namespace=sonobuoy resource=configmaps
INFO[0000] create request issued name=sonobuoy-plugins-cm namespace=sonobuoy resource=configmaps
INFO[0000] create request issued name=sonobuoy namespace=sonobuoy resource=pods
INFO[0000] create request issued name=sonobuoy-aggregator namespace=sonobuoy resource=services
```

Let's check the status.

```Bash
$ sonobuoy status 

PLUGIN               STATUS     RESULT   COUNT   PROGRESS
mixed-workload-e2e   complete   passed   1           

Sonobuoy plugins have completed. Preparing results for download.
```

Our Sonobuoy test passed and all we need to do is cleanup.

```Bash
$ sonobuoy delete                
INFO[0000] delete request issued kind=namespace namespace=sonobuoy
INFO[0000] delete request issued kind=clusterrolebindings
INFO[0000] delete request issued kind=clusterroles
```

## Wrapping Up

We have reached the end and we have a functioning plugin. I hope this helps you create your own plugins. You can check out my repo [here](https://github.com/phillipsj/my-sonobuoy-plugins).

Thanks for reading,

Jamie
