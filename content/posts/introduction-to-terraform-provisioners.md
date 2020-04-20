---
title: "Introduction to Terraform Provisioners"
date: 2020-04-19T19:28:37-04:00
tags:
- Open Source
- Terraform
- HashiCorp
---

As you continue learning about Terraform, you will start hearing about [provisioners](https://www.terraform.io/docs/provisioners/index.html). Terraform provisioners can be created on any resource and provide a way to execute actions on local or remote machines. These give a hook to allow supplementing Terraform were a feature isn't yet present or to extend the capabilities of Terraform. As the documentation points out, these are not "go-to" solutions as these don't integrate with Terraform state. There are three categories for the default provisioners. Those categories are file operations, script execution, and configuration management/provisioning. Let's get started discussing each of these.

## File Provisioner

I have discussed the use of this provisioner in other [posts](https://www.phillipsj.net/posts/create-an-archive-and-upload-it-with-terraform/). The provisioner was used to collect or create content that needs uploading to a remote host. This use could be gathering information from other Terraform resources and generating a config file that gets uploaded to a server. It can also move files to different locations as part of the Terraform execution. It comes down to your needs as to how you would use it. Here is an example.

```hcl
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

## Script Execution

This group includes the **remote-exec** and **local-exec** provisioners. I have been mentioned the [local exec](https://www.terraform.io/docs/provisioners/local-exec.html) before in a [post](https://www.phillipsj.net/posts/how-to-handle-unsupported-azure-features-in-terraform/) on how to leverage the Azure CLI to execute commands that the Terraform provider for Azure doesn't support. 

#### Local Exec

The local exec provisioner executes code locally on the machine that is running the Terraform. This provisioner is useful when you need steps to occur with other tools you have installed. Here is an example.

```hcl
resource "null_resource" "azure-cli" {
  
  provisioner "local-exec" {
    # Call Azure CLI Script here
    command = "ssl-script.sh"

    # We are going to pass in terraform derived values to the script
    environment {
      webappname = "${azurerm_app_service.demo.name}"
      resourceGroup = ${azurerm_resource_group.demo.name}
    }
  }

  depends_on = ["azurerm_app_service_custom_hostname_binding.demo"]
}
```

#### Remote Exec

The [remote exec](https://www.terraform.io/docs/provisioners/remote-exec.html) provisioner executes tools and scripts on a remote target. This ability comes in handy if you need to run a command or script on a VM that doesn't allow some other way. Let's look at how to do that for an AWS instance.

```hcl
resource "aws_instance" "my_server" {
  # ...

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello World'"
    ]
  }
}
```

## Configuration Management/Provisioning

This category is the biggest default category with four provisioners out of the box. Those provisioners are [chef](https://www.terraform.io/docs/provisioners/chef.html), [habitat](https://www.terraform.io/docs/provisioners/habitat.html), [puppet](https://www.terraform.io/docs/provisioners/puppet.html), and [salt-masterless](https://www.terraform.io/docs/provisioners/salt-masterless.html). While I have tinkered with all of these frameworks, I haven't used these in a production capacity. Most of the needs I have been simple and only required the remote exec to run a few commands. If you are doing a lot of IaaS and already use these tools, then you could standardize on the provisioner for doing additional configuration on a virtual machine. Now I have been discussing these in the context of IaaS. However, provisioners can exist on any resource so that you could execute a recipe or a puppet module. I plan to do new posts on these, as these have some interesting scenarios to explore.

## Conclusion

I hope you found this introduction useful as it explores provisioners and provides additional context around the topic. I am excited to do more posts on these as it's a valuable tool to have in the toolbox.
