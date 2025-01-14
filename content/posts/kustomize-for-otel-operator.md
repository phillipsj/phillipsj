---
title: "Kustomize for OTel Operator"
date: 2025-01-07T20:43:35-05:00
tags:
- OpenTelemetry
- Open Source
- OTel
- K8s
- Kubernetes
- Kustomize
- Helm
---

If you have been reading my blog for a while, you may already know that I'm not the biggest fan of [Helm](https://helm.sh). If you’re new here, hi, I'm not a fan of Helm. I feel it adds a lot of complexities that
are seldom worth it, and it's hard to build a Helm chart well, note I said well. Many projects have started publishing manifests for their projects, and the [OpenTelemetry Operator](https://github.com/open-telemetry/opentelemetry-operator) is one of them. You can find the manifest [here](https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml). There is also an artifact for the manifest also available.

The OpenTelemetry operator has several areas that could be tweaked when doing a deployment. I typically tweak the collector image, the Java agent image, and a couple of settings related to requirements for different cloud vendors. I believe the project is going to change the default collector image to the K8s collector image, which will remove that need. The default Java agent image is the older 1.x where I want the 2.x version. This got me thinking that I should just create some patches to the manifest to apply those tweaks. I thought I would blog about the creation of these patches and then share them to hopefully make it easier for others to take the same approach. Let's get started.

## Getting the OTel operator manifest

Let's create a working directory and pull down the manifest.

```Bash
$ mkdir otel-operator && cd $_
$ curl -O https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml
```

## Setting up Kustomize

The first step in getting Kustomize configured is to set up our `kustomization.yaml` file. Ours will be fairly simple.

```Bash
$ touch kustomization.yaml
```

Then put the following contents in the file. This will define our operator manifest as a resource.

```YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- opentelemetry-operator.yaml
```
Now we can do our first set of patches by defining the images we want to be able to define different tags on.

```YAML
images:
- name: ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator
  newTag: 0.115.0
- name: quay.io/brancz/kube-rbac-proxy
  newTag: v0.13.0
```

This now puts the specific versions we want to use in a single place to adjust. The final item we want to patch is the args that are passed to the controller manager to define the collector image we want to use and the updated version of the Java agent.

```YAML
patches:
- patch: |-
    - op: test #Makes sure that index is the expected image and hasn't changed.
      path: /spec/template/spec/containers/0/name
      value: manager
    - op: add
      path: /spec/template/spec/containers/0/args/-
      value: --collector-image=ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-k8s:0.115.0
    - op: add
      path: /spec/template/spec/containers/0/args/-
      value: --auto-instrumentation-java-image=ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-java:2.10.0
  target:
        kind: Deployment
        name: opentelemetry-operator-controller-manager
```

The first patch is a test, that is a neat little trick I picked up while learning how to do this. Since you can only do patches based on index, I wanted to make sure that the first container has the name I expect. That way if the upstream manifest ever changes the order, I will find out pretty quickly as my build will fail.

Here is what the final `kustomization.yaml` file should look like:

```YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- opentelemetry-operator.yaml
images:
- name: ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator
  newTag: 0.115.0
- name: quay.io/brancz/kube-rbac-proxy
  newTag: v0.13.0
patches:
- patch: |-
    - op: test #Makes sure that index is the expected image and hasn't changed.
      path: /spec/template/spec/containers/0/name
      value: manager
    - op: add
      path: /spec/template/spec/containers/0/args/-
      value: --collector-image=ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-k8s:0.115.0
    - op: add
      path: /spec/template/spec/containers/0/args/-
      value: --auto-instrumentation-java-image=ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-java:2.10.0
  target:
        kind: Deployment
        name: opentelemetry-operator-controller-manager
```

Let's run it to see that it works.

```Bash
$ kustomize build > output.yaml
```

You shouldn't see any errors. If you open the `output.yaml` file you can see the changes have been applied and the manifest we pulled down untouched. 

## Wrapping Up

I have a few more posts on this topic planned to cover a few additional tweaks. I also want to see what it looks like to split it out into separate files instead of putting it all in the `kustomization.yaml` file.

Thanks for reading,

Jamie