---
Title: "How we Gitflow"
date: 2017-11-08T20:59:00
Tags: 
- Tools
- Processes
---
# How we Gitflow

This question came up in a Twitter discussion, it was about using gitflow. What a great opportunity to write a blog post.

At work, we use gitflow for every size project, small to large. We have found it helps to keep a consistent workflow. We also have tied our semantic versioning into how we use gitflow, all of this is part of our CI/CD approach.

## Our gitflow process

We typically start all projects by creating the initial repository, then once the repository has been cloned, we create a develop branch and push that back up.

As part of our process we typically use SourceTree as your GUI tool, SourceTree and GitKraken have built in support for gitflow. We typically *initialize* gitflow in the repository using SourceTree. That initialization just makes sure you have a master and develop branch. It also makes it super easy to create feature branches, release branches, and hotfix branches along with the workflows for merging them back to the appropriate branches.

With the basics out of the way, lets get down to what we do.

We typically start development of a new project, purely working on the develop branch. Once development is far enough along and we determine that a particular feature may create a large impact, we will start using a feature branch. We do not always use feature branches, especially when features are small and do not require many changes to other parts of the application. 

Once we are ready to create a release, we create a release branch. In our CI/CD, release branches get automatically deployed to our test environment. From there testers, start doing their testing. If any bugs are found during testing, we typically fix those bugs on the release branch. Those new commits, get automatically deployed for an additional round of testing.

Once a release has been tested and signed off, we will *Finish* the release by merging it into master and develop along with tagging it with it's version number. That kicks off the CI/CD process that deploys it to production.

Now on to hotfixes, we create a hotfix branch from master if we have what we deem to be a hotfix. We do the hotfix, then *Finish* it by merging into master and develop along with tagging since the version needs to be incremented.

Sometimes we do have multiple hotfixes and releases in queue, but typically we don't. We do not find gitflow to be cumbersome or cause any drag in our system. It does require discipline to consistently do, but that is where tools like SourceTree make it easier. It gives nice buttons that will do the three or four steps that it sometimes take to complete a step.

## Versioning

Now on to how we drive our versioning. We use semantic versioning for all of our applications. We use the tool [GitVersion](https://github.com/GitTools/GitVersion) to help use automate it. Our initial version is driven by the latest tagged version number, if one doesn't exist our first version number is **0.1.0**. We then automatically add tags to our versions based on branch and build number. Here is what it typically looks like for use using the version number.

* Feature Branch -> 0.1.0~feature001
* Develop Branch -> 0.1.0~alpha001
* Release Branch -> 0.1.0~beta0001
* Master Branch -> 0.1.0

