---
title: "Pode a Powershell Web Framework"
date: 2020-11-03T22:52:04-05:00
draft: true
tags:
- Open Source
- PowerShell
- Polaris
- REST API
---

[Pode](https://badgerati.github.io/Pode/) is a PowerShell based web framework that I learned about recently. After a little investigation, it really seems to be a more tradtional style web framework that is conventiently written in PowerShell. There is a view engine for rendering HTML templates, it can serve up assets like CSS and JavaScript, and the application structure is familiar. Before I start walking through creating an application, my initial thoughts are that this is more geared toward those familiar with existing web development frameworks. This means there is a little more that might be needed to learn and that there is more resources to learn it.

## Why PowerShell frameworks

This is also the time to clarify why I keep exploring these frameworks. My background is as a developer that has migrated into DevOps, Cloud Engineering, and Site Reliabitliy Engineer. I am very comfortable with any programming langauge and can use most to build an API or website. The one thing that I have learned is that isn't true for a lot of people that are comming into these areas from a non-developer background. Tools like Bash, PowerShell, and Python are heavily used within these fields due to the nature of the work that relies on PowerShell modules, shell scripting, and automation libraries produced by vendors in Python. These are all approachable langauges for most that work in tech and frameworks like Pode, Polaris, UniversalDashboard, etc. allow people who have built skills in these languages to build small web APIs and websites to solve very specific problems. I don't feel these are intended to really compete with the typical list of web frameworks that are often used and not really aimed at the developer market.

I wrote the paragarph above yesterday when I started this post. Today, I saw an article on [ZDNet](https://www.zdnet.com/article/programming-language-pythons-popularity-ahead-of-java-for-first-time-but-still-trailing-c/) that was discussing how Python has passed Java in the [TIOBE Index](https://www.tiobe.com/tiobe-index/) and is now #2 behind C. That is a big testament to the appeal of Python. An interesting part of the article, I have pulled out here.


> "I believe that Python's popularity has to do with general demand," writes Jansen. "In the past, most programming activities were performed by software engineers. But programming skills are needed everywhere nowadays and there is a lack of good software developers. 

The qoute highlights that programming isn't something just for developers anymore and that is how I feel about a lot of these tools that are poppping up. These tools allow others to get tasks completed and deliver value.

## Building a web app to create Active Directory users

I feel that examples that leverage real world use cases always seem to relate the best to users. With that, in the past I have been asked to create a web applicaiton that an HR department can use to create new users in Active Directory. A web application that puts guard-rails on the process helps the HR department and take a load of the IT help desk. We will create a simple form that has some default values configured. When that form is submitted it will call the AD modules to create the user account configured correctly. As pointed out above, doing this with PowerShell makes it approachable to IT folks who are comfrotable using PowerShell to perform other tasks like AD management.

### Installing Pode and project setup

Let's start by installing Pode.

```Bash
$ Install-Module -Name Pode
```

Now we can create a directory called *pode* and our *server.ps1* file.

```Bash
$ mkdir pode && cd pode
$ touch server.ps1
```

Open *server.ps1* in your favorite text editor. We are going to import the Pode module and create a Pode server and a basic route to test that everything works.

```PowerShell
Import-Module Pode

Start-PodeServer {
    Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http

    Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
        Write-PodeJsonResponse -Value @{ 'value' = 'Hello, world!' }
    }
}
```

We can now start up our basic Pode server and test our basic route.

```Bash
$ ./server.ps1
Listening on the following 1 endpoint(s) [1 thread(s)]:
        - http://localhost:8080/
```

We are going to use [HTTPie](https://httpie.io/) to do our testing by executing the below command.

```Bash
$ http get http://localhost:8080
HTTP/1.1 200 OK
Content-Length: 25
Content-Type: application/json; charset=utf-8
Date: Fri, 06 Nov 2020 01:57:26 GMT
Server: Pode -

{
    "value": "Hello, world!"
}
```

It looks like we have everything wired up correctly.

### Rendering an HTML page

Pode appears to be convention-based which does aid in setup. We will need to create two directories along-side our *server.ps1*. Those two directories are *views* and *public*.

```Bash
$ mkdir {views,public}
$ ls
public/ server.ps1 views/
```

In the *server.ps1* file, we are going to set our view engine and replace our root path so we can return a web page.

```PowerShell
Import-Module Pode 

Start-PodeServer {
    Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http
    
    # set the engine to use and render Pode files
    Set-PodeViewEngine -Type Pode

    Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
        Write-PodeViewResponse -Path 'index'
    }
}
```

Remember that Pode is based on conventions, so Pode will look into the *views* directory for a HTML template named *index.pode*. That name needs to match the path that is being passed into the *Write-PodeViewResponse*. The .pode file extension allows you to use PowerShell inside of your HTML template.

```Bash
$ touch views/index.pode
```

Now open the *index.pode* file and add some basic markup that will start building out our web page.

```HTML
<!DOCTYPE html>
<html>
    <head>
        <title>User Creation</title>
    </head>
    <body>
        <h1>Create new Active Directory Users</h1>
        <p>This is just the start of the application.</p>
    </body>
</html>
```

Let's run our Pode app and see if we can view the index page. Remember that our web page is running on http://localhost:8080.

**basic-page.png**

Great! We are now rendering a web page.

### Adding some pizazz

Our page is rather plain and we can spruce that up with a little stylesheet. I am going to use a CSS framework called [Bulma](https://bulma.io/) to make our page look a little better. I could wait to do this until the end, if you don't really care if it looks better you can skip this section.

After downloading the zip file from the website, unzip the files, and copy the *bulma.min.css* file in the CSS directory to the the *public* directory of your Pode application. Once that is complete, add the stylesheet to the web page. We could link to an CDN for this stylesheet, I just didn't feel given the context of this app that it didn't make much sense. We will be adding a few other items to the HTML to, so be sure to grab all the changes.

```HTML
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>User Creation</title>
        <link rel="stylesheet" type="text/css" href="/bulma.min.css">
    </head>
    <body>
        <section class="hero is-primary">
          <div class="hero-body">
            <div class="container">
              <h1 class="title">Create new Active Directory Users</h1>
              <h2 class="subtitle">This is just the start of the application.</h2>
            </div>
          </div>
        </section>
    </body>
</html>
```

Now if we visit our page, we should see a page that looks like below.

**styled-page.png**

We now have some basic styling, now we can get back the focus which is our form for collecting user info to create a user account.

### Creating the new user form

