---
title: "Thoughts on Git Policies"
date: 2020-12-04T21:02:59-05:00
tags:
- git
- Thoughts
- DevOps
- Policies
---

I have had a few conversations on policies and the role they can play with git repositories. When I talk about policies, I am talking about GitHub's status checks, Azure DevOps branch/pull requests policies or GitLab's push rules. These are all implementations of ways to leverage tools to perform a gate to prevent code that doesn't meet a standard from getting committed into your mainline branch. Here are some examples of using these types of gates.

### Linting/Style Checks

These types of gates will run your favorite linting tool. If the code doesn't pass then, the code wouldn't be eligible for being merged in. While this seems minor, it is a good idea to implement these to help establish the pattern of getting everyone to perform these before submitting their pull requests. This would also be the right candidate for a pre-commit hook, so it just executes when you commit your code. Please keep the pull request policy.

### Code Formatting

If you have a formatting standard or using a language like Go with a formatter built-in, you can make sure that you format your code before merging. You could easily take this policy and just have it run. If it finds code to fix, fix it, then commit that back in. The more of these tasks that we can offload to the computer, the better for everyone since it takes away the cognitive load. This is another one that would be a great candidate for a pre-commit hook and again keep the policy.

### Run Automated Tests

If you have automated tests, having a policy that requires those to execute without failure also increases your code's quality and builds confidence with any changes that are getting merged.

### Code Coverage

If you have automated tests, then evaluating the code coverage on any pull requests would be wise. Now this one could be implemented in two different ways. The first way is to have it just raise a warning that the reviewers will see so a person can determine if it is okay. The second method is to set up a threshold for coverage, and if it drops below, then the pull request can't be merged. There is a lot of interpretation for this one, so implement accordingly. My personal philosophy is that you want your coverage percentage to increase or remain constant as you add code.

### Successful Build

We probably shouldn't be merging in any pull requests that don't have a successful build executed. This is a pretty standard policy, in my opinion, that should be mandatory. A build might perform the steps mentioned above, so those may not be required as long as you have those tasks fail the build if they return any issues. This will also ensure that you don't end up surprised when you have to a hotfix for production, and you can't build your software.

### Required Code Reviewers

This is another one that I consider mandatory. This policy would enforce that you have actual people perform a code reviewer. This policy should not allow you to review your own code. How many reviewers are up to the team, but you have to have at least one to make it a policy. Something I have been a fan of is also scoping reviewers by area of the code. If you know that a team or specific person knows that section better than others, I will configure it to automatically add that person as an optional reviewer. I wouldn't make them required, but it's nice to raise awareness that a susceptible section had extra eyes.

## Conclusion

This was just a quick list of the different types of policies to have at a high level. You can make these as specific as you need as most systems allow you to implement webhooks to accommodate these types of checks. You could roll these into your build scripts too, which may or may not be the right choice. 

Thanks,

Jamie
