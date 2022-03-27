---
title: "Random Thoughts on Dev Processes"
date: 2022-03-27T12:35:18-04:00
tags:
- Thoughts
- DevOps
- Policies
- Processes
---

*This post contains affiliate links. If you use these links to buy something I may earn a commission.*

I was sitting around thinking today about why I have some of the practices and beliefs that I have about the development processes. Often these practices and beliefs don't appear shared among others and I am always curious how I have developed these over my career. Some of these practices and beliefs are a result of my experiences over my career, others are related to the books that I have read on the topic of software development over the years. A few books I keep finding myself going back and reading again. I often discover that these ideas are in these books and that I must have passively absorbed these. One of these books is [Continuous Delivery](https://bookshop.org/a/80833/9780321601919), which is a great read on techniques and practices that can prevent or mitigate many of the issues we constantly struggle within the industry. Having automated tests, continuous integration, automated builds, automated deployments, and structured approaches to all activities ease so many burdens. All the stress, all the long nights trying to release, all hours doing manual steps can be reduced by many of the practices found in that book. Why do we struggle to accept or implement these practices? I can think fondly back on the times in my career when I worked on teams that embraced many of these and worked toward achieving as many of these as we can. We had fun, we had minimum stress, and we moved into a better way of working. That team, several years later, is leveraging many of the same systems we put in place to achieve the practices.

One of the practices listed that actually got me thinking this topic was the one about always being able to revert to a previous version or revision. A typical workflow for me is to make several small commits on a feature branch while I am working. I always push this to my fork so I have a backup and I can track my work. I then prepare my pull request by cleaning up that history to make a good story and to keep the branch limited to a few items as I can. Keeping the scope of a pull request limited to a single item makes it easier to revert. It does add more work if several items need changing to complete a task and I have found that if it does, that indicates there may be a bigger design issue that needs sorting out.

Welp, this is enough of these thoughts for now.

Thanks,

Jamie
