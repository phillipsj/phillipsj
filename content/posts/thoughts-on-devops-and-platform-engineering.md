---
title: "Thoughts on Devops and Platform Engineering"
date: 2024-09-07T20:51:15-04:00
tags:
- Random Thoughts
- Thoughts
- DevOps
- Policies
- Agile
- Craftsmanship
- Shipping
---

I read a [LinkedIn Post](https://www.linkedin.com/posts/bryan-finster_platform-engineering-is-dead-hear-me-activity-7235320270813609984-Nizw?utm_source=share&utm_medium=member_desktop) that got me thinking about solidifying my thoughts on the topic. I was excited about platform engineering for a short period, then I just wasn’t. Let me break this down as this also applies to a lot of DevOps processes. This is going to be a long post, so I will just provide a TLDR, but I think it deserves a full read.

### TLDR

I feel platform engineering is an unnecessary abstraction that is often brittle and stifles collaboration instead of fostering it. We have no shortage of tools, those tools just may lack easy onboarding or need bolstering to improve the experience of all users. We need composition, not inheritance. We need to have the Unix Philosophy.

## Here we go!

DevOps has always been about getting people to collaborate with each other. It was to build camaraderie and empathy between groups of people involved with the creation, delivery, and operations in IT. In the past, many teams would just hand things off and walk away. That was in itself an abstraction over what it took to make both sides of a successful project work. That abstraction often failed. Development teams would build software not considering the limitations of the operating environment. Maybe there wasn’t enough server space, maybe there wasn’t a program, maybe security and compliance requirements weren’t considered. With DevOps, those concerns got brought to the front for discussion. In an idea scenario, development teams would learn more about the operations and the operations team would learn more about the development. Then both teams could consider the impacts from many different angles. I’ve lived this before, and it’s harmonious when it happens.  

Common forms of Platform engineering, in my opinion, are an attempt to build abstractions to hide these concerns. I think that is a straight-up mistake. Abstractions are often brittle and cause a lot more confusion. It also causes friction from lock in, constant churn, etc. It’s hard to run a platform that can grow and adapt as needed. This leads to many cases of the platform constantly breaking things as changes happen or not having the ability to add new capabilities quicker. This can and does lead to shadow IT.

Also, don’t we already have a platform? It’s your cloud. Those APIs are an abstraction over the underlying operations. Yes, it’s often challenging to get everyone up to speed on it, and some just don’t want to learn those skills.  That’s why we have teams and collaboration. Each cloud has dozens of services that fit most use cases, and they provide some level of abstraction over the underlying concerns. Add in containers, and we have plenty of platforms to work with.

With all this said, I think the best approach is to not put facades in place. But to leverage the tools in a way that allows those curious to dive deeper and those that don’t want to don’t have to. We have dozens of CI/CD tools, infrastructure as code tools, and several tools for building containers. What is lacked by a lot of these tools is that tailored experience, which can be achieved through composition, not by inheritance.

## Examples

Let me give you an example. Instead of abstracting away the build pipeline, expose it in a clean fashion that is straightforward to follow. As people get comfortable, they will naturally want to start making additions on their own.  Templates can help or just a good wiki with examples may be all that is required.

Having your infrastructure as code in the repo with the application code allows dev teams to dig in and start tinkering with it if they want. This may eventually lead to the team taking more ownership, it may not. However, it hasn’t hindered anyone from learning and there isn’t a leaky or brittle abstraction in the way.

## Additional Thoughts

> Build golden paths, not cages. What I mean by that is not that abstractions are wrong per se, 
> but you have to want to use them. If they don’t work, a team should be able to circumvent 
> them at any point in time.
> > Kaspar von Grünberg

I like this quote as it does a good job describing the issue that I often see with platforms. We end up building cages. Just like the LinkedIn article states, I think this often occurs because we aren't thinking about software enablement, but about building a platform. I think it’s odd that people are flocking to Kubernetes not for the platform but for the dream of being agnostic since they’re afraid of vendor lock-in, locking themselves into a vendor.

Here are some additional interesting articles that I read that influenced my post.

* [Top 10 Fallacies in Platform Engineering](https://humanitec.com/blog/top-10-fallacies-in-platform-engineering)
* [How to pave golden paths that actually go somewhere](https://platformengineering.org/blog/how-to-pave-golden-paths-that-actually-go-somewhere)
* [Why putting a pane of glass on a pile of sh*t doesn’t solve your problem](https://platformengineering.org/blog/why-putting-a-pane-of-glass-on-a-pile-of-shit-doesnt-solve-your-problem)

## Wrapping up

I have a lot more to say, but I feel it's going to get repetitive and lose the point. Do I think platform engineering isn't a good endeavor? No, I think it's a great goal. Having standard practices, patterns, tooling across your organization is going to be a big win in software delivery. My concerns are mainly around the current approaches to it. You have to talk to your customers, you have to have experience building software, and you have to compose your solution. This all feels very familiar and has me returning to this previous [post](https://www.phillipsj.net/posts/inspiration-software-faster/) that I wrote almost 10 years ago. It's all about process, not the tooling. If you focus on building a good process, the tooling will come easily.

Thanks for reading,

Jamie