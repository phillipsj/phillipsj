---
title: "Terraforming AWS IAM Policies"
date: 2021-01-24T16:48:16-05:00
tags:
- Open Source
- Terraform
- HashiCorp
- AWS
- IAM
---

Working with IAM policies and roles in AWS is often very trying. Writing all of that JSON is painful to me personally and doing the JSON inline when using Terraform is even more frustrating. This weekend, I found out that you can write IAM policies using a Terraform data resource that will then output the JSON so it can be consumed in a policy or role resource. I find that very exciting, so I thought I would share. Another benefit is that you will get some help writing the policy because of the Terraform objects.

## Creating the base Terraform

Let's add our Terraform block and our provider configuration to start.

```YAML
terraform {
  required_version = ">= 0.14.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.25.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

## Discussion of the IAM Policy

I often find myself creating some custom policies around S3. Let's view a JSON policy from the documentation that I modified. This will grant list on the bucket, and then we allow objects to be retrieved.

```JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::tfiam"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": ["arn:aws:s3:::tfiam/*"]
    }
  ]
}
```

We are going to want to assign this to an EC2 role, which looks like below.

```JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
```

We could easily inline these into Terraform, and it would be like this.

```HCL
resource "aws_iam_role" "tf_role" {
  name = "TerraformRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = {
    name = "TerraformRole"
  }
}
```

That isn't very clean and can make your Terraform challenging to read or reason. Terraform fortunately has a data resource that we can use to define these better than the inline JSON file. Let's check it out.

## Terraform IAM Policies and Roles

Let's start by writing our S3 read-only policy in Terraform using the *aws_iam_policy_document*.

```HCL
data "aws_iam_policy_document" "s3_readonly" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets"
    ]

    resources = [
      "arn:aws:s3:::tfiam"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::tfiam/*"
    ]
  }
}
```

We can now use this policy document to create our policy.

```HCL
resource "aws_iam_policy" "tf_s3_readonly" {
  name        = "TerraformS3Readonly"
  description = "Terraform S3 readonly access."
  policy      = data.aws_iam_policy_document.s3_readonly.json
}
```

Great, we now the policy in place. Let's create our IAM role policy.

```HCL
data "aws_iam_policy_document" "ec2_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
```

Now we can create our IAM role with Terraform and assign the policy document.

```HCL
resource "aws_iam_role" "tf_role" {
  name = "TerraformRole"

  assume_role_policy = data.aws_iam_policy_document.tf_role.json

  tags = {
    name = "TerraformRole"
  }
}
```

Finally, we can attach our S3 policy to our IAM role.

```HCL
resource "aws_iam_role_policy_attachment" "tf_attach" {
  role       = aws_iam_role.tf_role.name
  policy_arn = aws_iam_policy.tf_s3_readonly.arn
}
```

Let's validate our Terraform then apply it to make sure that it creates everything successfully.

```Bash
$ terraform validate
Success! The configuration is valid.

$ terraform apply -auto-approve
aws_iam_policy.tf_s3_readonly: Creating...
aws_iam_role.tf_role: Creating...
aws_iam_role.tf_role: Creation complete after 1s
aws_iam_policy.tf_s3_readonly: Creation complete after 1s
aws_iam_role_policy_attachment.tf_attach: Creating...
aws_iam_role_policy_attachment.tf_attach: Creation complete after 1s

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

Awesome! We now have a more native Terraform way to define our policies. Make sure to clean up these by running destroy.

```Bash
terraform destroy -auto-approve
aws_iam_role_policy_attachment.tf-attach: Destroying...
aws_iam_role_policy_attachment.tf-attach: Destruction complete after 1s
aws_iam_role.tf_role: Destroying...
aws_iam_policy.tf_s3_readonly: Destroying...
aws_iam_policy.tf_s3_readonly: Destruction complete after 1s
aws_iam_role.tf_role: Destruction complete after 1s

Destroy complete! Resources: 3 destroyed.
```

## Conclusion

I hope you found this useful. I prefer having the policy being defined natively in Terraform and not having that inline JSON. The inline JSON is excellent if you need to copy and paste, so there is that advantage. If you want access to the policies as JSON, then you have two choices. The first choice is to get the JSON from the state. The other alternative is to define an output variable that returns that JSON. Both options will work and provide that JSON for you. 

Thanks for reading,

Jamie
