---
Title: Now using Wyam
Published: 1/2/2017
Tags:
- Open Source
- Cake
- Wyam
---

**TL;DR; Wyam is awesome and worth checking out.**

When I first started blogging, I started using *Blogger*. It was easy to get started and it was very popular and it wasn't wordpress. After a few failed attempts and not being overly happy I started looking around at altertantives. In 2014 I started using a Python based static generator called [Tinkerer](http://tinkerer.me) which is based on [Sphinx](http://www.sphinx-doc.org). After a few years of using Tinkerer, which I really enjoyed, the development started to slow down and it wasn't very active. At that point, I switched to using [Hexo](https://hexo.io/) and it has been enjoyable also. In that time frame I started participating in the [Cake](http://cakebuild.net/) project and noticed they were using this this project called [Wyam](https://wyam.io) to build their documents page. I didn't give it much thought, but found it interesting. Finally, I decided to investigate Wyam as it is .NET based and it would be easy for me to modify if needed. Regardless to say, but after ~5hrs, I have been able to convert and deploy my whole site using it. I think it is a better implementation of the [Clean Blog]() theme and I can use Markdown or Razor to create pages or posts. 

The extremely nice part is that Wyam doesn't rely on any custom tags or syntaxes, it just uses straight up Markdown to achieve all the things you would like to do. If you find that you want a custom tag, then that is easy as adding a pipeline to your build to support it. 
