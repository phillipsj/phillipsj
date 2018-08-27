---
Title: "Sight-reading Code: Self-Contained Deployments"
Published: 08/26/2018 21:01:57
Tags: 
- Open Source
- Professional
- .NET Core
---
# Sight-reading Code: Self-Contained Deployments

In the world of music there exists the concept called [Sight-reading](https://en.wikipedia.org/wiki/Sight-reading). Sight-reading is all about the ability to perform a piece of music upon first sight. without practice. Highly skilled musicians have this ability through their thousands of hours of practice, other musicians have this ability based on practice and experience. This skill is used when testing muscians for entry into music programs and when joining protestigous groups. Sight-reading requires musicians to have the ability to read several notes ahead of the current note that they are actually playing. Now imagine not only needing to read ahead to know what notes to play, but having to keep the timing of the existing note/notes that you are currently playing. This ability relies on experience, muscle memory, and short-term memory. To get better at sight-reading takes practice and experience with a wide range of musical styles. To get started, most start out using music that isn't complicated and as the intuition grows they start increasing difficult of the music they are studying. Becoming a master at this is extremely difficult, however learning enough to be able to perform a basic piece of music is pretty quick. It is amazing what you are able to learn in a short amount of time, yet takes a life time to master.

The reason I started out writing about this is that in my experience reading code works the same. If you can recall the first time you stared at a moderately complext piece of software and felt lost. I remember and I didn't even have a clue where to get started, when I reflect back at the feeling of starting my first complext desktop softare that performed vehicle tracking using Winforms, C#, and .NET I still feel that sense of being scared and asking what am I going to do. I learned to do software development using VBA, then moved to VB .NET using ASP .NET. I had no clue with Winforms and C#. With that said, in a few months, I knew the code base like everyone else. I navigated with easy and contributed to driving down the backlog. That was 11 years ago this month that I had that feeling. I still have that feeling when I stumble across a piece of new technology that I have no experience using nor with the language it is written. I do realize that I have a secret weapon and that is my ability to sight-read code that I have never seen before and start having intuition about the structure and where to look to gain the information that I am searching. This ability has been developed through on the job training as I tackle new code bases and it has been improved, even accelerated, through participating in Open Source Software. 

Open Source Software provides a ton of source code that you can pratice your sight-reading. Say you are using a specific library at work and you are having an issue or don't understand how it works. What is your first reaction? Stackoverflow? Co-worker? How about going to the source code repository and start reading? The last one is my new default if I want to know how a piece of code internally functions or works. A large reason that I end up reading the source is because I want to extend the library or I want to add a new feature. The only way I can determine how to approach both of those issues is to read the docs and if the docs do not cover what I need to know, then I need to drop down into the source.

With this bit of background, I am needed to know how [Self-contained Deployments](https://docs.microsoft.com/en-us/dotnet/core/deploying/#self-contained-deployments-scd) in .NET core actually work under the hood. I am writing this post as I am actually digging in and finding out what I need to know. My intuition is that there is just a piece of functionality that just zips up everything created with Framework Dependent Deployments bin directory along with a copy of the runtime. I know an *exe* is producded, I wonder what technology they are using to produce the *exe*? Are they using WIX, NSIS, something else entirely different? Let's find out together.

The first step is to find the repository that you want to start splunking around in. I know this is part of the .NET CLI, so I am going to start by going [here](https://github.com/dotnet/cli). I would also highly encourage taking the time to read the *README* as it may provide insight into the organization of the code and where specific items can be found. I immediatley spotted that there is a *src* folder that contains the source code for the project and that is where I want to start. I am now going to go into the *dotnet* folder as that is the one that seems the most relevant to what I want to know. I could be wrong, but let's find out. As a side note, the *redist* folder looks interesting too. 

Once in the *dotnet* directory, I am starting in the *CommandLine* directory as that is where the commands will be stored. I am going to see if I can find the *publish* and follow the logic to find where the *runtime identifier* is being used. The *CommandLine* folder seems to not be the folder that I am wanting. I just noticed that I missed the folder called *commands*. Since that seems even more up in my face, let's check that out. Ah, there is a *dotnet-publish* folder, now I am on to something. Once in there, I am going to open the *Program.cs* file as that one is the start of the command. Now this is interesting, it seems the *PublishCommand* just parses parameters and builds out a set of arguments that get passed to *MSBuild*. This might mean I will need to go read the MSBuild source, but I am going to look around a little more. As a side note, this is very similar to how *Cake* handles a lot of argument parsing inside of Addins and core. This just goes to show that the experience of contributing to Cake has aided me in being able to quickly understand what I am seeing. Now that I have opened the *PublishCommandParser.cs*, I have found the piece of code that tells me what I wanted to know. It is taking the self-contianed argument and setting an MSBuild property. This confirms that I need to look at what is happening in MSBuild.

```
Create.Option(
                    "--self-contained",
                    LocalizableStrings.SelfContainedOptionDescription,
                    Accept.ZeroOrOneArgument()
                        .WithSuggestionsFrom("true", "false")
                        .ForwardAsSingle(o =>
                        {
                            string value = o.Arguments.Any() ? o.Arguments.Single() : "true";
                            return $"-property:SelfContained={value}";
}))
```

Now it is time to go to the [MSBuild Github repo](https://github.com/Microsoft/msbuild). I see another *src* folder so I am going to start there. Inside of that folder the *MSBuild* folder holds some promise. There is a lot of content inside of here, I am going to spend a few minutes exploring the folders to see if I can get a feel for where I should be looking. Another side note, appears that MS builds .NET CLI archives using LZMA compression, if you find that sort of think interesting. Found this little nuget too, [Microsoft.DotNet.PlatformAbstractions](https://www.nuget.org/packages/Microsoft.DotNet.PlatformAbstractions/), another reason to go digging into these projects. After spending some time searching for what I am looking for I decided that I am going to download the code and start doing some text searching over the files to find out where instances of *publish* are mentioned. I have not been able to pinpoint what I am wanting to know, but I am pretty close. Along the way you can see that I have learned a lot about the structure of the .NET CLI and the MSBuild projects. I will post back when I am finding specifically what I am looking to learn.

Thank you for sticking with me if you read until the end. I hope this gives you some insight on strategies, techniques, and confidence to start reading more code. The more code you read the more experience and intuition you will pick up and it will enable you to approach any code base with confidence.