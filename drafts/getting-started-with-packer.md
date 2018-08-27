---
Title: "Getting started with Packer"
Published: 06/28/2018 19S:53:25
Tags: 
- Open Source
- Packer
- HashiCorp
- Docker
- Digital Ocean
- AWS
---
# Getting started with Packer

I have been using a lot of really cool tools to stream line workflows and efforts. Many of those tools are created by [HashiCorp](https://www.hashicorp.com/). Tools like [Terraform](https://www.terraform.io/), [Vagrant](https://www.vagrantup.com/), [Vault](https://www.vaultproject.io/), and [Packer](https://www.packer.io/) have been very valauble. It is amazing what companies provide for free. In this post I am going to cover Packer. Packer allows images to be created for [Docker](https://www.docker.com/), [Hyper-V](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/about/), [AWS](https://aws.amazon.com/), [Azure](https://azure.microsoft.com), [Digital Ocean](https://www.digitalocean.com/), etc. using a command set of tooling and techniques. It is important to understand that it doesn't allow *"write once, target everything"* style of development. While many see this as an issue, I feel it doesn't detract from the advantages of using this tool. Along with targeting many platform images, it allos you to use multiple provisioners for privisioning the software on the server. Provisioners like [Ansible](https://www.ansible.com/), [Chef](https://www.chef.io/chef/), [Puppet](https://puppet.com/), or just plan shell scripts. All these options ensure that Packer will fit in your environment and for all teams depedent on you.

Nothing is better than a real world example to get you up and running with Packer. Here is the scenario that we are going to accomodate.

TODO: Better call out

You are on a team responsible for building our images for the dev teams and the ops team for deploying your servers. Currently for operations, your ops team deploys to a Hyper-V cluster for on-premise servers and to Digital Ocean for your cloud provider. One of your dev teams uses Docker while another team just runs Hyper-V locally for development. It takes you several hours to build one to two of those and you have at least three different ones to build. How these are provisioned have slight variations and you follow a manual check list.

With the given scenario, I am going to walk you through using Packer to streamline the process and increase repeatability for generating these different images. This would save the team described above many hours every month and will ensure devs are working on images that are exactly the same as production since they were produced using the same tool. We are going to build an image for a kubernetes tooling environment.

## Install Packer

Packer can be downloaded from [here](https://www.packer.io/downloads.html) for your OS. If you are running on Windows with [Chocolatey](https://chocolatey.org/) installed or running on Linux, here is how you install it.

#### Windows

```
~$ choco install packer -y
```

### Linux

```
~$ wget -O packer-installer.sh https://git.io/f4bLb
~$ chmod +x packer-installer.sh
~$ ./packer-installer.sh
```

Now you can run the following:

```
~$ packer
Usage: packer [--version] [--help] <command> [<args>]

Available commands are:
    build       build image(s) from template
    fix         fixes templates from old versions of packer
    inspect     see components of a template
    push        push a template and supporting files to a Packer build service
    validate    check that a template is valid
    version     Prints the Packer version
```

## Create your project structure

I haven't found a lot of guidance on the best way to structure a repo, here is how we are going to do it.

```
mkdir packer-tutorial && cd packer-tutorial
mkdir tooling && cd tooling
mkdir kube && cd kube
touch main.json
```

This will create a very basic structure that allows us to expand any tooling images and it follows more of an approach I have adopted for Terraform.

## Creating basic Packer file.

Open the main.json file and let's get hacking.

```
{
    "variables": {              
    },
    "builders": [
        {
          "type": "docker",
          "image": "ubuntu:18.04",
          "commit": true,
          "message": "Packer"
        }
    ],  
    "provisioners": [
      {
        "type": "shell",
        "inline": [
          "apt-get update",
          "apt-get upgrade -y",
          "apt-get install curl -y"
        ]
      }
    ]
}
```

Here is what is happening, we are going to use a docker builder and pull done Ubuntu 18.04 as our base image and then we are going to provision using inline shell.  

Now let's run it.

```
~$ packer build main.json
```

When that is complete, let's look for the image in docker.

```
~$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
<none>              <none>              8896aa498f01        12 seconds ago      144MB
```

Now that Docker is out of the way, let's create a Hyper-V image.

## Adding Hyper-V

We are going to add a builder, but we don't have to add a provisioner.

```
```