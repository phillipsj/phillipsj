---
title: "OpenTelemetry Operator Addon for MicroK8s"
date: 2025-01-26T22:51:30-05:00
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

As I have been working on setting up a home lab for Kubernetes for learning, I have settled on MicroK8s as my distribution of choice. It's easy to install, fairly well supported and comes with lots of [addons](https://microk8s.io/docs/addons). Yes, many addons are just convenience methods for installing a Helm chart or manifest which I like. Since I plan to install [OpenTelemetry](https://opentelemetry.io) on my cluster, I decided to create an addon. Canonical has good documentation and a template repository you can use, which is located [here](https://github.com/canonical/microk8s-addons-repo-template). I made myself a new repository from this template and dug into creating my first MicroK8s addon. You're provided with the choice to write it using Bash or Python with utilities provided for each. I'm not the biggest fan of Bash so of course I chose Python. The Python approach allows the use of Requests and Click for your addon. PyTest is provided for testing that your addon works correctly. Overall, the experience has been good. I was able to get my addon created and tested with minimal effort. You can check out my [addon repository](https://github.com/phillipsj/microk8s-addons) to check out what I have done. You may want to watch the repository if this interests you as I have a few more observability-related addons that I will be adding.

If you would like to install my addon you can do it by first adding the repository to your MicroK8s.

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
$ microk8s enable phillipsj/opentelemetry-operator

Enabling opentelemetry-operator
"open-telemetry" has been added to your repositories
CertManager is not installed. Using auto-generated certificates instead.
Release "opentelemetry-operator" does not exist. Installing it now.
NAME: opentelemetry-operator
LAST DEPLOYED: 
NAMESPACE: opentelemetry-operator
STATUS: deployed
REVISION: 1
NOTES:
opentelemetry-operator has been installed. Check its status by running:
  kubectl --namespace opentelemetry-operator get pods -l "app.kubernetes.io/name=opentelemetry-operator"

Visit https://github.com/open-telemetry/opentelemetry-operator for instructions on how to create & configure OpenTelemetryCollector and Instrumentation custom resources by using the Operator.
Enabled opentelemetry-operator
```

That is all there is to it. I have added the ability to detect if you have CertManager installed. In the previous example, the CertManager addon wasn't enabled so the installation happened using the auto-generated certificates. In the next example, you will notice that it detects the CertManager addon so CertManager is used.

```Bash
$ microk8s enable phillipsj/opentelemetry-operator

Enabling opentelemetry-operator
"open-telemetry" has been added to your repositories
CertManager is installed. Using Cert-manager certificates instead.
Release "opentelemetry-operator" does not exist. Installing it now.
NAME: opentelemetry-operator
LAST DEPLOYED: 
NAMESPACE: opentelemetry-operator
STATUS: deployed
REVISION: 1
NOTES:
opentelemetry-operator has been installed. Check its status by running:
  kubectl --namespace opentelemetry-operator get pods -l "app.kubernetes.io/name=opentelemetry-operator"

Visit https://github.com/open-telemetry/opentelemetry-operator for instructions on how to create & configure OpenTelemetryCollector and Instrumentation custom resources by using the Operator.
Enabled opentelemetry-operator
```

That's it, if there are any additional features or options I should support please open up an issue or submit a pull request.

Thanks for reading,

Jamie
