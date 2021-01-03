---
title: "Pull Requests and Code Reviews"
date: 2021-01-03T12:47:07-05:00
tags:
- Thoughts
- Ramblings
- Professional
---

Pull requests, which I will be calling PRs, seem to be too controversial lately, so have code reviews. These two get lumped together because we typically see PRs required code reviews for approval. While these do tend to lumped together, they are, in fact, orthogonal concerns. You don't have to have PRs to do code reviews, and you don't have to have code reviews with your PRs. Let's talk about each separately.

## Code Reviews

Code reviews are just another tool in the toolbox. The goal is to ensure that someone has looked over your changes to ensure that you didn't make any mistakes, missed something, or maybe they have a different perspective to be considered. A review can happen as part of pairing or mobbing, or it may need to happen asynchronously. In addition to pairing, others may need to be aware of the changes, so having a mechanism to say "hey, look this over" is required. 

Do these techniques and tools get abused? The answer to that is a resounding **YES**! We sometimes substitute tools when avoiding collaboration or avoiding a co-worker. We also implement these as a CYA, cover your booty, that adds bureaucracy where it isn't required. With that said, there are times when there are legitimate reasons to need these in a more formal process. One of these reasons is regulatory.

We always need to be aware that it isn't an all or nothing approach. It's all muddy, and we should keep that in mind when we make value statements towards others.

## Pull Requests

We often see PRs come into play when discussing code reviews. It's a simple reason that is the case. PRs are a way to enforce a policy and record that it occurred. It requires someone to sign-off on reviewing the changes before they can merge to record that the change was inspected. Some industries require that the person approving the changes isn't the author. This comes into play in many financial related industries. The better we can automate that and put that information into our source control system, the better.

PRs also serves another purpose, automation. Having policies that enforce quality gates is a necessity to have confidence and to move fast. Policies that require a successful build ensure that all tests pass, and any other myriad of tasks is indispensable in an environment you want to move quickly. How does a team ensure that level of quality without a PR system? Relying on the developers to run them locally before committing and pushing isn't reassuring. People are imperfect and forget. Requiring a PR allows those checks to be in place, and having a reviewer, who may review the code too, verify that everything checks out is a net positive. This helps you understand why these are often inseparable even though they are composable.

Does this mean a workflow with PRs is the best? Of course not. No single workflow is the best. As you move more to a continuous delivery type workflow, I expect things to shift and change, and practices will come and go. PRs work well when you may have longer-lived feature branches but may not work so great with a more trunk-based workflow.

## Conclusion

These are just reasons why these things exist and why we see these coupled together. I am not advocating any of these practices. I am advocating that people are using processes and potentially the reasons as to why they are using them. We seem always to want to completely disregard a technique or technology because we don't see it's purpose. It's all about context. We don't always have the context for the decisions or the culture in those environments that make them. We should give everyone the benefit of the doubt and not speak so absolutely about it all.

We don't have a lot of empirical data in this industry. We make a lot of decisions on anecdotal data, the experiences we have. There is a lot of resistance to what empirical data we have available because it doesn't always align with our experiences and anecdotal data. 

Thanks for reading,

Jamie
