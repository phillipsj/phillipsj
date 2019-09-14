---
Title: Why I picked Ember
date: 2014-11-28T19:00:00
Tags:
- Ember
RedirectFrom: blog/html/2014/11/28/why_i_picked_ember
---

This is going to be long post, probably a ramble, about why I settled on Ember as the new age MV\* framework I wanted to learn.

When I first go started doing development, the ecosystem that I was working in was ASP .NET Web Forms. I learned to do all client-side interaction on the server and I always found myself struggling. Then along came the AJAX toolkit for ASP .NET, which enabled me to do cool things like auto update content areas without having to write any JavaScript or understand what was happening. Then as richer client experiences started gaining traction, my current team and I decided to go wtih Silverlight as most of us didn’t have large amounts of experience with JavaScript or Flex. Eventually, we ran into the issue that Flex and Silverlight are on the way out, so we decided to go JavaScript and started embracing jQuery and Dojo. jQuery because of its popularity and ease of use, Dojo becausee the GIS technology that we were using was built on top of Dojo. I left that job not to long after the transtion and found myself working on a project using ExtJS. As somewhat frustrating as it was, I really liked the framework and its implementation of a MVC style architecture. I was able to quickly convert a Flex application into a pure JavaScript application using ExtJS in a matter of weeks. In this same job, I also inherited support of a Dojo and Knockout application so I was exposed to the Knockout paradigm. 

As an aside, during this time I was also migrating from ASP .NET Web Forms to ASP .NET MVC, experimenting with Django, Ruby on Rails, and various PHP MV* server side frameworks. This ushered me into a new future, that I could understand and grasp more easily than ASP .NET Web Forms.

What I discovered along the way is that I really like opionated frameworks and convention over configuration. Why waste my time doing repetitive tasks and making descisions that I was indifferent about, when I can be solving peoples problems. Lastly, since the single page application was being more prevelant and the building of web APIs to provide an agnostic way for all your clients to access the same server-side logic, I knew that I need to get cozy with a good JavaScript framework that was lighter weight than Dojo or ExtJS and had a style (opinion) that set comfortable with me.

I knew I could rule out Knockout, I really liked it, but it wasn’t a complete package. Backbone doesn’t provide enough structure. Angular was sweeping the dev communities that I was plugged in to, so I decided I would check it out. As I learned more about Angular, I found that there was not a lot of guidance to application structure, there was not a built-in router, and the use of data attributes just bothered me. Why do frameworks insist on messing with your HTML. I want clean HTML and I felt Angular didn’t give me that. Another struggle with Angular is the weird naming of things (Ember does it too), why name stuff after patterns, when the pattern doesn’t really fit. I questioned the descision to not go with Angular, but the recent news of 2.0 reassures me that I am glad that I didn’t. I breifly considered Durandal, but it was announced that Rob was going to Angular. I would consider it now that Rob is back.

So after all this searching I decided to finally pick up Ember. Rob Conery’s posts about Ember scared me off initially, and finally Rob put out a post that ran through the terminology used by Ember into terms that I could understand which helped. I then started working through a couple tutorials to see how I liked their philosophy. I will say the first few weeks were really trying my patience, but once it started to click, I realized that my style really fits well with Ember.  So that is kind of why I am embracing Ember. Clearly, with my recent flurry of posts, it would be obvious that Ember and I mesh well.

Thank for reading
