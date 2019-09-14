---
Title: "Using ILRepack with .NET Core SDK and .NET Standard"
date: 2019-08-01T20:15:57
Tags: 
- Open Source
- .NET Core
- Microsoft
- Cake
- Tools
---

# Using ILRepack with .NET Core SDK and .NET Standard

We used to think to have a package manager in .NET would solve all of our problems, then we ended up with NuGet dependency conflicts. We later discovered the witchcraft that is assembly binding redirects. I had experienced this issue in the past, but it has more personally impacted when I authored [Cake.AzureStorage](https://github.com/cake-contrib/Cake.AzureStorage) which uses the Azure Storage SDK, which has a dependency on JSON .NET. Well, unfortunately for me, Cake and several other addins had a dependency on JSON .NET and it was a different version. The solution I had available at the time leveraged ILMerge to weave those libraries into mine with a private scope. This process altered the namespace of the classes in the dlls and injected those classes directly into my code. Now that the world is finally moving on to .NET Standard, ILMerge is no longer an option to achieve this functionality. Luckily for us, a new project called [ILRepack](https://github.com/gluck/il-repack) has come along to enable IL weaving for .NET Core and .NET Standard.

I am going to walk you through how to implement this for a .NET Standard 2.0 library that I maintain called [Cake.XdtTransform](https://github.com/cake-contrib/Cake.XdtTransform). This post is only an example of how to do use ILRepack.

We are making these changes in the **csproj** file. Here is mine before any modifications.

```XML
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>netstandard2.0</TargetFramework>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
  </PropertyGroup>

  <PropertyGroup>
    <Authors>Jamie Phillips</Authors>
    <Copyright>Copyright © 2015-$([System.DateTime]::Now.Year) - Jamie Phillips</Copyright>
    <Description>Cake Addin for performing XDT based config file transforms.</Description>
    <PackageIconUrl>https://cdn.jsdelivr.net/gh/cake-contrib/graphics/png/cake-contrib-medium.png</PackageIconUrl>
    <PackageLicenseExpression>MIT</PackageLicenseExpression>
    <PackageProjectUrl>https://github.com/cake-contrib/Cake.XdtTransform</PackageProjectUrl>
    <PackageTags>Cake;Script;Build;Transform;Config;XDT</PackageTags>
    <RepositoryUrl>$(PackageProjectUrl)</RepositoryUrl>  
    <RepositoryType>git</RepositoryType>  
  </PropertyGroup>
  
  <ItemGroup>
    <PackageReference Include="Cake.Core" Version="0.33.0" PrivateAssets="All" />
    <PackageReference Include="DotNet.Xdt" Version="2.1.1" />
  </ItemGroup>

</Project>
```

The first step will be to add the ILRepack build task package to our project. Then mark the DotNet.Xdt and ILRepack build task as *Private Assets* so they will not be included in the list of dependencies in the NuGet package.

```XML
<ItemGroup>
  <PackageReference Include="Cake.Core" Version="0.33.0" PrivateAssets="All" />
  <PackageReference Include="DotNet.Xdt" Version="2.1.1" PrivateAssets="All"/>
  <PackageReference Include="ILRepack.MSBuild.Task" Version="2.0.13" PrivateAssets="All"/>
</ItemGroup>
```

Now that we have that added let's run a build to make sure that we didn't break anything.

```Bash
$ dotnet build
```

Good, now let's add what the task to our project. Add this after our package references item group.

```XML
<Target Name="ILRepack" AfterTargets="Build" Condition="'$(Configuration)' == 'Release'">
    <PropertyGroup>
      <WorkingDirectory>$(MSBuildThisFileDirectory)bin\$(Configuration)\$(TargetFramework)</WorkingDirectory>
    </PropertyGroup>
    <ItemGroup>
      <InputAssemblies Include="DotNet.Xdt.dll" />
    </ItemGroup>
    <ItemGroup>
      <!-- Dot not internalize any types inside this assembly -->
      <InternalizeExcludeAssemblies Include="Cake.Core.dll" />
    </ItemGroup>
    <Message Text="MERGING: @(InputAssemblies->'%(Filename)') into $(OutputAssembly)" Importance="High" />
    <ILRepack
      OutputType="$(OutputType)"
      MainAssembly="$(AssemblyName).dll"
      OutputAssembly="$(AssemblyName).dll"
      InputAssemblies="@(InputAssemblies)"
      InternalizeExcludeAssemblies="@(InternalizeExcludeAssemblies)"
      WorkingDirectory="$(WorkingDirectory)" />
</Target>  
```

A lot is going on in the snippet above, let's start at the top and break it down section by section. When we define the target, we are going to limit this to the Release configuration, so we don't see weird issues when debugging our library. The first property group is going to define our working directory; this, of course, will be our bin directory for our build configuration and target framework. In our case, this will be *Release\netstandard2.0*. The first item group will be the list of assemblies that we want to weave into our assembly. Since this is only one library without any dependencies, it is pretty simple, for a more complex example check out Cake.AzureStorage project file [here](https://github.com/cake-contrib/Cake.AzureStorage/blob/develop/src/Cake.AzureStorage/Cake.AzureStorage.csproj). The next item group is defining the assemblies we don't want to merge. In this case, we don't want to merge any assemblies like Cake.Core which will be provided by the Cake runtime. In this example, I added a message letting me know that I was running this task, you can remove this if you don't think it is helpful. Finally, we get to the ILRepack section, which you can copy and paste as is. Parameters don't need to be changed, and if it is something you need to change, you will know what to do.

Now, all we need to do is run a Release build and see what happens.

```Bash
$ dotnet build -c Release
Microsoft (R) Build Engine version 16.2.32702+c4012a063 for .NET Core
Copyright (C) Microsoft Corporation. All rights reserved.

  Restore completed in 32.97 ms for ~\code\Cake.XdtTransform\src\Cake.XdtTransform\Cake.XdtTransform.csproj.
  Cake.XdtTransform -> ~\code\Cake.XdtTransform\src\Cake.XdtTransform\bin\release\netstandard2.0\Cake.XdtTransform.dll
  MERGING: DotNet.Xdt into 
~\code\Cake.XdtTransform\src\Cake.XdtTransform\Cake.XdtTransform.csproj(38,3): error : ILRepack: Unable to find input assembly at index 0: ~\code\Cake.XdtTransform\src\Cake.XdtTransform\bin\release\netstandard2.0\DotNet.Xdt.dll.

Build FAILED.

~\code\Cake.XdtTransform\src\Cake.XdtTransform\Cake.XdtTransform.csproj(38,3): error : ILRepack: Unable to find input assembly at index 0: ~\code\Cake.XdtTransform\src\Cake.XdtTransform\bin\release\netstandard2.0\DotNet.Xdt.dll.
    0 Warning(s)
    1 Error(s)

Time Elapsed 00:00:01.82
```

Well, I wonder what happened. This error is stating that the DotNet.Xdt.dll isn't in our build output directory. This error occurs because the output didn't get the NuGet packages copied to it. We can fix this by adding the following line right below the *TargetFramework* tag.

```XML
<CopyLocalLockFileAssemblies>true</CopyLocalLockFileAssemblies>
```

Here it is added.

```XML
<PropertyGroup>
  <TargetFramework>netstandard2.0</TargetFramework>
  <GenerateDocumentationFile>true</GenerateDocumentationFile>
  <CopyLocalLockFileAssemblies>true</CopyLocalLockFileAssemblies>
</PropertyGroup>
```

Now when we run our build.

```Bash
$ dotnet build -c Release
Microsoft (R) Build Engine version 16.2.32702+c4012a063 for .NET Core
Copyright (C) Microsoft Corporation. All rights reserved.

  Restore completed in 34.38 ms for ~\code\Cake.XdtTransform\src\Cake.XdtTransform\Cake.XdtTransform.csproj.
  Cake.XdtTransform -> ~\code\Cake.XdtTransform\src\Cake.XdtTransform\bin\Release\netstandard2.0\Cake.XdtTransform.dll
  MERGING: DotNet.Xdt into 
  ILRepack: Output type: Dll.
  ILRepack: Internalize: yes.
  ILRepack: Working directory: ~\code\Cake.XdtTransform\src\Cake.XdtTransform\bin\Release\netstandard2.0.
  ILRepack: Main assembly:
  ~\code\Cake.XdtTransform\src\Cake.XdtTransform\bin\Release\netstandard2.0\Cake.XdtTransform.dll.
  ILRepack: Output assembly:
  ~\code\Cake.XdtTransform\src\Cake.XdtTransform\bin\Release\netstandard2.0\Cake.XdtTransform.dll.
  ILRepack: Internalize exclude assemblies (2): ^Cake.XdtTransform.dll Cake.Core.dll.
  ILRepack: Input assemblies (2):
  ~\code\Cake.XdtTransform\src\Cake.XdtTransform\bin\Release\netstandard2.0\Cake.XdtTransform.dll ~\code\Cake.XdtTransform\src\Cake.XdtTransform\bin\Release\netstandard2.0\DotNet.Xdt.dll.
  ILRepack: IL Repack - Version 2.0.13
  ILRepack: Runtime: ILRepack.MSBuild.Task, Version=2.0.13.0, Culture=neutral, PublicKeyToken=null
  ......
  ILRepack: Adding assembly for merge: ~\code\Cake.XdtTransform\src\Cake.XdtTransform\bin\Release\netstandard2.0\Cake.XdtTransform.dll
  ILRepack: Adding assembly for merge:
  ~\code\Cake.XdtTransform\src\Cake.XdtTransform\bin\Release\netstandard2.0\DotNet.Xdt.dll
  ILRepack: Merging Win32 resources
  ILRepack: Processing references
  ILRepack: Processing types
  ILRepack: - Importing <Module> from Cake.XdtTransform.dll
  ILRepack: - Importing <Module>
  ILRepack: Merging <Module>
  ......
  ILRepack: - Importing <Module> from DotNet.Xdt.dll
  ILRepack: - Importing <Module>
  ILRepack: Merging <Module>
  ......
  ILRepack: Processing exported types
  ILRepack: Processing resources
  ILRepack: - Importing DotNet.Xdt.SR.resources
  ILRepack: Fixing references
  ......
  ILRepack: Processing XAML resource paths ...
  ILRepack: Writing output assembly to disk
  ILRepack: Patching Win32 resources
  ILRepack: Finished in 00:00:00.7076593

Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:01.68
```

Now when we create our NuGet package the DotNet.Xdt library will be "embedded" inside of our DLL. This "embedding" prevents conflicts with other libraries that might use it. It does make your DLL larger, but it isn't a significant amount at all. In this case, the library when from 13KB to 77KB, however the DotNet.Xdt library was 83KB. So while this one grew, it is smaller overall.

Here is what it all looks like together.

```XML
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>netstandard2.0</TargetFramework>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <CopyLocalLockFileAssemblies>true</CopyLocalLockFileAssemblies>
  </PropertyGroup>

  <PropertyGroup>
    <Authors>Jamie Phillips</Authors>
    <Copyright>Copyright © 2015-$([System.DateTime]::Now.Year) - Jamie Phillips</Copyright>
    <Description>Cake Addin for performing XDT based config file transforms.</Description>
    <PackageIconUrl>https://cdn.jsdelivr.net/gh/cake-contrib/graphics/png/cake-contrib-medium.png</PackageIconUrl>
    <PackageLicenseExpression>MIT</PackageLicenseExpression>
    <PackageProjectUrl>https://github.com/cake-contrib/Cake.XdtTransform</PackageProjectUrl>
    <PackageTags>Cake;Script;Build;Transform;Config;XDT</PackageTags>
    <RepositoryUrl>$(PackageProjectUrl)</RepositoryUrl>  
    <RepositoryType>git</RepositoryType>  
  </PropertyGroup>
  
  <ItemGroup>
    <PackageReference Include="Cake.Core" Version="0.33.0" PrivateAssets="All" />
    <PackageReference Include="DotNet.Xdt" Version="2.1.1" PrivateAssets="All"/>
    <PackageReference Include="ILRepack.MSBuild.Task" Version="2.0.13" PrivateAssets="All"/>
  </ItemGroup>

 <Target Name="ILRepack" AfterTargets="Build" Condition="'$(Configuration)' == 'Release'">
    <PropertyGroup>
      <WorkingDirectory>$(MSBuildThisFileDirectory)bin\$(Configuration)\$(TargetFramework)</WorkingDirectory>
    </PropertyGroup>
    <ItemGroup>
      <InputAssemblies Include="DotNet.Xdt.dll" />
    </ItemGroup>
    <ItemGroup>
      <!-- Dot not internalize any types inside this assembly -->
      <InternalizeExcludeAssemblies Include="Cake.Core.dll" />
    </ItemGroup>
    <Message Text="MERGING: @(InputAssemblies->'%(Filename)') into $(OutputAssembly)" Importance="High" />
    <ILRepack
      OutputType="$(OutputType)"
      MainAssembly="$(AssemblyName).dll"
      OutputAssembly="$(AssemblyName).dll"
      InputAssemblies="@(InputAssemblies)"
      InternalizeExcludeAssemblies="@(InternalizeExcludeAssemblies)"
      WorkingDirectory="$(WorkingDirectory)" />
  </Target>  
</Project>
```

That's it, and we now have a NuGet package with no dependencies embedded in the Cake.XdtTransfrom.dll.

Thanks for reading,

Jamie
