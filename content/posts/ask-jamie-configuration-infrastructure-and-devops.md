---
title: "Ask Jamie: Configuration, Infrastructure, and DevOps"
date: 2020-11-03T21:32:57-05:00
tags:
- DevOps
- Opinion
- Ask Jamie
---

I am working through the next set of questions that I received on Twitter related to DevOps. I will have the questions and my response.

{{< tweet 1322228031931506690 >}}

Here are my thoughts on that topic. In my opinion, infrastructure is what your application needs to run vs. configuration is how it needs to run. A database is an infrastructure item; the account to access the database is how it needs to connect. I am a big proponent of infrastructure as code, and I use Terraform to do that. I am also currently a fan of the workspace per environment with one set of Terraform templates. Those templates get configuration applied based on the environment/workspace. This is outlined at a high level [here](https://www.terraform.io/docs/cloud/guides/recommended-practices/part1.html#the-recommended-terraform-workspace-structure). This means that infrastructure configuration is used when the infrastructure is deployed, application configuration is applied when the application is deployed. I also like to store my infrastructure code with my application code in the same repository. Shared/Global resources are only referenced and not created there. 

Now this rolls into one of the other questions:

{{< tweet 1322228568886300682 >}}

All configuration should have sane defaults defined and checked into source control; think of that as the base configuration. Then during the deployment, overrides and secrets should be applied. These allow anyone who looks into source control to know what configuration needs to be supplied; think of it as documentation. I feel you shouldn't have branches per environment because that would mean that you are not using a single artifact across all of your deployments. My opinion is that your builds should produce a single artifact, and that artifact is deployed to each environment in order. That means that unless the artifact is deployed to integrations, it can't be deployed to prod. This will also drive setting configuration at deployment time.

{{< tweet 1322229751189221376 >}}

Again, another opinion of mine. Infrastructure, application code, and configuration should all be applied in a single deployment pipeline in with each item representing either a step or stage. Infrastructure first, then code and configuration. This will require you to be extra careful about infrastructure changes and code changes. You don't want to make changes that cause breaking changes. This may mean it takes several deployments to stagger in all the changes, so nothing really breaks. This isn't always avoidable and leads to good conversations and thought experiments.

{{< tweet 1322230597209776128 >}}

I am a big fan of blue-green deployments and using rings. If you deploy the same artifact across multiple environments leading up to production, then any issues, assuming your environments are the same, will be revealed. I use Azure regularly, and the staging slots available in Azure App Service allow deploying to a staging slot. If the code checks out there, then swap that into production. If the swap goes poorly, then switch it back. That will not work if there are breaking changes introduced as you may not be able to swap back to a prior version of the application. Ultimately, a roll-forward approach solves a lot of these concerns—a note on Terraform here. Terraform will partially apply changes, so you may not have everything deployed into the correct state that is expected in case of a failure. Given that I have usually had at least two environments to deploy to first, I haven't had this cause any issues in a production environment.

{{< tweet 1322241600362262530 >}}

Oh, this is a fun one. Here is one of my primary beliefs, no changes should occur to production that didn't happen as part of a pipeline. Of course, there are exceptions to this rule; however, when those are not followed up with getting the infrastructure as code reconciled, all kinds of fun ensue. That is another excellent feature of Terraform. It is stateful, not stateless. Since Terraform stores state, drift detection is possible. Terraform will undo those changes when applied if the Terraform wasn't updated, and you can see in the log files what was detected and what changes were made to make it match Terraform. I have found the best way to combat drift is to really scope production access to people that absolutely require it; otherwise, all changes go in source control, are code reviewed, then deployed through a pipeline.

## Conclusion

These are my thoughts on the above questions related to configuration, infrastructure, and DevOps. It is always a balance between putting as much in code as possible and pulling out configuration to make your artifacts flexible. I have personally moved between the two extremes on a single project until I was able to find a balance. Again, this is one area to be patient and experiment with until you find what works for that project and team.

Thanks for reading,

Jamie
