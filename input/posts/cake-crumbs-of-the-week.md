---
Title: "Cake Crumbs of the Week"
Published: 02/25/2017 22:06:52
Tags: 
- Open Source
- Cake
- Cake Crumbs
---
# Cake Crumbs of the Week

I am starting a new series of posts called *Cake Crumbs*.  What I will be doing is sharing little bits of Cake goodness that I have discovered as I use Cake. Some of these items may be in the documentation, some may be obvious to others, and a few may be useful to you.  

## Using a local, file based NuGet source

So you can use local NuGet sources both, UNC and full path with the *addin* and *tool* directives.

```
#addin nuget://Home/Home2/nuget/?package=Cake.WebDeploy
```

## Cake Namespace Imports

Did you know that you can use the *CakeNamespaceImport* attribute to bring in other namespaces with your Cake aliases. Very handy when you need make sure those objects are accessible directly in your Cake script.

In the example below that is why you can reference the NuGetPackSettings class in your Cake script without a using statement.

```
[CakeMethodAlias]
[CakeAliasCategory("Pack")]
[CakeNamespaceImport("Cake.Common.Tools.NuGet.Pack")]
public static void NuGetPack(this ICakeContext context, FilePath filePath, NuGetPackSettings settings)
```