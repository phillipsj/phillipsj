---
title: "Terraform as a .NET CLI Tool"
date: 2023-06-30T22:30:43-04:00
tags:
- Open Source
- Terraform
- .NET
- .NET Tool
---

I have been working on a project in my limited free time the last couple of weeks called [dotnet-terraform](https://github.com/phillipsj/dotnet-terraform). The project packages [Terraform](https://www.terraform.io/) as a .NET CLI tool that will be available for Windows x64, Linux x64, Linux arm64, and MacOS arm64. I'm only supporting LTS versions of.NET and the platforms listed previously unless someone requests to support additional versions or platforms.

## Why

I created this project to solve two problems I was experiencing, and I hope this solves the same issues for you. The first issue is needing a simple and effective way to install Terraform on a target environment. I don't like my logic tied up in platform-specific YAML steps since I can't often run that locally. By wrapping Terraform as a .NET CLI tool, I can ensure that I can easily install Terraform locally. The second benefit is ensuring I always have the same version of Terraform that I used to write the infrastructure locally and on the build server. Installing Terraform as a [local tool](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-tool-install#local-tools) ensures I always have the correct version that a specific project requires.

## Getting Started

You can install this project as either a global or local tool. The intent of the project is to use it as a local tool while a global install works just as well.

### Local Install

The first step is to ensure you have a manifest created. The manifest will need checked into source control.

```Bash
dotnet new tool-manifest
```

Now install the tool using the version you want.

```Bash
dotnet install dotnet-terraform --version "*-rc*"
```

### Global Install

The command is:

```Bash
dotnet install -g dotnet-terraform --version "*-rc*"
```

## Usage

This tool is just a wrapper around Terraform. You can pass the exact commands and arguments, and it should work. The tool command is `dotnet-terraform`. By naming the command `dotnet-terraform` I ensure there aren't any conflicts with other installations for Terraform. This tool relies on how the naming conventions work as specified here for [global tools](https://learn.microsoft.com/en-us/dotnet/core/tools/global-tools#invoke-a-global-tool) and [local tools](https://learn.microsoft.com/en-us/dotnet/core/tools/global-tools#invoke-a-local-tool). I advise to use the following command style, `dotnet terraform`, and you should get the desired behavior you expect.

Examples:

```Bash
$ dotnet terraform version
Terraform v1.5.0
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.5.2. You can update by downloading from https://www.terraform.io/downloads.html
```

```Bash
$ dotnet terraform fmt --help
Usage: terraform [global options] fmt [options] [target...]

  Rewrites all Terraform configuration files to a canonical format. Both
  configuration files (.tf) and variables files (.tfvars) are updated.
  JSON files (.tf.json or .tfvars.json) are not modified.

  By default, fmt scans the current directory for configuration files. If you
  provide a directory for the target argument, then fmt will scan that
  directory instead. If you provide a file, then fmt will process just that
  file. If you provide a single dash ("-"), then fmt will read from standard
  input (STDIN).

  The content must be in the Terraform language native syntax; JSON is not
  supported.
...
```

## Wrapping Up

Please reach out and let me know if you find this useful. I have a few features I can think I want to add that could be useful outside of just wrapping Terraform like I'm currently doing.

Thanks for reading,

Jamie

