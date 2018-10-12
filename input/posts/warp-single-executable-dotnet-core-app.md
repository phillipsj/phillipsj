---
Title: "Warp: Single executable .NET Core app"
Published: 10/12/2018 18:25:41
Tags: 
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
---
# Warp: Single executable .NET Core app

[Warp](https://github.com/dgiagio/warp) is a pretty cool tool written in Rust that compresses a self-contained published .NET Core application into a single executable. When executing, it is unpacked into a local cache. This solves the deployment issue of self-contained deployments along with providing a really nice cross platform solution. Warp was written by [Diego Giagio](https://github.com/dgiagio). I decided that I wanted to give it a try and see just how it all works. The instructions on the GitHub page are nice. These instructions will be from installing Warp to creating an application and testing it. Let's get started.

## Downloading Warp

Head over to the Github page and find the Warp executable for your platform. I am working on a Linux system so these instructions will be based on that.

These commands download Warp and places in your local usr bin folder.

```Bash
$ wget -O warp-packer https://github.com/dgiagio/warp/releases/download/v0.1.1/linux-x64.warp-packer
$ chmod +x warp-packer
$ sudo mv ./warp-packer /usr/local/bin/warp-packer
```

After that is all completed, let's test it out to make sure it works.

```Bash
$ warp-packer
warp-packer 0.1.1
Diego Giagio <diego@giagio.com>
Create self-contained single binary application

USAGE:
    warp-packer --arch <arch> --exec <exec> --input_dir <input_dir> --output <output>

FLAGS:
    -h, --help       Prints help information
    -V, --version    Prints version information

OPTIONS:
    -a, --arch <arch>              Sets the architecture. Supported: ["linux-x64", "windows-x64", "macos-x64"]
    -i, --input_dir <input_dir>    Sets the input directory containing the application and dependencies
    -e, --exec <exec>              Sets the application executable file name
    -o, --output <output>          Sets the resulting self-contained application file name
```

Now we can test packaging up a .NET Core application.

## .NET Core Application

We are going to create a simple F# based .NET Core application.

```Bash
$ mkdir warped && cd $_
$ dotnet new console -lang F#
```

Now let us add some logic to it to make it something extra.

```F#
open System

[<EntryPoint>]
let main argv =
    match Array.tryHead argv with
    | Some name -> printfn "Hello %s, nice to see you!" name
    | None -> printfn "Please enter your name!"
    0
```

Now that we have this simple application built, we can pick up with the instructions provided on the GitHub page.

## Publishing Application with Warp

Now we are going to get to the fun part, navigate in the terminal back into the *warped* folder and execute this command.

```Bash
$ dotnet publish -c Release -r linux-x64
```

After that finishes, let's pack it with Warp.

```Bash
warp-packer --arch linux-x64 --input_dir bin/Release/netcoreapp2.1/linux-x64/publish --exec warped --output warped
```

Once that is complete let's list all the contens of the directory.

```Bash
$ ls
bin  obj  Program.fs  warped  warped.fsproj
```

Notice that we know have this file called *warped* located in the directory. Let's make it executable.

```Bash
$ chmod +x warped
```

Now we can execute it.

```Bash
$ ./warped
Please enter your name!

$ ./warped Jamie
Hello Jamie, nice to see you!
```

Look there, a single executable that bundles all those self-contained deployment files that were published into a single executable.

There appears to be work on building a global .NET tool for working with warp from the .NET CLI. I'm looking forward to it.

Thanks for reading.