---
title: "The Kubernetes Terraform Provider Is Often Overlooked"
date: 2021-01-15T19:14:40-05:00
tags:
- YAML
- k8s
- Kubernetes 
- Terraform
---

I wrote a post title [K8s YAML Alternative: Terraform](https://www.phillipsj.net/posts/k8s-yaml-alternative-terraform/) almost a year ago. That post explored using Terraform to create resources in Kubernetes instead of YAML manifests or other alternatives like Helm. In the last year, I haven't seen many posts or articles about using Terraform to do it. I find that a little odd that it hasn't gotten a more comprehensive adoption than what it appears to have. Helm has some advantages and challenges, with the biggest, in my opinion, being the templating system. Go templates aren't that bad, just challenging to learn. Kustomize has come along and seems to be gaining a lot of adoption. The ability to write YAML manifests, then compose those together has a lot of advantages. These are good options depending on the tools that already exist in your stack. Many shops are leveraging Terraform to do infrastructure-as-code, which makes me wonder why they aren't using Terraform for Kubernetes. The modularity that is provided by these other tools is also available in Terraform. The new HCL 2.0 syntax brings a lot of extra power to what one can achieve with Terraform. I am planning some posts to walk through setting up modules for a personal Kubernetes project. I will put those modules out on GitHub for others to consume and use them to compose new modules to build more complex modules. I genuinely believe that Terraform and modules can replace a large chunk of Helm's functionality, and it will be friendlier to use than either it or Kustomize. I encourage you to read the post from last year to see what is possible.

Thanks for reading,

Jamie
