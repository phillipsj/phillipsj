---
title: "Learning and Growing in DevOps"
date: 2023-11-24T14:16:06-05:00
tags:
- DevOps
- Opinion
- Ask Jamie
---

I have been seeing a lot of posts recently on [LinkedIn](https://www.linkedin.com) lately titled something like  "Skills needed for being a DevOps Engineer" or "How to become a DevOps expert". Instead of responding to these posts, I decided I would just write a blog post to share my thoughts so I can reference it in the future. Let me start by saying that tools are not the most important thing to learn in DevOps, the most important thing to learn are concepts and the spirit. Patrick Debois posted [this](https://www.linkedin.com/posts/patrickdebois_my-current-definition-of-devops-everything-activity-6755909565658746880-odKR/) a few years back with his current definition.

> My current definition of Dev*Ops: everything you do to overcome the friction created
> by silos ... All the rest is plain engineering.

Microsoft has this definition posted [here](https://azure.microsoft.com/en-us/resources/cloud-computing-dictionary/what-is-devops)

> A compound of development (Dev) and operations (Ops), DevOps is the union of people,
> process, and technology to continually provide value to customers.

I could find several more of these definitions that are roughly all the same. The one thing you may notice is that no tools are specified or called out. The tools aren't important, communication and having empathy for the others involved in the process are the most important. Take a few minutes to reflect on those definitions.

Okay, now that we know that it isn't about the tools or the technology, let's get to what you can do to become better at DevOps. If you are a developer, become more familiar with the operations side of your environment/application. Does your team participate in on-call rotations for it? Do you all deploy it? Are you patching/upgrading your environment? Do you understand the networking components? If you answer no to any of those, then I would highly urge you to take some time and volunteer to learn those things from the teams that handle them. Learn their side, understand it, find the thing that could make their lives better, and incorporate that into your process or application.

Now for the operations folks. Do know how the developers do their job? Do you know what the application does? Do you know the entire tech stack that it's built with? Do you participate in the architecture meetings? If you answer no to that, then I would highly urge you to take some time and volunteer to learn those things from the application developers.

As you start working together and understanding the other side empathy starts developing. As that empathy develops, hopefully, you will start working on improvements to reduce friction and improve everyone's pain points. At that point, you will be doing DevOps.

## Building Skills

After saying all of that, we can get to the practical side of it all. You will have to use technology to achieve these goals and some of this will be technology that you may have little to no experience using. That's good because that is where real growth happens. Solving real-world problems with technology is the sweet spot of truly growing. This may be introducing a *CI/CD* solution like [TeamCity](https://www.jetbrains.com/teamcity/) or [GitHub Actions](https://github.com/features/actions) to automate things like security scans into your development process to make it easier for the security team. It could be introducing an *Infrastructure as Code* tool such as [Terraform](https://www.terraform.io/), [OpenTofu](https://opentofu.org/), or [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep) to turn your infrastructure into code which would help the operations team. Maybe you have a lot of troubleshooting steps and runbooks you provide to the operations team or support team, imagine taking those steps or runbooks and building tools like a dashboard that can execute the steps with a click of a button to make their lives better. All of these things build your skillset in **"DevOps"** while also reducing friction. Notice that none of these are focused on the tool, they are focused on the problem that the tool helps you solve. That's how you become a DevOps specialist, focus on the problems and the tools that can help you solve them.

## Conclusion

There isn't a list of things to learn to make you better at DevOps. However, there is an infinite list of problems that need to be solved that are all unique, yet similar, and creating solutions for them will most definitely make you better at DevOps. So I would encourage everyone wanting to get into DevOps to focus on the pain and trying to automate that away. You will naturally build your toolset and when you do speak about it you will be speaking from a place of experience. I will also guess that when you do speak about it, you won't be focusing on the technology used.

Thanks for reading,

Jamie
