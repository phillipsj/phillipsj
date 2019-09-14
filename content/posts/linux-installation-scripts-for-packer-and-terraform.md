---
Title: "Linux Installation Scripts for Packer and Terraform"
date: 2018-09-15T09:56:14
Tags: 
- Open Source
- Packer
- HashiCorp
- Terraform
- Linux
---
# Linux Installation Scripts for Packer and Terraform

I really enjoy using [Packer](https://www.packer.io/) and [Terraform](https://www.terraform.io) by [HashiCorp](https://www.hashicorp.com/). These tools have become an essential part of my day to day that I wouldn't really know what to do without them. On Linux, most package managers, do not always seem to have the most up-to-date versions of these tools so I created a really simple script for installing each one.

These are located in the following Gists and are simple to use.

## Packer

Packer Gist is located [here](https://gist.github.com/phillipsj/d2f16c47a8eff7e0e5a0e131718387c3).

Use:

```
$ wget https://gist.githubusercontent.com/phillipsj/d2f16c47a8eff7e0e5a0e131718387c3/raw/8a97c8ad15bb3fb07c1cdd5dcb6114146ca4eaf5/packer-installer.sh
$ chmod +x packer-installer.sh
$ sudo ./packer-installer.sh
```

## Terraform

Terraform Gist is located [here](https://gist.github.com/phillipsj/7f701dd51d62d564fe8d1c3c4b704ba1).

Use:

```
$ wget https://gist.githubusercontent.com/phillipsj/7f701dd51d62d564fe8d1c3c4b704ba1/raw/fea275a785c058b81d5b5752e7e9e9133216747a/terraform-installer.sh
$ chmod +x terraform-installer.sh
$ sudo ./terraform-installer.sh
```

Pretty basic operations and I don't need to memorize how to do it. I may revisit this later and make it a bit more dynamic and combine it together.
