---
Title: ".NET Core Publishing: SCD and FDD"
Published: 06/05/2018 22:47:08
Tags: 
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
---
# .NET Core Publishing: SCD and FDD

Today we are going to learn and discuss the two basic publishing options that are *out of the box* with the .NET CLI. These two options are [Framework-dependent Deployments](https://docs.microsoft.com/en-us/dotnet/core/deploying/index#framework-dependent-deployments-fdd), known as **FDD**, and [Self-contained Deployments](https://docs.microsoft.com/en-us/dotnet/core/deploying/index#self-contained-deployments-scd), known as **SCD**.

Here is the break down for how we are going to demonstrate the difference. We are going to build a simple .NET console application and then use Docker to demonstrate the behavior of FDD and SCD on Ubuntu Linux.

If you do not have Docker installed, you can still follow along, you just will not be able to see the differences in behavior, but you will still learn how to perform both types of publishing.

Let's get started by creating the sample application. Please note that I am doing this all from Windows using PowerShell, the commands will not be very different if you are using Bash.

```
$ dotnet new console -o FddAndSdd
```

Now lets change the default *Hello World* string to be the following.

```
Console.WriteLine("Hello from a published app!");
```

Now let us build and run it to just make sure we are ok.

```
$ dotnet run
Hello from a published app!
```

Now we can get started.

## FDD: Framework Dependent Deployments

FDD is the default behavior when you run the *publish* command. Let's do that now and discuss the output.

```
$ dotnet publish
```

What happens is that a build is ran and your application is published to the *bin/<Debug|Release>/netcoreapp2.0/publish* as a dll. Now all you need to do to run your application is execute the dotnet command passing it your dll.

```
$ dotnet .\bin\Debug\netcoreapp2.0\publish\FddAndSdd.dll
Hello from a published app!
```

If we wanted to do a release build then it is just a flag to set it.

```
$ dotnet publish -c release
$ dotnet .\bin\Release\netcoreapp2.0\publish\FddAndSdd.dll
Hello from a published app!
```

Now let's pull down an image without the .NET runtime. We will mount the project directory and then try to execute the application from the command line in the container.

Let's pull the Ubuntu 18.04 image:

```
$ docker pull ubuntu:18.04
```

Once that is pulled we are going to run that image, mount our working directory as a volume and drop into the cmd.

```
$ docker run -t -i -v ~/code/FddAndSdd/bin/Release/netcoreapp2.0/publish:/publishing ubuntu:18.04 /bin/bash
root@f3afb2a2e818:/#
```

Okay, let's navigate to the dll and try to run it.

```
$ root@f3afb2a2e818:/# cd publishing/
$ root@f3afb2a2e818:/publishing# ls
FddAndSdd.deps.json  FddAndSdd.dll  FddAndSdd.pdb  FddAndSdd.runtimeconfig.json

$ root@f3afb2a2e818:/publishing# ./FddAndSdd.dll
bash: ./FddAndSdd.dll: cannot execute binary file: Exec format error

$ root@f3afb2a2e818:/publishing# dotnet FddAndSdd.dll
bash: dotnet: command not found
```

Hmm, that didn't work. It didn't work because the .NET runtime was not installed and since this is an FDD published app you have to call it with the *dotnet* command which isn't installed either. 

Let's pull down the pre-built image from Microsoft that has the runtime and let's see if we get a different result.

```
$ docker pull microsoft/dotnet:2.1.0-runtime-bionic
$ docker run -t -i -v ~/code/FddAndSdd/bin/Release/netcoreapp2.0/publish:/publishing microsoft/dotnet:2.1.0-runtime-bionic /bin/bash

$ root@c6d3688e8334:/# cd publishing/
$ root@c6d3688e8334:/publishing# ls
FddAndSdd.deps.json  FddAndSdd.dll  FddAndSdd.pdb  FddAndSdd.runtimeconfig.json

$ root@c6d3688e8334:/publishing# ./FddAndSdd.dll
bash: ./FddAndSdd.dll: cannot execute binary file: Exec format error

$ root@c6d3688e8334:/publishing# dotnet FddAndSdd.dll
Hello from a published app!
```

Ah! Executing the app without the dotnet command doesn't work, which is expected. Now that we have the *dotnet* runtime installed it works with the *dotnet* command. If you don't grab an image with the runtime or a user is installing the application, then the following will have to be performed to get the runtime.

First install the repository that hosts the runtime:

```
$ wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg
$ sudo mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
$ wget -q https://packages.microsoft.com/config/ubuntu/18.04/prod.list 
$ sudo mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
$ sudo chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
$ sudo chown root:root /etc/apt/sources.list.d/microsoft-prod.list
```

Now install the runtime:

```
$ sudo apt-get install apt-transport-https
$ sudo apt-get update
$ sudo apt-get install aspnetcore-runtime-2.1
```

Now that seems like a lot of extra work to make sure that the runtime is already installed to get your application working. For a less technical user, this would be a daunting task, especially adding a thirdy party repository.

With this example out of the way, we can discsus some of the advantages and disadvantages. With system wide runtime security patches will be regularly applied. The deployment package will be smaller and you don't have to target any specific environments. Biggest disadvantage is that updates to the existing runtime or it's removal will impact your application. Another disadvantage is that your users will need to install the runtime themselves, which isn't always the most friendly for users.

## SCD: Self-contained Deployments

SCD differs from FDD as it will publish the runtime along with your application. Since the runtime will be included you have to know what platforms you are planning to target at publishing time. 

Let's publish our application as an SCD which requires us to pass the [RFID](https://docs.microsoft.com/en-us/dotnet/core/rid-catalog) of the runtime we want to target.

```
$ dotnet publish -c release -r win-x64
$ .\bin\release\netcoreapp2.0\win-x64\publish\FddAndSdd.exe
Hello from a published app!
```

As you can see, we published an SCD for Windows which generated an EXE file for us. We can execute it and it works as expected. Now let's build a Linux SCD, we are going to use the portable version, you can use a specific RFID for the platform if you specifically want to target.

```
$ dotnet publish -c release -r linux-x64
$ .\bin\release\netcoreapp2.0\linux-x64\publish\FddAndSdd
```

Of course nothing happens on Windows because it doesn't know what to do. Let's start an Ubuntu container up and see what happens.

```
$ docker run -t -i -v ~/code/FddAndSdd/bin/release/netcoreapp2.0/linux-x64/publish:/publishing ubuntu:18.04 /bin/bash
$ root@9b4f531fbde6:/#

$ root@9b4f531fbde6:/# cd publishing/
$ root@9b4f531fbde6:/publishing# ls
You will see a ton of files, it is a lot bigger than before.

$ root@9b4f531fbde6:/publishing# ./FddAndSdd
Failed to load ���, error: libunwind.so.8: cannot open shared object file: No such file or directory
Failed to bind to CoreCLR at '/publishing/libcoreclr.so'
```

Now this is interesting, you are thinking "I thought he said it was a self-contained deployment", well it is, however, the .NET runtime has OS dependencies that need to be installed. The additional packages that are required are outlined in the following [documentation](https://docs.microsoft.com/en-us/dotnet/core/linux-prerequisites?tabs=netcore2x#linux-distribution-dependencies). These should be in Ubuntu package repository, which is a step in the right direction as it doesn't require users to add a third party repository.

To prove that it works we are going to add the dependencies.

```
$ docker run -t -i -v ~/code/FddAndSdd/bin/release/netcoreapp2.0/linux-x64/publish:/publishing ubuntu:18.04 /bin/bash

$ root@554fa0cd2c0e:/# apt update
$ root@554fa0cd2c0e:/# apt install libunwind8 libuuid1 liblttng-ust0 libcurl3 libssl1.0.0 libkrb5-3 zlib1g libicu60

$ root@554fa0cd2c0e:/# cd publishing/

$ root@554fa0cd2c0e:/publishing# ./FddAndSdd
Hello from a published app!
```

Now that we have done it the hard way, it's time to let you in on a secret. Microsoft provides docker images that have just the dependencies pre-installed just for SCD apps. They are usually named like this one for Ubuntu 18.04, **2.1.0-runtime-deps-bionic**.

Advantages are that for the most part, installation is much easier. It also allows each app to have it's runtime version self contained which makes multiple .NET runtime installations easier as they will not conflict or force upgrades. Disadvantages are the size and making sure to update the runtime for security patches when you do a new release.

## Conclusion

Hopefully everyone has found this useful or at least demonstrated something you haven't seen before. This is one in many posts that I will be doing as we have several alternative options left to explore. The options that are left are:

* Flatpak
* Snaps
* Native

Each one of these will get a separate post as there is a lot to cover with each one.

Thanks for reading and hit me up on Twitter, LinkedIn, or GitHub if you have any questions or anything you would like to see expanded.