---
Title: "Development in a Container"
Published: 07/13/2019 12:00:03
Tags: 
- Containers
- Wyam
- Blogging
- Microsoft and Linux
- Linux
---
# Development in a Container

I have been a skeptic of using containers for local development until recently. I have been frustrated that some of my favorite Linux distributions make it challenging to do .NET Core development. Either packages are not available or other weird behaviors with global .NET Core tools have been present. I can provide two examples of odd behavior. The first example involves using .NET Core from as a snap. However, global tools seem to struggle to find the .NET Core runtime. The second example appears to be weird behavior involving installing packages that are global tools on Fedora. It will continuously error, then start working, I haven't had the time to track that down, primarily when I use most of my free time trying to create content. 

Then it hit me, I have had great success running .NET Core on Ubuntu 18.04 so why don't I create a container for doing local development. I know plenty of people do it, and it seems like a lot of overhead that shouldn't be necessary. Now I think I get it, and I will accept that overhead if I can guarantee that my dev environment always works. Using a container will also free me up to run any distro that can support container tooling, and I don't have to wait on support from the Microsoft before I upgrade my distro. It surprised me that I finally understood, I didn't have that pain yet to lead me to this solution. This is a valuable lesson that I keep learning, and I talk about all the time. Sometimes people don't understand a solution to a problem until they have it or feel the pain of that problem.

Okay, with that off my conscious, let's get down to creating a .NET Core container setup and scripts for doing [Wyam](https://wyam.io/) blogging. I will be using [podman](https://podman.io/), replace the *podman* command with *docker* if you are using it.

First up, let's get our Dockerfile in place. We are going to using Ubuntu 18.04 with the latest .NET Core version. We will create a working directory that we will use to mount our local files into the container. Then we will install the Wyam CLI into the container and set our entry point to be the wyam command that I use to run it locally. 

```Dockerfile
FROM mcr.microsoft.com/dotnet/core/sdk:2.2-bionic

ENV PATH="$HOME/.dotnet/tools:${PATH}"
WORKDIR /code/app

RUN dotnet tool install -g Wyam.Tool

ENTRYPOINT wyam --recipe Blog --theme CleanBlog --preview --watch
```

Now we can build our container for running our blog. The *-t* command tags it with a name that we will be using below.

```Bash
$ podman build . -t blog
```

Now we have a container, and we can run it and watch our files to get the feedback we want while creating our content locally. When we run the container, we need to make sure that we map our volume from our local filesystem to the working directory in our container.

```Bash
$ podman run --rm -it -p 5080:5080 -v "$(pwd):/code/app:z" blog
```

There are a lot of commands here, so I am going to cover what is happening. We are using *--rm* to tell podman that we want to remove the container when we stop the command. The *-it* command pipes the console back out to the terminal that executed the command was instead of detaching it. The *-p* is setting the port and we are going just to use the same port that Wyam uses as I am used to that. Finally, we use the *-v* command to mount our local directory to our working directory in the container. Then we pass the name of the container that we want to run.  You will notice that I am passing an **:z** at the end of my volume command. That is a unique option that needs to be passed to let SELinux know that you want to allow permissions to the directory or you will be in read-only mode. You can read more about it [here](https://stackoverflow.com/questions/24288616/permission-denied-on-accessing-host-directory-in-docker).

I hope you found this helpful, please reach out if you find any mistakes or have any additional questions. The Dockerfile is in the GitHub repo for this blog.

Thanks for reading,

Jamie
