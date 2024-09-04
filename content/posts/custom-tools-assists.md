---
title: "Custom Tools: Assists"
date: 2024-09-04T17:15:00-04:00
tags:
- Open Source
- Python
- Containers
- Tools
- Kubernetes
- AWS
- Azure
- Crane
---

I said in a [previous post](https://www.phillipsj.net/posts/cookiecutter-terraform/) that I was going to be working on streamlining a lot of my personal processes and ways that I do things. One of the ways that I'm going to be achieving this is my working on my own custom CLI tool that packages of lots of the things that I find myself doing on a regular basis. With that said, I would like to introduce you all to [Assists](https://github.com/phillipsj/assists). It is a Python-based CLI
tool that I will be bundling up shortcuts and workflow items that I can share with everyone. It is currently published on [PyPI](https://pypi.org/project/assists/) and my vision for how it will be consumed is using [pipx](https://github.com/pypa/pipx).

The first couple of commands are designed for making it easier to log into Amazon ECR and Azure ACR. Both of these CLI tools have an easy way to perform [Docker](https://www.docker.com/) logins. However, neither of these tools has any shortcuts for [Podman](https://podman.io/) or [Crane](https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane.md). Let's investigate some examples, which all assume you’re already authenticated with the correct CLI tool.

### AWS Commands

If you want to log in to AWS ECR using Podman, you would need to do the following: 

```bash
aws ecr get-login-password --region <region> --profile <profile> \
  | podman login --username AWS \
  --password-stdin <registry>
```

If you use `assists` it becomes:

```bash
ast aws podman <registry> --profile <profile>
```

Here is Crane without `assists`:

```bash
aws ecr get-login-password --region <region> --profile <profile> \
  | podman login --username AWS \
  --password-stdin <registry>
```

Crane with `assists` becomes:

```bash
ast aws crane <registry> --profile <profile>
```

### Azure Commands

If you want to log in to Azure ACR using Podman, you would need to do the following: 

```bash
podman login <registry> \
  -u 00000000-0000-0000-0000-000000000000 
  -p \
  "$(az acr login --name <registry> --expose-token -o tsv --query accessToken)"
```

If you use `assists` it becomes:

```bash
ast az podman <registry>
```

Here is Crane without `assists`:

```bash
crane auth login <registry> \
  -u 00000000-0000-0000-0000-000000000000 
  -p \
  "$(az acr login --name <registry> --expose-token -o tsv --query accessToken)"

```

Crane with `assists` becomes:

```bash
ast az crane <registry>
```

## Wrapping Up

I have several plans of more tasks that I want to add, so the tool should grow as time permits. Please install and use it as that is the point of sharing it. If you run across any bugs or think you may have something that would be useful, then please open up an issue so we can discuss. The current tooling is in flux, however, I have settled on using Python and [typer](https://typer.tiangolo.com/).

Thanks for reading,

Jamie