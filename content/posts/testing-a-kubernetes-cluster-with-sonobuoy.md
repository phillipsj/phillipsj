---
title: "Testing a Kubernetes Cluster with Sonobuoy"
date: 2022-01-26T20:23:44-05:00
tags:
- Kubernetes
- Sonobuoy
- Testing
- Rancher
- Go
---

If you are constantly building Kubernetes clusters as part of your job, you may want to consider bringing [Sonobuoy](https://sonobuoy.io) into your workflow. It's a good way to build out a standard suite of validation tests that can ensure that a cluster is configured in a standardized fashion. Sonobuoy has a concept called [plugins](https://sonobuoy.io/plugins/). They produce several that you can use to run things like upstream E2E tests, CIS Benchmarks, or RBAC auditing. In addition to these, you can also build your own custom plugins, which can use the language of your choice using the testing framework of your choice. Let's find out what we can achieve using one of the included plugins and a custom plugin.

## Installing Sonobuoy

Sonobuoy can be installed for Windows or Linux by doing a wget and extracting using tar.

```Bash
# Windows
wget https://github.com/vmware-tanzu/sonobuoy/releases/download/v0.56.0/sonobuoy_0.56.0_windows_amd64.tar.gz
tar.exe -xvf sonobuoy_0.56.0_windows_amd64.tar.gz

# Linux
wget https://github.com/vmware-tanzu/sonobuoy/releases/download/v0.56.0/sonobuoy_0.56.0_linux_amd64.tar.gz
tar -xvf sonobuoy_0.56.0_linux_amd64.tar.gz
```

Move the executable somewhere on your path.

## Setup

You will need an admin kubeconfig and it will need to be added to your KUBECONFIG environment variable. That is all you need outside of having Sonobuoy installed. If you are using Rancher, [here](https://rancher.com/docs/rancher/v2.6/en/cluster-admin/cluster-access/kubectl/#accessing-clusters-with-kubectl-from-your-workstation) is how you can get it for your cluster. Now we can verify that it's all configured correctly by running the conformance test in quick mode. This should complete in about 1-2 minutes.

```Bash
$ sonobuoy run --wait --mode quick

21:44:40          PLUGIN        NODE    STATUS   RESULT   PROGRESS
21:44:40             e2e      global   running                    
21:44:40    systemd-logs   rke2agent   running                    
21:44:40    systemd-logs    rke2main   running                    
21:44:40 
21:44:40 Sonobuoy is still running. Runs can take 60 minutes or more depending on cluster and plugin configuration.
21:45:00             e2e      global   complete   passed   1/1 (0 failures)
21:45:00    systemd-logs   rke2agent   complete   passed                   
21:45:00    systemd-logs    rke2main   complete   passed                   
21:45:00 Sonobuoy plugins have completed. Preparing results for download.
21:45:20 Sonobuoy has completed. Use `sonobuoy retrieve` to get results.
```

It looks like everything is set up correctly. We can start running plugins and don't forget to make sure everything has been cleaned up.

```Bash
sonobuoy delete
```

## Cluster Inventory Plugin

We are going to start with using the [cluster inventory plugin](https://github.com/vmware-tanzu/sonobuoy-plugins/tree/main/cluster-inventory). We can take the report return by that and parse it looking for the information that we expect. We can assert things about our cluster by just using the report generated from this plugin. Let's get the report by running against a cluster.

```Bash
sonobuoy run --plugin https://raw.githubusercontent.com/vmware-tanzu/sonobuoy-plugins/master/cluster-inventory/cluster-inventory.yaml
```

Once it has been completed we can pull down the results in a YAML format.

```Bash
results=$(sonobuoy retrieve)
sonobuoy results $results --mode dump > inventory.yaml
```

Now we can parse through our `inventory.yaml` and assert some things about our cluster. We are going to check our total node count and assert that we have at least one node that is Windows running as an RKE2 worker node. We will also check that our status is `Ready`. We also have some node info so we can verify the operating system being used along with our Kubelet and ContainerD versions. Here is a list of what we are going to check.

* status
* labels
  * kubernetes.io/os
  * node-role.kubernetes.io/worker
  * node.kubernetes.io/instance-type
* nodeInfo
  * osimage
  * containerruntimeversion
  * kubeletversion
* node count


Let's start writing our checks. We could convert or alter the plugin to only return the JSON report, we are just going to roll with what we have with minimum effort. There are a couple of approaches, you can use [yq](https://github.com/mikefarah/yq) and if you use PowerShell, then the [PowerShell YAML](https://github.com/cloudbase/powershell-yaml) module is a good choice. I am going to use Go along with [testify](https://github.com/stretchr/testify) for ease of use. Let's create our `sonobuoy_test.go` and add some structs to use to parse the results.

```Go
type NodeInfo struct {
	ContainerRuntimeVersion string `yaml:"containerruntimeversion,omitempty"`
	KubeletVersion          string `yaml:"kubeletversion,omitempty"`
	KubeProxyVersion        string `yaml:"kubeproxyversion,omitempty"`
	OperatingSystem         string `yaml:"operatingsystem,omitempty"`
	OSImage                 string `yaml:"osimage,omitempty"`
}

type Details struct {
	Addresses  []map[string]string `yaml:"addresses,omitempty"`
	Conditions []map[string]string `yaml:"conditions,omitempty"`
	Labels     map[string]string   `yaml:"labels,omitempty"`
	NodeInfo   NodeInfo            `yaml:"nodeInfo,omitempty"`
	Taints     []map[string]string `yaml:"taints,omitempty"`
}

type Item struct {
	Name    string  `yaml:"name,omitempty"`
	Status  string  `yaml:"status,omitempty"`
	Items   []Item  `yaml:"items,omitempty"`
	Details Details `yaml:"details,omitempty"`
}
```

This only represents the information that I want to check and is enough to demonstrate the use case. Next, we can create our test function. We will start off by setting up a struct to represent what we expect the results to be. Then we can read in and parse our YAML file. Finally, we will start asserting as we parse through the results to select the information we want to check.

```Go
func TestCluster(t *testing.T) {
	expected := struct {
		count                                    int
		status, windowsK8s, linuxK8s, rkeVersion string
	}{
		count:      3,
		status:     "Ready",
		windowsK8s: "v1.22.5",
		linuxK8s:   "v1.22.5+rke2r2",
		rkeVersion: "rke2",
	}

	a := assert.New(t)

	data, err := ioutil.ReadFile("inventory.yaml")
	if err != nil {
		log.Fatal(err)
	}

	var results Item
	if err := yaml.Unmarshal(data, &results); err != nil {
		log.Fatal(err)
	}

	a.NotNil(results)
	for _, i := range results.Items[0].Items {
		if i.Name == "Cluster Components" {
			for _, i2 := range i.Items {
				if i2.Name == "Nodes" {
					a.Exactly(expected.count, len(i2.Items))
					for _, node := range i2.Items {
						a.Contains(node.Status, expected.status)

						nodeInfo := node.Details.NodeInfo
						a.NotNil(nodeInfo)

						labels := node.Details.Labels

						a.NotNil(labels)
						a.Contains(labels, "cattle.io/os")
						a.Contains(labels, "kubernetes.io/os")
						a.Contains(labels, "rke.cattle.io/machine")
						a.Contains(labels, "node.kubernetes.io/instance-type")
						a.Equal(expected.rkeVersion, labels["node.kubernetes.io/instance-type"])

						if node.Details.NodeInfo.OperatingSystem == "windows" {
							a.Equal(expected.windowsK8s, nodeInfo.KubeletVersion)
							a.Equal(expected.windowsK8s, nodeInfo.KubeProxyVersion)
							a.Equal("windows", labels["cattle.io/os"])
							a.Equal("windows", labels["kubernetes.io/os"])
						}
						if node.Details.NodeInfo.OperatingSystem == "linux" {
							a.Equal(expected.linuxK8s, nodeInfo.KubeletVersion)
							a.Equal(expected.linuxK8s, nodeInfo.KubeProxyVersion)
							a.Equal("linux", labels["cattle.io/os"])
							a.Equal("linux", labels["kubernetes.io/os"])
						}
					}
				}
			}
		}
	}
}
```

Bringing it all together including the imports.

```Go
package main

import (
	"io/ioutil"
	"log"
	"testing"

	"github.com/stretchr/testify/assert"
	"gopkg.in/yaml.v3"
)

type NodeInfo struct {
	ContainerRuntimeVersion string `yaml:"containerruntimeversion,omitempty"`
	KubeletVersion          string `yaml:"kubeletversion,omitempty"`
	KubeProxyVersion        string `yaml:"kubeproxyversion,omitempty"`
	OperatingSystem         string `yaml:"operatingsystem,omitempty"`
	OSImage                 string `yaml:"osimage,omitempty"`
}

type Details struct {
	Addresses  []map[string]string `yaml:"addresses,omitempty"`
	Conditions []map[string]string `yaml:"conditions,omitempty"`
	Labels     map[string]string   `yaml:"labels,omitempty"`
	NodeInfo   NodeInfo            `yaml:"nodeInfo,omitempty"`
	Taints     []map[string]string `yaml:"taints,omitempty"`
}

type Item struct {
	Name    string  `yaml:"name,omitempty"`
	Status  string  `yaml:"status,omitempty"`
	Items   []Item  `yaml:"items,omitempty"`
	Details Details `yaml:"details,omitempty"`
}

func TestCluster(t *testing.T) {
	expected := struct {
		count                                    int
		status, windowsK8s, linuxK8s, rkeVersion string
	}{
		count:      3,
		status:     "Ready",
		windowsK8s: "v1.22.5",
		linuxK8s:   "v1.22.5+rke2r2",
		rkeVersion: "rke2",
	}

	a := assert.New(t)

	data, err := ioutil.ReadFile("inventory.yaml")
	if err != nil {
		log.Fatal(err)
	}

	var results Item
	if err := yaml.Unmarshal(data, &results); err != nil {
		log.Fatal(err)
	}

	a.NotNil(results)
	for _, i := range results.Items[0].Items {
		if i.Name == "Cluster Components" {
			for _, i2 := range i.Items {
				if i2.Name == "Nodes" {
					a.Exactly(expected.count, len(i2.Items))
					for _, node := range i2.Items {
						a.Contains(node.Status, expected.status)

						nodeInfo := node.Details.NodeInfo
						a.NotNil(nodeInfo)

						labels := node.Details.Labels

						a.NotNil(labels)
						a.Contains(labels, "cattle.io/os")
						a.Contains(labels, "kubernetes.io/os")
						a.Contains(labels, "rke.cattle.io/machine")
						a.Contains(labels, "node.kubernetes.io/instance-type")
						a.Equal(expected.rkeVersion, labels["node.kubernetes.io/instance-type"])

						if node.Details.NodeInfo.OperatingSystem == "windows" {
							a.Equal(expected.windowsK8s, nodeInfo.KubeletVersion)
							a.Equal(expected.windowsK8s, nodeInfo.KubeProxyVersion)
							a.Equal("windows", labels["cattle.io/os"])
							a.Equal("windows", labels["kubernetes.io/os"])
						}
						if node.Details.NodeInfo.OperatingSystem == "linux" {
							a.Equal(expected.linuxK8s, nodeInfo.KubeletVersion)
							a.Equal(expected.linuxK8s, nodeInfo.KubeProxyVersion)
							a.Equal("linux", labels["cattle.io/os"])
							a.Equal("linux", labels["kubernetes.io/os"])
						}
					}
				}
			}
		}
	}
}
```

Now we can execute our tests.

```Bash
$ go test
PASS
ok      github.com/example/sonobuoy       0.013s
```

All of our tests passed. We have successfully validated a cluster that we deployed using the *Cluster Inventory* Sonobuoy plugin.

## Wrapping up

This is just an example of how to leverage Sonobuoy to perform additional testing outside of just conformance tests. Sonobuoy is extensible with helpers that allow you to create your own plugins. 

Thanks for reading,

Jamie
