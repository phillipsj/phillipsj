---
Title: "Creating an EKS tools image for your team"
date: 2018-06-20T21:50:58
Tags: 
- Kubernetes
- AWS
- EKS
- Kubectl
- Helm
- AWS CLI
---
# Creating an EKS tools image for your team

A couple weeks ago I posted this [post](https://www.phillipsj.net/posts/docker-base-image-for-eks-tools) about creating a docker base image for working with EKS. I said I would follow up with how you would use this base image to build an image for your team to use. This is it.

The cool thing about EKS is that it uses IAM and IAM roles to grant a user access to your Kubernetes cluster. Since it uses IAM your Kube config, along wth Heptio, it is super simple and can be shared among a team.  Here is an example of what it typically looks like:

```
apiVersion: v1
clusters:
- cluster:
    server: https://<your-cluster>.<region>.eks.amazonaws.com
    certificate-authority-data: <your-cert-data>
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: heptio-authenticator-aws
      args:
        - "token"
        - "-i"
        - "cluster-name"
```

You can see the *aws* user and the call to the Heptio authenticator. Besides the cluster info and the certificate there isn't much data in the file. Here are the steps we are going to take to create an image for the team.

1. Create a Dockerfile
2. Add the Kube Config to the Dockerfile
3. Configure a mount point, so users can mount their AWS credentials
4. Build and Publish the image.

With that high level plan out there, let's get started. We are going to create a docker file that uses the [eks-tools-base](https://hub.docker.com/r/phillipsj/eks-tools-base/) image that I have on Docker Hub. Let's create a directory to host all of this.

```
~$ mkdir eks-tools-team && cd eks
~$ touch Dockerfile
~$ mkdir .kube && cd .kube && touch config
```

Here is the contents that should be used for the kube-config:

```
apiVersion: v1
clusters:
- cluster:
    server: https://<your-cluster>.<region>.eks.amazonaws.com
    certificate-authority-data: <your-cert-data>
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: heptio-authenticator-aws
      args:
        - "token"
        - "-i"
        - "cluster-name"
```

Now the contents of the Dockerfile:

```
FROM phillipsj/eks-tools-base:0.2-beta

COPY .kube /root/.kube

ENTRYPOINT ["/bin/bash"]
```

Now we are ready to build our container.

```
~$ docker build . -t eks-tools-team
```

Once that is complete, let's run the container and mount our AWS credentials and access the EKS cluster.

```
~$ docker run --rm -it -v ~/.aws:/root/.aws eks-tools-team
~$ kubectl get nodes
NAME                          STATUS    ROLES     AGE       VERSION
ip-xx-xx-x-xxx.ec2.internal   Ready     <none>    XXd       v1.10.3
ip-xx-xx-x-xx.ec2.internal    Ready     <none>    XXd       v1.10.3
```

That's it, now you can push this image to a private container registry or just let everyone on your team build it themselves.
