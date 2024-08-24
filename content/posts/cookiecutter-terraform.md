---
title: "Cookiecutter Terraform"
date: 2024-08-23T21:25:09-04:00
tags:
- Terraform
- Python
- DevOps
- SRE
- Principles
- Processes
- Tools
---

I have been wanting a more streamlined way to create my preferred style of creating a [Terraform](https://www.terraform.io/) project.
My preferred style is very close to what is documented in the [official docs](https://developer.hashicorp.com/terraform/language/style#file-names) with a few modifications around how environments and
backends are handled. I like to put as much configuration in source control and var files as possible. I strictly pass secrets 
using environment variables. I’ve attempted to do this several times in the past, and I’ve finally just used a solution that
I’ve been considering for a while. It's time to get it done, so I can start using it to speed up day-to-day tasks.

The solution I finally settled on is leveraging [cookiecutter](https://github.com/cookiecutter/cookiecutter). Cookiecutter is an awesome way
to template creating all kinds of projects, and it's intuitive to use. My solution is called [cookiecutter-terraform](https://github.com/phillipsj/cookiecutter-terraform). 


I hope you find it useful too.

Thanks for reading,

Jamie