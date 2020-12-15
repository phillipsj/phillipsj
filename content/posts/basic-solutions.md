---
title: "Basic Solutions"
date: 2020-12-14T21:16:25-05:00
tags:
- Thoughts
---

By default, when I first started doing development, I picked the most basic solution that I could understand. That would be the solution that I would implement. There would be times that I would just keep at a problem until I put a solution in place. Those solutions are incredibly memorable, yet some of the most brittle solutions that I have ever created. As I grew in this career, I started reaching for more complex solutions to problems. These solutions would be using all the "proper" techniques and new technology of that time. I would look at them as these elegant and beautiful creations. With that shift in mentality, I grew out of touch with why I got started in the first place, helping people. Building solutions for myself is fun, just not as rewarding as actually solving problems for others. A majority of the time, a basic solution gets the user 80% to 90% of the way there. It is less difficult to maintain and support. Other team members can learn it quickly too. 

I moved into DevOps and cloud engineering, which is a focus shift. I am longer in the middle of the software development cycle, and I have started to reflect on the current state. Back in the day, in the late 2000s, you didn't need multiple runtimes/SDKs installed to build a web application. Package managers were not as prevalent, and neither was the cloud. Heck, smartphones were just becoming a thing. The websites we made were reasonably nice web applications using tools like jQuery, Dojo, and ExtJS. The performance, IMO, was not all that different from some of the sites today. We have slowly shifted from the models we used to build single-page applications to migrate back to a server-side rendering approach. The same can be said for how a lot of frameworks are designed. Was MVC expressed by early Rails, Django, and ASP .NET MVC 2.x the pinnacle of just enough? Django, as far as I know, hasn't tried to integrate with the front end tools, while Rails kind of when all in on it. ASP .NET started down an integrated pipeline to quickly move away from it. I used to think that a fully integrated experience would be more effortless, yet it increased the complexity beyond learning multiple tools to build a site. Learning numerous tools for building a website is still more complicated than I feel it should be.

We then decided to make many systems distributed using microservices and event stores. We traded development complexity for infrastructure complexity, I would argue. We kept all the complexity and didn't really trade it at all. We have now introduced containerization, Kubernetes, and the cloud into the picture. Let's not forgot all the aspects that are considered to be DevOps. It has grown to a level of overwhelming complexity. 

How do we start to reduce that complexity? Can we reduce the cognitive load? What is enough complexity? When do we reach the limit of good infrastructure? These are all questions that need to be pondered while adding tools and techniques into an existing app. Maybe the existing monolith is fine. Perhaps we just need to extract the bits that are causing the pain and leave the rest. Can we trade some of these tools for less complicated tooling? These are just some random things floating around in my mind.

Thanks for reading,

Jamie
