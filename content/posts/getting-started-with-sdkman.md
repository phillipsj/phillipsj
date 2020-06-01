---
title: "Getting Started With SDKMAN!"
date: 2020-05-31T14:37:43-04:00
draft: true
Tags: 
- Linux
- Bash
- JVM
- SDKMAN!
---

There are lots of ways on Linux to get JVM based runtimes and languages. Over the years, I have found [SDKMAN!](https://sdkman.io/) to be one of the easiest ways to get all most all runtimes and languages based on the JVM. A significant advantage of tools like SDKMAN! is that it is a local user install and not a system-wide installation. Let's get started by installing SDKMAN! following the instructions provided.

## Installation

Installation requires downloading a script from their site and piping it to Bash. As with any file you download from the internet, inspect it in the GitHub repository before running it on your system. One advantage of user-level tools is that they don't require any superuser privileges. The official guide shows using *curl* to retrieve the script. If you don't have curl available, you will need to install it. I am running Ubuntu, and curl was required installation.

```Bash
$ sudo apt install curl -y
```

Now we can execute the SDKMAN! script and notice that it does update our **.bashrc** or if you are using zsh your **.zshrc**.

```Bash
$ curl -s "https://get.sdkman.io" | bash
...truncated...
Added sdkman init snippet to /home/phillipsj/.bashrc
Attempt update of zsh profile...
Updated existing /home/phillipsj/.zshrc

All done!

Please open a new terminal, or run the following in the existing one:

    source "/home/phillipsj/.sdkman/bin/sdkman-init.sh"

Then issue the following command:

    sdk help

Enjoy!!!
```

Now that it finished, we do like the instructions say, and we can either restart our terminal to get our **.bashrc** to reload or use the *source* line to load SDKMAN! into the current session. Let's execute the source line.

```Bash
$ source "/home/phillipsj/.sdkman/bin/sdkman-init.sh"
```

Now let's check let's run the *sdk* command to check what that it is working.

```Bash
$ sdk version
==== BROADCAST =================================================================
* 2020-05-31: sbt 1.3.12 released on SDKMAN! #scala
* 2020-05-31: Jbang 0.26.0 released on SDKMAN! See https://github.com/jbangdev/jbang/releases/tag/v0.26.0 #jbang
* 2020-05-29: sbt 1.3.11 released on SDKMAN! #scala
================================================================================

SDKMAN 5.8.2+493
```

We have version 5.8.2 installed, now let's install a JVM SDK like Kotlin. We can list what is available with the following command.

```Bash
$ sdk list 
================================================================================
Available Kotlin Versions
================================================================================
     1.3.72              1.2.71              1.1.60              1.0.5-2        
     1.3.71              1.2.70              1.1.51              1.0.5          
     1.3.70              1.2.61              1.1.50              1.0.4          
     1.3.61              1.2.60              1.1.4-3             1.0.3          
     1.3.60              1.2.51              1.1.4-2             1.0.2          
     1.3.50              1.2.50              1.1.4               1.0.1-2        
     1.3.41              1.2.41              1.1.3-2             1.0.1-1        
     1.3.40              1.2.40              1.1.3               1.0.1          
     1.3.31              1.2.31              1.1.2-5             1.0.0          
     1.3.30              1.2.30              1.1.2-2                            
     1.3.21              1.2.21              1.1.2                              
     1.3.20              1.2.20              1.1.1                              
     1.3.11              1.2.10              1.1                                
     1.3.10              1.2.0               1.0.7                              
     1.3.0               1.1.61              1.0.6                              

================================================================================
+ - local version
* - installed
> - currently in use
================================================================================
```

Let's install *Kotlin*, and it will pick the latest version.

```Bash
$ sdk install kotlin
Downloading: kotlin 1.3.72

In progress...

###################### 100.0%
###################### 100.0%

Installing: kotlin 1.3.72
Done installing!


Setting kotlin 1.3.72 as default.
```

Awesome, we have Kotlin 1.3.72 installed and set as our default. We can use SDKMAN! to install multiple versions and switch between those as needed. Let's verify that Kotlin is working as expected. Let's create a file named *hello.kt* with the contents below.

{{% note "Java needs installing" %}}
**Note:** Kotlin will require the installation of Java. I installed the AdoptOpenJDK version using SDKMAN! with the following command: 

```Bash
$ sdk install java 8.0.252.hs-adpt
```

{{% /note %}}


```Kotlin
fun main(args: Array<String>) {
    println("Hello, SDKMAN!")
}
```

Compile the file with the Kotlin compiler.

```Bash
$ kotlin hello.kt -include-runtime -d hello.jar
```

Now execute our new app.

```Bash
$ java -jar hello.jar
Hello, SDKMAN!
```

## Wrapping Up

SDKMAN! is a helpful tool to have available if you are working with the JVM. You get user-based installs, multiple version support, and the ability to switch between those versions. I also like the fact that you get numerous options when it comes to Java, so you can install Azul or AWS Java for when you are building for a cloud provider.

Thanks for reading,

Jamie
