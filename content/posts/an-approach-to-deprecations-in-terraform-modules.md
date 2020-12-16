---
title: "An Approach to Deprecations in Terraform Modules"
date: 2020-12-15T21:43:28-05:00
tags:
- Open Source
- Terraform
- HashiCorp
---

Working with modules in Terraform can be challenging. Once a module is used by multiple teams or is published for public consumption, it becomes harder to change the module because those changes will have a larger ripple effect. One way these changes are mitigated is with the versioning of your modules. By versioning, users can choose to opt-in to updates that may cause breaking changes. These changes require manual verification and identification to make sure that it won't impact you. There is an open [GitHub Issue](https://github.com/hashicorp/terraform/issues/5949) suggesting to add a feature to allow designating deprecations so when you run a validate those, any changes that the module's author has flagged will show up. This gives you a chance to catch those changes as part of your regular workflow. However, that issue has been open for over four years. 

I have thought about the problem, and I was planning to write a Go tool that would leverage some conventions to provide a solution that would alleviate or help manage this issue. After thinking, I don't need to write a custom tool to get this in a workable state. I just need to use some tools that are usually available on most Unix/Linux systems. So here is the solution that I settled on that can quickly be approved.

## Step 1: Create a DEPRECATION.md in your module

Most modules have a *README.md*, I propose adding a *DEPRECATION.md* alongside the README file to store two categories of changes, one set that is *Warnings* and another set that is *Errors*. Warnings will be things that will be deprecated in future versions or items that have been tweaked. Errors would be things that would be breaking changes that the consumer will definitely have issues with. I have provided an example.

```markdown
## Warnings

* There will be a breaking change in the next version. Please update the variable password.
* The provider will be updated in the next version.

## Errors

* There has been a breaking change in this version.
```

## Step 2: Parsing and Reporting the DEPRECATION.md

Now that we have this file, we can leverage *find* and *grep* in a Bash script to search all of the modules in our *.terraform* directory and print them to the screen. I have included exit code usage for errors, so if you use this on a build server, it will fail the build. This can easily be tweaked for your needs.

```Bash
#!/usr/bin/env bash

find .terraform/modules/*/DEPRECATION.md | while read item; do 
    #warnings=$(sed "/^## Warnings$/,/^## Errors/!d;//d;/^$/d" $item)
    #warnings=$(grep -zoP '## Warnings\s*\K[\s\S]*(?=\s*## Errors)' ${item})
    echo "--------------------------------------------"
    echo "Searching for warnings and errors in the module:"
    echo "    $item"
    echo ""
    echo "~~~~ Warnings ~~~~"
    #echo $warnings
    grep -zoP '## Warnings\s*\K[\s\S]*(?=\s*## Errors)' "$item"
    
    #errors=$(sed "/^## $1$/,/^## Errors/!d;//d;/^$/d" $item)
    #errors=$(cat $item | grep -zoP '## Errors\s*\K[\s\S]*(?=\s*)' ${item})
    if grep -zoP -q '## Errors\s*\K[\s\S]*(?=\s*)' "$item"
    then
      echo "~~~~ Errors ~~~~"
      grep -zoP '## Errors\s*\K[\s\S]*(?=\s*)' "$item"
      exit 1
    else
      echo "No errors listed."
      exit 0
    fi    
done
```

Now save this as a shell script so you can execute it. The correct time to execute this would be after your run *terraform init*.

## Script in Action

We are now going to execute it to see it in action.

```Bash
$ terraform init
$ sh module-dep.sh
--------------------------------------------
Searching for warnings and errors in the module:
    .terraform/modules/my-module/DEPRECATION.md

~~~~ Warnings ~~~~
* There will be a breaking change in the next version. Please update the variable password.
* The provider will be updated in the next version.

~~~~ Errors ~~~~
* There has been a breaking change in this version.
```

This produced an actionable list that will make it easier on the consumer as long as the author of the module provides useful inputs. This may have better utility with internal usage.

Thanks for reading,

Jamie
