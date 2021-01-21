---
title: "Migrating from Local State to Remote State in Terraform"
date: 2021-01-21T09:27:28-05:00
tags:
- Open Source
- Terraform
- HashiCorp
- PostgreSQL
---

Today is my birthday, and I took the day off. It's raining outside at the moment, so what's better to do than getting some personal tech stuff handled and blog about it at the same time. Yesterday, I wrote this [post](https://www.phillipsj.net/posts/postgresql-backend-for-terraform/) about the PostgreSQL backend for Terraform. Today, I will show how to take a local Terraform state and migrate that to a remote backend. If you are new to Terraform backends, you should hop over and check out my [discussion](https://www.phillipsj.net/posts/discussion-of-terraform-backends/) of them. My preference and recommendation are to use a remote backend that supports locking, especially if working on a team. 

## The Plan

The plan is to migrate my [LKE Terraform](https://www.phillipsj.net/posts/terraforming-a-linode-kubernetes-cluster/) to a remote backend, and you can use the Terraform in that post as a base. You will need a PostgreSQL database, which you can setup using Docker. I will be using a PostgreSQL container running on my NAS dedicated for Terraform. Now there are two options for setting the connection string that is required. In the previous post, I did it straight in the Terraform template. That isn't the most secure way to do that and not my preference. You can also set that when initializing the backend.

### Configuring the PostgreSQL Connection String

The first item to do is set our environment variable for the connection string. I will show you how to do this on Linux, and I would encourage you to add this to your profile, so it's available for you all the time.

```Bash
$ export PG_CONN_STR=postgres://<user>:<pass>@localhost:<port>/terraform_backend?sslmode=disable
```

The database name is required to be *terraform_backend*, so if you haven't created that, then do so. I am running this on my home network, so I have SSL mode set to disable it. I don't recommend this configuration for a production system. There isn't anything sensitive that will be configured with Terraform, so if my state were compromised, it would just be an inconvenience, not detrimental.

### Adding the backend to Terraform

Now that we have that in place, we need to add the backend to the *terraform* block in our main.tf.

```HCL
terraform {
  required_version = ">= 0.14.3"
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.13.4"
    }
  }

  backend "pg" {}
}
```

We have one more thing to do. The Azure and S3 based backends allow you to set keys to separate your state into different files. Then workspaces are appended to that key to generate a separate state for each workspace. Since tracking of the workspaces is in the table inside PostgreSQL, we need to separate the different states we want to track. We can do that in one of two ways: separate databases or separate schemas. The schema approach is lighter weight and less challenging to manage long term. Let's add a schema called *lke_state* to the backend config.

```HCL
terraform {
  # Omitted

  backend "pg" {
    schema_name = "lke_state"
  }
}
```

We can now migrate our state.

### Migrating the state

This part is such an anti-climatic end to this whole post. All we need to do is initialize Terraform passing the backend configuration. Terraform should ask if you want to migrate from local to the new remote backend. Answer the prompt *yes*, and your state will migrate.

```Bash
$ terraform init -backend-config="conn_str=${PG_CONN_STR}"

Initializing the backend...
Do you want to copy the existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "pg" backend. No existing state was found in the newly
  configured "pg" backend. Do you want to copy this state to the new "pg"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes


Successfully configured the backend "pg"! Terraform will automatically
use this backend unless the backend configuration changes.
```

One last thing that I will do once I migrate is to run a plan to make sure everything is clean.

```Bash
$ terraform plan

No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
```

Awesome! Everything appears to have migrated successfully.

## Conclusion

Terraform state is one of the more powerful features since it can assist with drift detection. It can be one of the most challenging parts too. Starting with local state is the recommended path and what I typically do. When I am ready to start working with others or involving a CI/CD pipeline, then I will migrate to a remote backend that implements locking. Hopefully, this shows you that you don't need to be intimidated by this migration.

Thanks for reading,

Jamie
