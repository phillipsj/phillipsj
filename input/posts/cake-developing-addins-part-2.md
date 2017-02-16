---
Title: "Cake: Developing Addins Part 2"
Published: 01/22/2017 15:47:05
Tags:
- Open Source
- Cake
- Tutorials
- Netlify
---
# Cake: Developing Addins Part 2

* [Part 1](http://www.phillipsj.net/posts/cake-developing-addins-part-1)
* [Part 3](http://www.phillipsj.net/posts/cake-developing-addins-part-3)
* [Part 4](http://www.phillipsj.net/posts/cake-developing-addins-part-4)
* [Part 5](http://www.phillipsj.net/posts/cake-developing-addins-part-5)

In part 1, I was struggling with how to implement the addin. I put forth a few options and I have taken a few days to think it over. During that time I reached out to a few people and had discussions about the two remaining options that I had. I have found it useful over my career to always discuss designs, implementations, and general issues with others, the collaboration always results in a better solution. 

Option 2 is the option that has risen to the top and the one that offers the quickest implementation and one that is robust enough to get the job done. For this option I will be using the [Cake.Npm](https://github.com/cake-contrib/Cake.Npm) to do my implementation. Hopefully I can get some good unit tests and start working through the actual design.

The design is going to be the focus of this post. Part of me would like to create a *package.json* file with NPM scripts in it to execute the Netfliy-CLI, the other side of me says just use the *ProcessStart* in Cake to call the Netlify commands. While typing out this explanation, I just realized that I can implement this all as a tool. That would handle the command line calls for me easily. And this is why you discuss it with others or just out loud.  I would have realized this while eventually once I started slinging code, but now I don't have to go down that road and realize that I needed to refactor. This will make unit testing easier as I only need to validate that the command line commands are accurate. 

None of this code is in the Github repository currently, but it will be shortly.

Thanks for reading,

Jamie

