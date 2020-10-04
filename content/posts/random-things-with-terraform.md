---
title: "Random things with Terraform"
date: 2020-10-03T14:18:49-04:00
draft: true
tags:
- Open Source
- Terraform
- HashiCorp
---

Anytime you are creating resources, there is seems to always be a need to create a random id, string, etc. Fortunately, Terraform provides that ability with the [random](https://registry.terraform.io/providers/hashicorp/random/latest) provider. I have found this really useful when making Terraform demonstration examples that I know many will reference. A vital feature of these resources is the **keepers** functionality, which lets you trigger the resource to generate a new key when an additional value changes. Let's dive in and take a tour of what is provided. To use the provider, you just need to add it to the providers' list in your Terraform 0.13 block.

```HCL
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "2.3.0"
    }
  }
}
```

Now we can start implementing each of the resources to learn how they work.

## Random String

This is probably the [resource](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) in this provider that I make use of the most. It provides a lot of configurability to tailor to your needs. I use this to generate a random character set to append to resource names to make them unique. A big one of these is in Azure, the App Service name becomes part of the URL. When I have people running examples that I produce, this keeps the name unique enough to not have conflicts. Let's create a random string and an output variable.

```HCL
resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

output "resource_code" {
  value = random_string.resource_code.result
}
```

This configures the string to have a length of five and no special or uppercase characters. This keeps it URL friendly. Let's see the output.

```HCL
resource_code = 9jx2y
``` 

Honestly, I feel this resource provides a lot of utility due to all the available options.

## Random Id

The [random_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) resource can be used to generate ids that can be used for naming resources. The byte length can be adjusted to increase the entropy of the generated id. The output is interesting for this resource as it provides a base64, base64 URL, hex, and decimal options along with just the id. 

Let's create a random id and output so we can take a look at what is generated.

```HCL
resource "random_id" "my_id" {
  byte_length = 8
}

# full object
output "my_id" {
    value = random_id.my_id
}
```

Here is the output.

```HCL
my_id = {
  "b64" = "ciNq9AnC8c8"
  "b64_std" = "ciNq9AnC8c8="
  "b64_url" = "ciNq9AnC8c8"
  "byte_length" = 8
  "dec" = "8224534940876992975"
  "hex" = "72236af409c2f1cf"
  "id" = "ciNq9AnC8c8"
}
```

Some of these values have alpha characters and may not be suitable for some uses, though there is the decimal output. To use one of these specifically, you just do the following.

```HCL
output "random_id" {
    value = random_id.my_id.id
}
```

## Random Integer

This resource creates a random integer between the defined min and max. I haven't really used this one all that often.

```HCL
resource "random_integer" "my_integer" {
  min = 1
  max = 100
}

output "my_integer" {
  value = random_integer.my_integer.result
}
```

This is the integer generated.

```HCL
my_integer = 78
```

## Random Password

The [random_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) resource is similar to the *random_string* except it hides the output from the console. Here it is in action.

```HCL
resource "random_password" "my_password" {
  length  = 12
  special = true
}

output "my_password" {
  value = random_password.my_password.result
}
```

While the password is hidden in the console output, you can still get the value as an output variable. Keep this in mind when using it.

```HCL
my_password = 4pdF$+>ql)>0
```

## Random Pet

This is one that I didn't realize was in here until recently. If you have used Docker or Helm and noticed you get the randomly generated names, now you can do this with Terraform. The length is interesting as it determines the number of adjectives that get added to the name.

Here is a quick example.

```HCL
resource "random_pet" "my_name" {
  length = 2
}

output "my_name" {
  value = random_pet.my_name.id
}
```

This is the generated name. I think this is really cool, and I look forward to using it in the future.

```HCL
my_name = modern-sheep
```

## Random UUID

This resource does as described, it generated a UUID. Not really much to discuss as there are currently no attributes that can be set. This one can also be handy for generating passwords.

```HCL
resource "random_uuid" "my_uuid" { }

output "my_uuid" {
  value = random_uuid.my_uuid.result
}
```

Here is the UUID.

```HCL
my_uuid = f7243f6f-c375-d6c8-6fe9-af3c56d4b194
```

## Random Shuffle

This resource shuffles a list of inputs and can return the whole list or a subset of that list with the items not in the original order. Again, this is one that I haven't used. Let's take a look at what it can do.

```HCL
resource "random_shuffle" "my_numbers" {
  input        = ["one", "two", "three", "four"]
}

output "my_numbers" {
  value = random_shuffle.my_numbers.result
}
```

This is our shuffled list. If you only wanted two values from the list, then you can adjust the result count.

```HCL
my_numbers = [
  "three",
  "one",
  "four",
  "two",
]
```

## Conclusion

Hopefully, you found this useful. I stumbled across a few of these that I hadn't used before and learned more about the random string resource than I previously knew, so I thought I would share.

Thanks for reading,

Jamie
