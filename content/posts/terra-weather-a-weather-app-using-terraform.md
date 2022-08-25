---
title: "Terra Weather: A Weather App Using Terraform"
date: 2022-08-23T22:41:37-04:00
tags:
- Open Source
- Terraform
- HashiCorp
- Fun
- Terraform Apps
---

I finally feel like creating some content again. It's good to want to do fun things with tools that you like working with. I had this idea to see if I could be a version of my weather app like I did in [Rust](https://www.phillipsj.net/posts/rusty-weather-my-first-rust-app/) and [Go](https://www.phillipsj.net/posts/go-weather-my-first-go-app/) using Terraform. I used the [HTTP Provider](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) along with [post conditions](https://www.terraform.io/language/expressions/custom-conditions#preconditions-and-postconditions) to achieve it. I then used the [OpenWeatherMap API](https://openweathermap.org/api) to get the weather. You will need to set up a straightforward API key.  Let's get into the Terraform.

```HCL
terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
      version = "3.0.1"
    }
  }
}

provider "http" {
  # Configuration options
}

variable "zipcode" {
    type = string
    default = "90210"
}

variable "api_key" {
    type = string
}

data "http" "weather" {
  url = "https://api.openweathermap.org/data/2.5/weather?zip=${var.zipcode}&units=imperial&appid=${var.api_key}"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }

  lifecycle {
    postcondition {
      condition     = self.status_code != "200"
      error_message = "Error getting weather for ${var.zipcode}."
    }
  }
}

locals {
    result = jsondecode(data.http.weather.response_body)
}

output "report" {
    value = "The temp in ${local.result.name} is ${local.result.main.temp}F and ${local.result.weather.0.main}."
}
```

There isn't much to it. I use the HTTP data source and I use variables to set the API key and pass in the zip code. I then parse the results of the HTTP data source to the `jsondecode` function. Finally, I create the report by creating an output where I create a nice friendly message. Leveraging the new `postcondition` option allows errors in the API call to be handled. Now it's time to initialize our Terraform.

```Bash
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/http from the dependency lock file
- Installing hashicorp/http v3.0.1...
- Installed hashicorp/http v3.0.1 (signed by HashiCorp)

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

We can then `apply` our Terraform to get our weather report.

```Bash
$ terraform apply
data.http.weather: Reading...
data.http.weather: Read complete after 0s [id=https://api.openweathermap.org/data/2.5/weather?zip=90210&units=imperial&appid=XXXXXXXXXXXXXXXXXXXXXXXXXXXX]

Changes to Outputs:
  + report = "The temp in Beverly Hills is 79.7F and Clear."

You can apply this plan to save these new output values to the Terraform state,
without changing any real infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

report = "The temp in Beverly Hills is 79.7F and Clear."
```

That's a wrap and I hope you found this as fun as I did. 

Thanks for reading,

Jamie