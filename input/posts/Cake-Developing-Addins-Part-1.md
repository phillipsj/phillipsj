---
Title: 'Cake: Developing Addins Part 1'
Published: 1/17/2017
Tags:
- Open Source
- Cake
- Tutorials
- Netlify
---

# Cake: Developing Addins Part 1

* [Part 2](http://www.phillipsj.net/posts/cake-developing-addins-part-2)
* [Part 3](http://www.phillipsj.net/posts/cake-developing-addins-part-3)
* [Part 4](http://www.phillipsj.net/posts/cake-developing-addins-part-4)

I am kicking off a series of posts that will be a **Play By Play** of my choices and decisions around how and when to create a Cake Addin. This will serve as a reference for me and hopefully someone will find it useful.

## Should I create an Addin

I have recently switched my hosting to [Netlify](https://www.netlify.com) and I have been extremely happy. I am currently using the Cake build script creating by [Dave Glick](https://daveaglick.com/).  Here is the deployment code:

```
Task("Deploy")
    .Does(() =>
    {
        string token = EnvironmentVariable("NETLIFY_PHILLIPSJ");
        if(string.IsNullOrEmpty(token))
        {
            throw new Exception("Could not get NETLIFY_PHILLIPSJ environment variable");
        }
   
        // Upload via curl and zip instead
        Zip("./output", "output.zip", "./output/**/*");

        StartProcess("curl", "--header \"Content-Type: application/zip\" --header \"Authorization: Bearer " + token + "\" --data-binary \"@output.zip\" --url https://api.netlify.com/api/v1/sites/phillipsj.netlify.com/deploys");
    });
```

This task uses curl to push your packaged content to the Netlify API and publishes your application. While this works fantastically, Netlify produces a [CLI](https://github.com/netlify/netlify-cli) npm package that wraps their API.  In their CLI there is support for working with their partial deployment functionality. It could be written like the above code. However, to be user friendly I think their should be Cake support to assist adoption. It would also be nice to have the Addin to help promote Netlify. 

So the decision at this point is that **I think I should create an Addin**.

## Implementation and Design decision

Now that I have decided that I want to create an Addin for Netlify, I have a few different options.

1.  Use curl and StartProcess like above.
2.  Use the Cake.Npm Addin and the Netfliy CLI in my Addin.
3.  Implement a pure .NET version of the Netlify CLI.

With my decision above, I think I will exclude #1 as an option. That leaves me with #2 and #3 as options for implementing the functionality. 

Here is where I am having difficulty. I do not want to take a depedency on Node, in reality, Node is almost always required as part of a front-end toolchain, ships with Visual Studio, and Microsoft includes it on their App Services. 

As far as streat credit goes, it would be cool to create a *NetlifySharp* library to use. That would allow the functionality to be available for other toolchains, not just Cake.  

My gut tells me to implement the functionality using option #2, that way I can design my Addin API and I would have a working Addin. However, I know how this works, once I get it working, I probably will not go back and create the pure .NET implementation.

This is a tough choice and once I will consider over the next few days. I do know myself as a developer and I will probably just go ahead and start with option #2 because it will create progress and I can see how it is starting to develop.

## End of Part 1

This is just the flow of my thoughts and decisions.  I hope others find this useful.

Thanks,

Jamie 
