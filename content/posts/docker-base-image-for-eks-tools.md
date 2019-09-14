---
Title: "Docker base image for EKS tools"
date: 2018-06-10T22:51:45
Tags: 
- Kubernetes
- AWS
- EKS
- Kubectl
- Helm
- AWS CLI
---
# Docker base image for EKS tools

I have an idea floating around to make working with EKS extremely easy withing a team. AWS uses the [Heptio Authenticator](https://github.com/heptio/authenticator) to wire up your AWS Credentials and IAM roles with [Kubectl](https://kubernetes.io/docs/reference/kubectl/overview/). What makes this really cool is that the Kube config is extremely generic. This means that your team can share a single copy of the Kube config letting AWS determine permissions on your Kuberentes cluster.

Since this config can be shared across a whole team, it makes sense to me to build a container with the base tools available. Then a team can build an image that has their Kube config baked in and push that to a private docker repository. Then all a user needs to do is inject the AWS credentials they want to use and they have an environment that is ready to go and consistent across a team.

Now that the basic premise is out there, which the complete details will come in a follow up post, I have already published an *eks-tools-base* image to Docker Hub that you can get started using now. Here is all the info you need to check it out.

```
docker pull phillipsj/eks-tools-base:0.1-beta
docker run -it eks-tools-base bash
```

Links:
*[GitHub](https://github.com/phillipsj/eks-tools-base)
*[Docker Hub](https://hub.docker.com/r/phillipsj/eks-tools-base/)

