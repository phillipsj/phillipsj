---
Title: "Creating a PowerShell profile on Linux"
date: 2018-10-16T18:28:39
Tags: 
- Open Source
- Microsoft And Linux
- Tools
- PowerShell
---
# Creating a PowerShell profile on Linux

In the world of Linux your shell profile is extremely important. That is what is responsible for aliases, loading plugins, loading auto-completion, and any other specific settings that you need for your environment. PowerShell isn't any different in those regards. This post is going to cover setting up a PowerShell profile and some functionality that will be nice to add to it.

## Setting up a PowerShell profile

PowerShell sets an environment variable called *$profile* that has the location of your profile or the location that your profile will be stored. Your profile typically has the name of *Microsoft.PowerShell_profile.ps1*. On Windows this is stored in the user's *Document* folder in a folder called *WindowsPowerShell* and has the same name.

Let's find out where it is stored on Linux.

```Bash
$ pwsh
PS /home/jamie> $profile
/home/jamie/.config/powershell/Microsoft.PowerShell_profile.ps1
```

If you navigate to the *.config* folder you will notice that the *powershell* folder doesn't exist yet. So this commands shows us where this will be stored by default. Let's open/create our profile and starting adding some functionality.

```PowerShell
PS /home/jamie> code $profile
```

This command will open VSCode with the profile, if you don't have VSCode you can use your favorite editor. Now that we have it open, let's go ahead and save it. Now your profile should show up in the *.config* folder. We have an empty profile and it doesn't provide much functionality.

## Doing normal profile stuff in PowerShell

When I configured Go and the AWS CLI, I added some paths to my *.bashrc*. Let's add those same paths to my PowerShell profile so it will work there too. If you launch PowerShell from Bash then your path is already configured, this really only matters if you are using it as your default shell. To learn how to do that go read this [post](https://www.phillipsj.net/posts/powershell-as-default-shell-on-ubuntu).

```PowerShell
# This adds to the path.
$env:Path += ":/usr/local/go/bin:~/.local/bin"
```

Now that we know how to add some basic functionality, we can add some more command features. Let's set up an alias.

```PowerShell
# This adds to the path.
$env:Path += ":/usr/local/go/bin:~/.local/bin"

# This aliases mkdir to something shorter.
New-Alias "md" "mkdir"
```

Okay an alias is pretty simple, but what is we wanted to implement a few of the [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) [shortcuts](https://github.com/robbyrussell/oh-my-zsh/wiki/Cheatsheet). Guess what, we can do that too.


```PowerShell
# This adds to the path.
$env:Path += ":/usr/local/go/bin:~/.local/bin"

# This aliases mkdir to something shorter.
New-Alias "mk" "mkdir"

# oh-my-zsh shortcuts
function md {
    param(
        [Parameter(Mandatory=true, Position=1)]
        [string]$Path
    )
    mkdir -p $Path
}

function ~ {
    cd ~
}

function rd {
    param(
        [Parameter(Mandatory=true, Position=1)]
        [string]$Path
    )
    rmdir $Path
}
```

This is just a glimpse into what can be done with PowerShell that is typically done with your Bash profile. I threw in a little zsh spice to the mix. PowerShell can really do pretty much everything that other shells can do. The one big advantage that I see is that the programming model is just better, again in my opinion. I will do a post in the future about converting Bash scripts to PowerShell and I will compare the features and constructs.

Thanks for reading, Jamie.
