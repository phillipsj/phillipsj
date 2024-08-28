---
title: "Optional Properties in Terraform"
date: 2024-08-28T18:29:51-04:00
tags:
- Open Source
- Terraform
- HashiCorp
---

I stumbled across an interesting issue this week, and I thought I would share. I needed to retrofit additional capability into a module without causing any changes. The Terraform would pass a map to the module and loop over it in a for each on a resource. There was a property that I wanted to see a value for only if that property existed in the object. The second item was to then use another map inside the object to only create a set of dynamic blocks if it existed. It was a fun little issue. I also learned how to use [`try`](https://developer.hashicorp.com/terraform/language/functions/try) which is a nice way to test if a value exists and if not set a default .Let me take you through it from a basic scenario to a more complex one.

Current example using locals:

```HCL
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

locals {
  tests = {
    "test1" = {
      length = 8
      prefix = "test1"
    }
    "test2" = {
      length = 4
    }
  }
}

provider "random" {
  # Configuration options
}

resource "random_id" "test" {
  for_each    = local.tests
  prefix = try(each.value.prefix, "default")
  byte_length = each.value.length
}
```

Here is the result:

```Bash
Terraform will perform the following actions:

  # random_id.test["test1"] will be created
  + resource "random_id" "test" {
      + b64_std     = (known after apply)
      + b64_url     = (known after apply)
      + byte_length = 8
      + dec         = (known after apply)
      + hex         = (known after apply)
      + id          = (known after apply)
      + prefix      = "test1"
    }

  # random_id.test["test2"] will be created
  + resource "random_id" "test" {
      + b64_std     = (known after apply)
      + b64_url     = (known after apply)
      + byte_length = 4
      + dec         = (known after apply)
      + hex         = (known after apply)
      + id          = (known after apply)
      + prefix      = "default"
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

This works as expected with a local and with newer versions of Terraform, this works as a variable. However, if you’re using an older version of Terraform, you may need to set the variable to type `any` instead of using `map`.

Let's look at a more complex example with nested items in a map using an AWS resource.

```HCL
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.64.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

locals {
  tests = {
    "test1" = {
      attribute = "Id"
      type      = "S"
    }
    "test2" = {
      attribute = "Id"
      type      = "S"
      ttl       = false
      additional_attrs = {
        "Name" = {
          type = "S"
        }
        "Age" = {
          type = "N"
        }
      }
    }
  }
}

resource "aws_dynamodb_table" "main" {
  for_each       = local.tests
  name           = each.key
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"
  range_key      = "GameTitle"

  attribute {
    name = each.value.attribute
    type = each.value.type
  }

  dynamic "attribute" {
    for_each = try(each.value.additional_attrs, {})
    content {
      name = attribute.key
      type = attribute.value.type
    }
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = try(each.value.ttl, true)
  }
}
```

This isn't the best looking Terraform and isn't how I would do it if I could do proper refactoring. It does achieve the goal of extending the current capabilities with minimal changes to the module interface. 

Thanks for reading,

Jamie