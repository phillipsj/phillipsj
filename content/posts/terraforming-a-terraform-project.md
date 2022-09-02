---
title: "Terraforming a Terraform Project"
date: 2022-09-01T21:26:08-04:00
tags:
- Open Source
- Terraform
- HashiCorp
---

I am back with another fun use of Terraform. I have this silly idea to bootstrap a Terraform project using Terraform. It's a pretty interesting idea and these thought exercises push your understanding of what is possible. Let's get into it. 

## Creating the project

I will be using the [local](https://registry.terraform.io/providers/hashicorp/local/latest/docs) provider and HashiCorp's recommended [project structure](https://www.terraform.io/language/modules/develop/structure). The first step is to add our provider.

```HCL
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

provider "local" {
  # Configuration options
}
```

Now we can create a variable that will define the path we want to use for our project. 

```HCL
variable "path" {
  description = "The path to creating a Terraform project/module."
  type        = string
}
```

Finally, we can create our three files: `main.tf`, `variables.tf`, and `outputs.tf`. We will use the `local_file` resource to do it.

```HCL
resource "local_file" "main" {
  content  = ""
  filename = "${var.path}/main.tf"
}

resource "local_file" "variables" {
  content  = ""
  filename = "${var.path}/variables.tf"
}

resource "local_file" "outputs" {
  content  = ""
  filename = "${var.path}/outputs.tf"
}
```

## Using the Terraform

The basics are in place to use Terraform to create a project. Let's do that now.

```Bash
$ terraform apply -auto-approve -var path=../test

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # local_file.main will be created
  + resource "local_file" "main" {
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../test/main.tf"
      + id                   = (known after apply)
    }

  # local_file.outputs will be created
  + resource "local_file" "outputs" {
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../test/outputs.tf"
      + id                   = (known after apply)
    }

  # local_file.variables will be created
  + resource "local_file" "variables" {
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../test/variables.tf"
      + id                   = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.
local_file.main: Creating...
local_file.outputs: Creating...
local_file.variables: Creating...
local_file.variables: Creation complete after 0s [id=da39a3ee5e6b4b0d3255bfef95601890afd80709]
local_file.outputs: Creation complete after 0s [id=da39a3ee5e6b4b0d3255bfef95601890afd80709]
local_file.main: Creation complete after 0s [id=da39a3ee5e6b4b0d3255bfef95601890afd80709]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

We can go check to see if the files are created in our directory.

```Bash
ls ../test
main.tf  outputs.tf  variables.tf
```

Looks like the files exist.

## Wrapping up

I hope you had some fun following along with this tangent. There are a ton of other options to explore.

Thanks for reading,

Jamie