---
title: "Azure DevOps, PATs, Git, and Terraform Modules"
date: 2023-07-09T14:30:51-04:00
tags:
- Open Source
- Azure DevOps
- Microsoft And Linux
- Tools
- Git
- Terraform
- HashiCorp
---

I learned a new trick this past week. The context I learned this in is how to access Terraform modules stored in a [git repository](https://developer.hashicorp.com/terraform/language/modules/sources#generic-git-repository), specifically Azure DevOps, without needing to use SSH and an SSH key. The SSH approach works fine, but I struggle with enabling that approach in a CI/CD system. Having to store that SSH key and ensure that it's correctly in each environment is often cumbersome compared to potential other methods. That's where this new trick comes into play. After a quick web search, I found this [blog post](https://wahlnetwork.com/2020/08/11/using-private-git-repositories-as-terraform-modules/). Git has the ability in the config file to allow altering any URL. One of these capabilities is [insteadOf](https://git-scm.com/docs/git-config#Documentation/git-config.txt-urlltbasegtinsteadOf), which can replace the base URL with a different URL. That means you inject your personal access token, PAT, into the URL in your config while leaving the URL referenced in source control without it. There is also the ability to add [headers](https://git-scm.com/docs/git-config#Documentation/git-config.txt-httpextraHeader) to any HTTP request needed. Substituting my base URL to include a PAT solved my issue. Let's check out an example.

Here is the Terraform module in Azure DevOps.

```HCL
module "custom_app_service" {
  source = "git::https://dev.azure.com/<org>/<project>/_git/<repo>?ref=v1.0.0"
}
```

Now you can [generate a PAT](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows) for ADO access.

Now you can add the substitution to your git config using below.

```Bash
git config --global url."https://<insert pat>@dev.azure.com".insteadOf https://dev.azure.com
```

When you run `terraform init`, you will substitute your base URL with the PAT instead of just the base URL. That also means that you don't have to put any PATs in git nor pass around an SSH key. If you need the same access in your CI/CD, you can run the same command to inject your PAT into the git command using the secrets management in the CI/CD system.

## Wrapping Up

I hope this is as useful for you as it was for me. Even after all these years in the industry, I'm always learning new tricks and capabilities of software that I have been using.

Thanks for reading,

Jamie

