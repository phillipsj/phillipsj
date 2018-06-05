---
Title: ".NET Core Publishing: SCD and FDD"
Published: 06/04/2018 20:47:08
Tags: 
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
---
# .NET Core Publishing: SCD and FDD

Today we are going to learn and discuss the two basic publishing options that are *out of the box* with the .NET CLI. These two options are [Framework-dependent Deployments](https://docs.microsoft.com/en-us/dotnet/core/deploying/index#framework-dependent-deployments-fdd), known as **FDD**, and [Self-contained Deployments](https://docs.microsoft.com/en-us/dotnet/core/deploying/index#self-contained-deployments-scd), known as **SCD**.

Here is the break down for how we are going to demonstrate the difference. We are going to build a simple .NET console application and then use Docker to demonstrate the behavior of FDD and SCD on both Windows and Ubuntu Linux.

If you do not have Docker installed, you can still follow along, you just will not be able to see the differences in behavior, but you will still learn how to perform both types of publishing.

Let's get started by creating the sample application. Please note that I am doing this all from Windows using PowerShell, the commands will not be very different if you are using Bash.

```
dotnet new console -o FddAndSdd
```

Now lets change the default *Hello World* string to be the following.

```
Console.WriteLine("Hello from a published app!");
```

Now let us build and run it to just make sure we are ok.

```
dotnet run
Hello from a published app!
```

Now we can get started.

## FDD: Framework Dependent Deployments

FDD is the default behavior when you run the *publish* command. Let's do that now and discuss the output.

```
dotnet publish
```

What happens is that a build is ran and your application is published to the *bin/<Debug|Release>/netcoreapp2.0/publish* as a dll. Now all you need to do to run your application is execute the dotnet command passing it your dll.

```
dotnet .\bin\Debug\netcoreapp2.0\publish\FddAndSdd.dll
Hello from a published app!
```

If we wanted to do a release build then it is just a flag to set it.

```
dotnet publish -c release
dotnet .\bin\Release\netcoreapp2.0\publish\FddAndSdd.dll
Hello from a published app!
```

Now let's create a Dockerfile that pulls down an image without the .NET runtime. We will mount the project directory and then try to execute the application from the commandline in the container.

#TODO: Insert docker stuff here

This is going to fail, now we need to walk through installing .NET Core then showing how it runs.

With this example out of the way, we can discsus some of the advantages and disadvantages. With system wide runtime security patches will be regularly applied. The deployment package will be smaller and you don't have to target any specific environments. Biggest disadvantage is that updates to the existing runtime or it's uninstallation will impact your application. Another disadvantage is that your users will need to install the runtime themselves, which isn't always the most friendly for users.

## SCD: Self-contained Deployments

SCD differs from FDD as it will publish the runtime along with your application. Since the runtime will be included you have to know what platforms you are planning to target at publishing time. 