---
Title: 'JavaScript: The Orchard Way'
Published: 2015-12-18 19:00:00
Tags:
- Orchard
- Open Source
- ReactJS
RedirectFrom: blog/html/2015/12/18/javascript_the_orchard_way.html
---

So I have been attending the [Orchard community](http://www.orchardproject.net/discussions) meetings since we started to use Orchard for our current project. Orchard is a great system that is very
moduler, with hooks and interfaces that can be overridden in a very easy way, once you learn it. So this past week, the discussion turned to what JavaScript framework should be used for Orchard core javascript needs. We all know that the conversation quickly went to [Angular](https://angularjs.org/).  There were several other frameworks discussed, but the top two were clearly Angular and [ReactJS](http://facebook.github.io/react/). Then an interesting question surfaced from [Bertrand](http://weblogs.asp.net/bleroy), it was “Which one is the Orchard way?”. So I know that the Orchard
team has a very defined culture and I have heard that statement several times in the past, but it got me wondering if a blog post or any formal statement of “The Orchard Way” has been created. With that I stumbled on to a [post](https://weblogs.asp.net/bleroy/the-orchard-way) by Bertrand that has the answer.

So with that answered, the next question is which framework is the closest to that philosophy. After binging for around the internet to gather a few more opinions to see if I felt differently I do not. ReactJS provies a very easy and clear mental model. This is a very basic statement if what is happening to illustrate the point. You create components that are encapsulated, reusable, and have a single responsibility. Data is pushed down from each parent and the child component that needs some data recieves it from the parent. Does this sound familiar, it sounds similar to Bertrand’s example, where the car builder has assembelers that only fulfill one specific component and they don’t worry about the other components. Now I am going to stretch the example
a litte, because I am sure if there is something need by the assemblers then a call is made and more information is pushed down from a higher level, sounds a lot like the one-way data flow provided forced by React. Which leads me to the qoute found in [this](https://github.com/kmcclosk/reactjs-rxjs-example) readme, “Its (React) sort of like the Actor Model”, which I agree it is kind of like that. So if you think about how each component is an actor that can contain actors and those components send messages with actions back up, etc. 

So to end, I do this that React is more like Elon’s factory than Greg’s, so that is why I feel Orchard should choose React.