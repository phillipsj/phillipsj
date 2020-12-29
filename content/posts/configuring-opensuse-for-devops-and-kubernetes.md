---
title: "Configuring openSUSE for DevOps and Kubernetes"
date: 2020-12-28T20:11:26-05:00
tags:
- Open Source
- Linux
- openSUSE
- DevOps
- Kubernetes
- Terraform
- Arkade
---

I am always looking for newer ways to get a system configured for what I like to experiment with and write blog posts. I am in the process of getting openSUSE setup, so I thought I would bring everyone along for the journey. Here is the list of tools that I know that I need:

* Terraform
* Packer
* Docker
* Docker-Compose
* kubectl
* Local K8s cluster

I have already checked out what is available in the openSUSE repositories and openSUSE OBS. Unfortunately, most of these are just not immediately available, and the ones that may be in OBS are from individuals, which gives me a little pause. Let's start with the native packages, and then we can jump into the other solution.

## openSUSE Packages

We can install Docker and Docker-Compose using *zypper*, so let's do that.

```Bash
$ sudo zypper install docker python3-docker-compose
```

Once installed, you may want to run through the [post installation](https://docs.docker.com/engine/install/linux-postinstall/) steps for Linux on the Docker website to execute without *sudo*. Those steps worked for me on both Tumbleweed and Leap 15.2. The Docker service is started or enabled yet, so that will require the following.

```Bash
$ sudo systemctl enable docker && sudo systemctl start docker
```

That's it for configuring Docker. All that's left is Docker-Compose, which doesn't require any additional setup. If you decide not to add your user to the Docker group, you will also need to execute the *docker-compose* command with *sudo*.

## Arkade: Portable DevOps Marketplace

All the other installations can use the tool [Arkade](https://github.com/alexellis/arkade). I have wanted to create a tool like Arkade for some time, and now I can enjoy using one without building it. Arkade is almost a one-stop-shop for all the DevOps and Kubernetes tooling that you need. Let's get Arkade installed first.

```Bash
$ curl -sLS https://dl.get-arkade.dev | sudo sh
x86_64
Downloading package https://github.com/alexellis/arkade/releases/download/0.6.35/arkade as /tmp/arkade
Download complete.

Running with sufficient permissions to attempt to move arkade to /usr/local/bin
New version of arkade installed to /usr/local/bin
There is already a command 'ark' in the path, NOT creating alias
main: line 176: arkade: command not found
```

Great, it was installed without a hitch. If you are on KDE Plasma, you can't use the alias *ark* since that is a native application, so expect the error above. Let's check it out to make sure that it works.

```Bash
$ arkade version
            _             _      
  __ _ _ __| | ____ _  __| | ___ 
 / _` | '__| |/ / _` |/ _` |/ _ \
| (_| | |  |   < (_| | (_| |  __/
 \__,_|_|  |_|\_\__,_|\__,_|\___|

Get Kubernetes apps the easy way

Version: 0.6.35
Git Commit: df53c4f6d9c604186b36aae7f0feb1d39940be8f
```

It's functioning as expected so that we can get installing Terraform, Packer, and kubectl.

```Bash
$ arkade get terraform --version=0.14.3 \
  && arkade get packer --version=1.6.6 \
  && arkade get kubectl
  
Downloading terraform
https://releases.hashicorp.com/terraform/0.14.3/terraform_0.14.3_linux_amd64.zip
32.09 MiB / 32.09 MiB [------------------------------------------------------------------------------------------] 100.00%
name terraform_0.14.3_linux_amd64.zip size:  33647270
/tmp/terraform
2020/12/28 20:44:00 extracted zip into /tmp: 1 files, 0 dirs (1.221184234s)
Tool written to: /home/phillipsj/.arkade/bin/terraform

# Add (terraform) to your PATH variable
export PATH=$PATH:$HOME/.arkade/bin/

# Test the binary:
/home/phillipsj/.arkade/bin/terraform

# Or install with:
sudo mv /home/phillipsj/.arkade/bin/terraform /usr/local/bin/

Downloading packer
https://releases.hashicorp.com/packer/1.6.6/packer_1.6.6_linux_amd64.zip
27.73 MiB / 27.73 MiB [------------------------------------------------------------------------------------------] 100.00%
name packer_1.6.6_linux_amd64.zip size:  29081121
/tmp/packer
2020/12/28 20:44:03 extracted zip into /tmp: 1 files, 0 dirs (1.285638958s)
Tool written to: /home/phillipsj/.arkade/bin/packer

# Add (packer) to your PATH variable
export PATH=$PATH:$HOME/.arkade/bin/

# Test the binary:
/home/phillipsj/.arkade/bin/packer

# Or install with:
sudo mv /home/phillipsj/.arkade/bin/packer /usr/local/bin/

Downloading kubectl
https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl
41.98 MiB / 41.98 MiB [------------------------------------------------------------------------------------------] 100.00%
Tool written to: /home/phillipsj/.arkade/bin/kubectl

# Add (kubectl) to your PATH variable
export PATH=$PATH:$HOME/.arkade/bin/

# Test the binary:
/home/phillipsj/.arkade/bin/kubectl

# Or install with:
sudo mv /home/phillipsj/.arkade/bin/kubectl /usr/local/bin/
```

If you look at the output, this is one of my favorite things about Arkade. It will install tools to your home directory unless you run it as elevated. Honestly, I wouldn't say I like putting many tools in */usr/bin* and prefer those installing in my home directory. One step that needs to execute is in the output, which is to add the *.arkade/bin* to your path. Here is the command to add it to your bashrc. You can replace that with your profile or zsh, etc.

```Bash
$ echo 'export PATH=$PATH:$HOME/.arkade/bin/' >>~/.bashrc
```

Now source your *.bashrc* to load in the new path so we can test.

```Bash
$ source .bashrc
```

Now we can test our installation. I am going to try which *terraform* and print its version.

```Bash
$ which kubectl
/home/phillipsj/.arkade/bin/kubectl

$ terraform version
Terraform v0.14.3
```

## Local K8s Cluster

Now this one is tricky and comes with a lot of personal preferences. If I were on a flavor of Ubuntu, I would use *MicroK8s* snap. Snaps have support on openSUSE, and I don't want to go with what I am comfortable using. Again, Arkade comes to the rescue as we can use it to install one of the following:

* [kind](https://kind.sigs.k8s.io/)
* [k3sup](https://github.com/alexellis/k3sup)
* [k3d](https://github.com/rancher/k3d)
* [minikube](https://minikube.sigs.k8s.io/)

I usually would quickly eliminate minikube from the equation, not this time. Some reported issues with Btrfs and k3s/k3d may make either of those not work. I find that a little funny considering that both are Rancher products and SUSE purchased Rancher this year. I need to give it some time. Out of all of these choices, I think I am going to go with kind. It will require another post so let's install it for now.

```Bash
$ arkade get kind
Downloading kind
https://github.com/kubernetes-sigs/kind/releases/download/v0.9.0/kind-linux-amd64
7.08 MiB / 7.08 MiB [--------------------------------------------------------------------------------------------] 100.00%
Tool written to: /home/phillipsj/.arkade/bin/kind

# Add (kind) to your PATH variable
export PATH=$PATH:$HOME/.arkade/bin/

# Test the binary:
/home/phillipsj/.arkade/bin/kind

# Or install with:
sudo mv /home/phillipsj/.arkade/bin/kind /usr/local/bin/
```

And to verify the installation.

```Bash
$ kind version
kind v0.9.0 go1.15.2 linux/amd64
```

Awesome!

## Conclusion

There are several different ways to achieve the result. I could have used a different combination of tools to get here, and I just felt this was the path of least resistance. I also got to learn more about Arkade. I will work through getting kind running, and if I am successful, I will share in a future post.

Thanks for reading,

Jamie
