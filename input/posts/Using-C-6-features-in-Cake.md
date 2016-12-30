---
Title: 'Using C# 6 features in Cake'
Published: 2016-07-25 21:47:22
Tags:
- Open Source
- Cake
RedirectFrom: 2016/07/25/Using-C-6-features-in-Cake/index.html
---

I like a lot of features available in C# 6, but my favorite is string interpolation. I think it makes aesthetically pleasing code, cleaner and more expressive.

```
var name = "Dave";

// String.Format example
var messageWithFormat = string.Format("I'm sorry, {0} I'm afraid I can't do that.", name);

// String Interpolation
var messageWithInterpolation = $"I'm sorry, {name} I'm afraid I can't do that.";
```

However, by default you cannot use string interpolation in your Cake file as those bits don't come with Roslyn just yet. This is an extremely easy fix. All you need to do is pass the experimental flag.

```
$ .\build.ps1 -experimental
```

This just gets old and repetitive and I don't know about you, but I like staying as close to the leading edge as possible, so I just make a small change to my bootstrapper file to always pass the experimental flag. Roughly on like 188 of your bootstrapper file, just replace the *$UseExperimental* variable with the *-experimental* flag. 

```
# Previous 
Invoke-Expression "& `"$CAKE_EXE`" `"$Script`" -target=`"$Target`" -configuration=`"$Configuration`" -verbosity=`"$Verbosity`" $UseMono $UseDryRun $UseExperimental $ScriptArgs"

# Altered
Invoke-Expression "& `"$CAKE_EXE`" `"$Script`" -target=`"$Target`" -configuration=`"$Configuration`" -verbosity=`"$Verbosity`" $UseMono $UseDryRun -experimental $ScriptArgs"
```

Now you can make your Cake even more elegant, in my opinion. Here are a few examples of places that string interpolation can be used that I enjoy.

```

// Before
Fixie("./src/\**/bin/" + configuration + "/*.Tests.dll");

// After
Fixie($"./src/\**/bin/{configuration}/*.Tests.dll");

// Before
throw new DirectoryNotFoundException(
        string.Format(
            "Deployment target directory not found {0}",
            deploymentPath
            )
        );

// After
throw new DirectoryNotFoundException(
            $"Deployment target directory not found {deploymentPath}"
            )
        );


```

Thanks for reading.

