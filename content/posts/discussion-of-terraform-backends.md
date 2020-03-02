---
title: "Discussion of Terraform Backends"
date: 2020-03-01T20:34:27-05:00
tags:
- Open Source
- Terraform
- HashiCorp
---

[Terraform](https://www.terraform.io/) is a tool for managing resources in a declarative fashion. One of the critical features of Terraform is drift detection, which is enabled by tracking state. To provide state in Terraform is a [backend](https://www.terraform.io/docs/backends/index.html). When first getting started, most people typically use the local state store. You will quickly outgrow a local state store, especially when you move your Terraform usage into a team environment and a CI/CD pipeline. Moving to a remote backend allows the state to be backed up, versioned, shared, locked, etc. These features grow valuable past a single user or a single system managed with Terraform. Once you start leveraging remote state, there are typically two big questions that arise.

1. Which features do I need?
2. What are my options for an on-premises backend?

I am going to answer these questions with my experience, and I would encourage you to get as many different experiences before deciding for yourself. Let's get started answering these questions.

## What features do I need?

The docs outline two types of backends: enhanced and standard. Enhanced backends are local, which is the default, and remote, which generally refers to Terraform Cloud. The one major feature of an enhanced backend is the support for remote operations. Remote operations support executing the Terraform apply and plan commands from a remote host. This feature isn't enough, in my opinion, to warrant adopting Terraform Cloud. There are plenty of reasons to use it, but this isn't one of those on my list.

The second type of backend is standard. There are currently 14 different standard backends available that I would organize around one feature, locking. Locking is what prevents two processes from editing the same state file at the same time. In a multi-user and CI/CD environment, this is critical to keep from corrupting your state.

To sum this up, I think the key feature you need is **locking**. After locking, the other critical element is the ability to version your state. Many of the cloud solutions provide this mechanism.

### Backends that support locking

Here are the backends that support locking.

* azurerm
* gcs
* s3
* consul
* cos
* etcdv3
* http (optional)
* manta
* oss
* pg
* Terraform Enterprise

### Backends that don't support locking

Here are the backends that don't support locking, and I would not recommend using unless a requirement or need exists.

* artifactory
* swift
* etcd

## What are my options for an on-premises backend?

Now this question is probably the toughest to answer. There are only four backends from the list that supports locking for use on-premises. I am not going to include Manta as it is relatively specialized. I am also not going to count HTTP since I haven't found an implementation that I like. Finally, there is the possibility to leverage an S3 compatible API that you can host yourself, and I may do a future post testing the S3 alternative compatibility.

The four choices left are below.

* consul
* pg
* Terraform Enterprise
* etcdv3

Out of the four that are left, I wouldn't recommend Terraform Enterprise. TF Enterprise is one of those products that you will know if you need it or not. I don't feel it is necessary unless you have the type of environment that it is warranted. That leaves us with three viable options for an on-premises state store: Consul, PostgreSQL, and etcdV3. I would feel comfortable using any of those solutions, so pick the one you feel most comfortable using and roll with that.

## Conclusion

Hopefully, you found this interesting and helpful. I didn't address which one to use if you are in a cloud-hosted situation as all of the cloud provider solutions support locking. Terraform is a flexible tool with support for many different solutions, which makes it difficult to prescribe an approach.

Thanks for reading,

Jamie
