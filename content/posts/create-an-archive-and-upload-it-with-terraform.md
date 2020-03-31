---
title: "Create an archive and upload it with Terraform"
date: 2020-03-30T20:10:27-04:00
tags:
- Open Source
- Terraform
- HashiCorp
---

Terraform is such a versatile tool and supports many features that are always fun to discover. Today we are going 
to learn about the [Archive provider](https://www.terraform.io/docs/providers/archive/index.html) and the [File provisioner](https://www.terraform.io/docs/provisioners/file.html).
The Archive provider allows you to create a zip file of a single file, a directory, or content generated withing your Terraform template. 
The second feature we will be levarging is the file provisioner, which allows you to upload a file or directory to a remote 
server using either SSH or Windows Remoting. The file provisioner will need to be used as a section within a resource. A 
typical example would be to upload a file to a virtual machine resource. However, you can also leverage it with a 
[Null resource](https://www.terraform.io/docs/providers/null/resource.html). A null resource is a last resort tool that I should
probably cover more in depth in a future blog post. 

With that out of the way, you may be curious as to what we are going to build today. We are going to create our main.tf and the file
that we want to use to generate an archive. Then we will use a null resource with a file provisioner to upload that archive file to a
remote server over SSH. Let's get started.

## Setup

Create your main.tf and data file to archive.

```bash
$ touch main.tf
$ mkdir data_backup
$ touch data_backup/data.csv
$ ls 
```

## Terraform

Okay, now that we have the file created open your main.tf and add the following. 

```hcl
provider "archive" {}

variable "user" {
  type = string
}

variable "password" {
  type = string
}

variable "host" {
  type = string
}

data "archive_file" "data_backup" {
  type        = "zip"
  source_file = "data_backup/data.csv"
  output_path = "data_backup.zip"
}

resource "null_resource" "upload" {
  provisioner "file" {
    source      = data.archive_file.data_backup.output_path
    destination = "/home/${var.user}/${data.archive_file.data_backup.output_path}"

    connection {
      type     = "ssh"
      user     = var.user
      password = var.password
      host     = var.host
    }
  }
}
```

We added our archive provider, then a few variables for SSH connection. Then we get to the main course which is the data
resource which creates our archive and then the null resource that creates our SSH connection and uploads our archive.

Since we included variables for the sensitive information when you execute you will be prompted for the values. Now let's execute
our apply.

```bash
$ terraform apply 
data.archive_file.data_backup: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.upload will be created
  + resource "null_resource" "upload" {
      + id = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

null_resource.upload: Creating...
null_resource.upload: Provisioning with 'file'...
null_resource.upload: Creation complete after 2s [id=4557742749054818375]
```

Now let's log into our remote server and see if our file exists.

```bash
$ ssh me@host
$ ls
data_backup.zip
```

Looks like it is there as expected.

## Conclusion

Now this isn't a real world use case for this feature. It does demonstrate the capabilities that exist within Terraform.
I have used these to upload executables and configuration to virtual machines many times which existing tools did not fit or work.
These tools are the tools you have in your toolbox when other tools don't always work, but are not the first tools you choose.

Thanks for reading,

Jamie