---
title: "Cake Addins Update"
date: 2021-05-23T21:13:57-04:00
tags:
- Open Source
- Cake
---

I just wanted to post that all of my Cake Addins migrated out of the Cake Contrib organization on GitHub and are now back in my account. I will be making changes and maintenance a little every week, so please be patient as I get this worked out. I will detail out my plans below.

## Immediate Changes

This migration occurred due to a change in the licensing and attribution of the projects. These changes occurred without any discussion with me, and I have worked through them with the team. With that said, the changes have not all been 100% remediated, and that will be my first order of business.

The next step will be to change the master branch to be main. I think that is a necessary change to make. With that change, I will be migrating away from git-flow in those projects to just having users create feature branches from main.

Lastly, I will need to get CI/Cd setup for the project, and I will be migrating to GitHub Actions. As part of that change, I will discontinue using Cake.Recipe as it brings in more complexity than I feel that I need.

A few projects have pending PRs, and those will get merged before proceeding, not to make it difficult for the contributor.

## Future Changes

I am planning to be a little more active in maintaining these addins since there are still plenty of people using them.

## Conclusion

I drifted away from these projects over the last few years. The result of that drift was precisely what occurred. I have no ill-will about what happened and hold myself accountable for ending up the way it did.

Thanks for reading,

Jamie

