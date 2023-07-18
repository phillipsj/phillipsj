---
title: "Using Terraform Outputs in Powershell"
date: 2023-07-17T22:44:12-04:00
tags:
- Open Source
- PowerShell
- Microsoft And Linux
- Azure
- Terraform
- PowerShell Core
- Microsoft
- HashiCorp
---

I have been using Terraform for more than five years, and in that time, I've never needed to consume outputs from executed Terraform until recently. It was a strange realization, and I found myself deciding the best way to do it. You may have noticed that I have been using [Terraform with .NET](https://www.phillipsj.net/posts/terraform-as-a-dotnet-cli-tool/), and I've also been using a project called [Invoke-Build](https://github.com/nightroman/Invoke-Build) for my build scripting. I have found Invoke-Build and .NET tools an excellent combination for creating builds. It gives me that feeling of using Cake without using anything specifically bespoke. The scenario that led to the need was doing a deployment in Invoke-Build using the [Azure PowerShell](https://learn.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-10.1.0) modules and needing the name of the resource group and app service that was auto-generated in the Terraform code. Oddly enough, most of the time, naming for me has been something static passed in, not something auto-generated with a high degree of entropy. I discovered after some light research that the `terraform output` command can return the current output of the Terraform run as JSON. I combined that with the [`Convert-FromJson`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-json?view=powershell-7.3) commandlet will return me the output as a PowerShell object. A PowerShell object makes it convenient for use in my deploy task within my build script. Let's create an example to see it all together.

## Project Setup

First, let's create a directory.

```Bash
$ mkdir tf-ps
```

We will create a .NET tool manifest in that directory and install Invoke-Build.

```Bash
$ dotnet new tool-manifest
The template "Dotnet local tool manifest file" was created successfully.

$ dotnet tool install --local ib
You can invoke the tool from this directory using the following commands: 'dotnet tool run ib' or 'dotnet ib'.
Tool 'ib' (version '5.10.4') was successfully installed. Entry is added to the manifest file ../tf-ps/.config/dotnet-tools.json.
```

Now I like to use the Invoke-Build project template for generating my invoke build script. You can install that with the following.

```Bash
$  dotnet new --install Invoke-Build.template
The following template packages will be installed:
   Invoke-Build.template

Success: Invoke-Build.template::1.0.4 installed the following templates:
Template Name        Short Name  Language    Tags               
-------------------  ----------  ----------  -------------------
Invoke-Build script  ib          PowerShell  Invoke-Build/Script
```

Now we can create our build script at the root of our project with the following command.

```Bash
$ dotnet new ib
The template "Invoke-Build script" was created successfully.
```

Remove the build and clean tasks since we won't be using those. Now we can do our Terraform setup. First, we need to install the `dotnet-terraform` tool.

```Bash
$ dotnet tool install --local dotnet-terraform
You can invoke the tool from this directory using the following commands: 'dotnet tool run dotnet-terraform' or 'dotnet dotnet-terraform'. 
Tool 'dotnet-terraform' (version '1.5.3') was successfully installed. Entry is added to the manifest file ../tf-ps/.config/dotnet-tools.json.
```

Finally, we can create our Terraform file. 

```Bash
$ touch main.tf
```

We now have the basics in place to start creating our example Terraform and the outputs we want to read.

## Creating our Terraform

The plan is to keep this simple. We will use the [random provider](https://registry.terraform.io/providers/hashicorp/random/latest/docs) to generate two names and create two outputs to return those names. Open the main.tf, and let's get started.

```HCL
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "random" {
  # Configuration options
}

resource "random_string" "resource_group_name" {
  length  = 16
  special = false
  upper   = false
}

resource "random_string" "app_service_name" {
  length  = 16
  special = false
  upper   = false
}

output "resource_group_name" {
  value = random_string.resource_group_name.result
}

output "app_service_name" {
  value = random_string.app_service_name.result
}
```

Now let's create a few Invoke-Build tasks for managing Terraform.

```PowerShell
<#
.Synopsis
	Build script, https://github.com/nightroman/Invoke-Build
#>

param(
	[ValidateSet('Debug', 'Release')]
	[string]$Configuration = 'Release'
)

# Synopsis: Format Terraform.
task fmt {
	dotnet terraform fmt --recursive
}

# Synopsis: Format Terraform.
task init fmt, {
    dotnet terraform init
}

# Synopsis: Validate Terraform
task validate init, {
	dotnet terraform validate 
}

# Synopsis: Apply Terraform
task apply validate, {
	dotnet terraform apply --auto-approve 
}

# Synopsis: Default task.
task . validate
```

We now have tasks for formatting, initializing, validating, and applying our Terraform. Let's run our build script using our default task to ensure we have formatted and validated our TF.

```Bash
$ dotnet ib
Build . ../tf-ps/tf-ps.build.ps1
Task /./validate/init/fmt
Done /./validate/init/fmt 00:00:00.2413400
Task /./validate/init

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/random from the dependency lock file
- Using previously-installed hashicorp/random v3.5.1

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
Done /./validate/init 00:00:00.8462540
Task /./validate
Success! The configuration is valid.

Done /./validate 00:00:01.1795593
Done /. 00:00:01.1844631
Build succeeded. 4 tasks, 0 errors, 0 warnings 00:00:01.3428812
```

Now we can create our `deploy` task that will read the output from Terraform once it is applied. We can do this in any task, I'm just doing this as part of my deploy task since that is where I will be using it. The key part is to ensure that you call `terraform output` with the `--json` option.

```PowerShell
# Synopsis: Deploy something using TF outputs
task deploy {
	$output = dotnet terraform output --json | ConvertFrom-Json
    assert($output.Count -eq 1)
    Write-Build Green "$($output.resource_group_name.value)"
    Write-Build Green "$($output.app_service_name.value)" 
}
```

The setup is now all complete. The major pieces are in place, so we can apply our Terraform and run our deploy task.

## Apply and Deploy

The first step is to apply our Terraform using our task. The apply task we created will format, initialize, and validate the Terraform before executing the apply.

```Bash
$ dotnet ib apply
Build apply ../tf-ps/tf-ps.build.ps1
Task /apply/validate/init/fmt
Done /apply/validate/init/fmt 00:00:00.2480703
Task /apply/validate/init

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/random from the dependency lock file
- Using previously-installed hashicorp/random v3.5.1

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
Done /apply/validate/init 00:00:00.7502469
Task /apply/validate
Success! The configuration is valid.

Done /apply/validate 00:00:01.0750479
Task /apply

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # random_string.app_service_name will be created
  + resource "random_string" "app_service_name" {
      + id          = (known after apply)
      + length      = 16
      + lower       = true
      + min_lower   = 0
      + min_numeric = 0
      + min_special = 0
      + min_upper   = 0
      + number      = true
      + numeric     = true
      + result      = (known after apply)
      + special     = false
      + upper       = false
    }

  # random_string.resource_group_name will be created
  + resource "random_string" "resource_group_name" {
      + id          = (known after apply)
      + length      = 16
      + lower       = true
      + min_lower   = 0
      + min_numeric = 0
      + min_special = 0
      + min_upper   = 0
      + number      = true
      + numeric     = true
      + result      = (known after apply)
      + special     = false
      + upper       = false
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + app_service_name    = (known after apply)
  + resource_group_name = (known after apply)
random_string.app_service_name: Creating...
random_string.resource_group_name: Creating...
random_string.resource_group_name: Creation complete after 0s [id=z5w9oduvn7ghsqys]
random_string.app_service_name: Creation complete after 0s [id=u2krolx9mo9e5c8o]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

app_service_name = "u2krolx9mo9e5c8o"
resource_group_name = "z5w9oduvn7ghsqys"
Done /apply 00:00:01.4561331
Build succeeded. 4 tasks, 0 errors, 0 warnings 00:00:01.5694294
```

Great! Make a note of the outputs from the apply. We can now execute our deploy task to use them.

```Bash
$ dotnet ib deploy
Build deploy ../tf-ps/tf-ps.build.ps1
Task /deploy
z5w9oduvn7ghsqys
u2krolx9mo9e5c8o
Done /deploy 00:00:00.2804354
Build succeeded. 1 tasks, 0 errors, 0 warnings 00:00:00.4142101
```

The outputs from the PowerShell object match the output from the apply task. 

## Wrapping Up

Such a simple discovery on my behalf that I thought I would share. It's nice to work with output from a CLI tool as an object. That is one of the many things I appreciate about PowerShell over other shell environments.

Thanks for reading,

Jamie
