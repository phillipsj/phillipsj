---
title: "Yes, Terraform can do that: Docker"
date: 2020-03-28T22:14:52-04:00
tags:
- Open Source
- Terraform
- HashiCorp
---

Back with another post about something else you can use with Terraform, Docker. The [Docker Provider](https://www.terraform.io/docs/providers/docker/index.html) can work with local and remote docker daemons. Here is a simple example that pulls the BusyBox image and creates a container 
that executes the sleep command.

```hcl
provider "docker" {
  host = "tcp://127.0.0.1:2376/"
}

# Create a container
resource "docker_container" "tf" {
  image = docker_image.busybox.latest
  name  = "tfdocker"
  command = ["sleep", "1000000"]
}

resource "docker_image" "busybox" {
  name = "busybox:latest"
}
```

Save this as *docker.tf*, and we will use it to create a Docker container.

```bash
$ terraform apply --auto-approve
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

Now, let's check our running containers.

```bash
$ docker ps
CONTAINER ID   IMAGE          COMMAND           CREATED              NAMES
d55638aa2a4c   83aa35aa1c79   "sleep 1000000"   About a minute ago   tfdocker
```

Now we can remove this container by executing the destroy command.

```bash
$ terraform destroy --auto-approve
Destroy complete! Resources: 2 destroyed.
```

That's it for the introduction to working with the Docker provider. There is one last remaining item that I glossed over.
By default, at least on Linux, your Docker daemon isn't exposed over the TCP port and local address. There are a few 
different ways to achieve this, the idea that I thought was the easiest is configuring a systemd unit that adds the extra
arguments to the docker run command that exposes the daemon at 127.0.0.1 on port 2376.

Create an empty ovveride.conf file.

```bash
$ sudo touch /etc/systemd/system/docker.service.d/override.conf
```

Now add the following to that file.

```toml
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2376
```

What we are doing is passing an additional host with the last *-H* flag. Now we can reload systemd to pick up our new
unit and restart the Docker service.

```bash
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker.service
```

Once that restarts, you can now execute your Terraform.

Thanks for reading,

Jamie
