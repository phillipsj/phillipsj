---
title: "Validating Variables in Terraform"
date: 2022-08-30T21:01:46-04:00
tags:
- Open Source
- Terraform
- HashiCorp
---

There are always new features being added to Terraform and a more recent set of features is the ability to put [validations](https://www.terraform.io/language/expressions/custom-conditions#input-variable-validation) on your variables. I am going to add validation to my Terraform weather application called [Terra Weather](https://www.phillipsj.net/posts/terra-weather-a-weather-app-using-terraform/). I am going to put some constraints on the `zipcode` variable to ensure that it is only a number and that it's only five digits. This limits it to just the USA right now. Let's get into it.

## Validation

Here is our variable.

```HCL
variable "zipcode" {
    type = string
    default = "90210"
}
```

Now we can add in our validation. We are going to ensure that we have the required five digits. We will also leverage two functions [`can`](https://www.terraform.io/language/functions/can) and [`tonumber`](https://www.terraform.io/language/functions/tonumber) to validate that it doesn't contain any alpha or special characters.

```HCL
variable "zipcode" {
  type    = string
  default = "90210"
  validation {
    condition     = length(var.zipcode) == 5 && can(tonumber(var.zipcode))
    error_message = "The zip code isn't a valid USA zip code."
  }
}
```

Now we can execute our TF passing in an invalid zip code to verify that it works.

```Bash
$ terraform apply --auto-approve --var zipcode=123
╷
│ Error: Invalid value for variable
│ 
│   on app.tf line 14:
│   14: variable "zipcode" {
│     ├────────────────
│     │ var.zipcode is "123"
│ 
│ The zip code isn't a valid USA zip code.
│ 
│ This was checked by the validation rule at app.tf:17,3-13.
```

If we passed in a value that has a length of five, but with any non-numeric, then it fails again.

## Wrapping Up

That's all that it takes to add in some validation of your variables. This goes a long way in ensuring that users know exactly what you are expecting as input. We also added a nice feature to Terra Weather. I have some other ideas on how to build out my Terraform app. 

Thanks for reading,

Jamie
