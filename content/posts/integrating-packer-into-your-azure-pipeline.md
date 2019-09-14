---
Title: "Integrating Packer into your Azure Pipeline"
date: 2018-10-17T14:49:01
Tags: 
- Open Source
- PowerShell
- Microsoft And Linux
- Bash 
- Azure
- Azure DevOps
- Packer
---
# Integrating Packer into your Azure Pipeline

[Packer](https://www.packer.io/) is a tool created by [HashiCorp](https://www.hashicorp.com/) that allows you to define virtual machine images as code. This allows repeatable bulding of these images and allows automation. Automating building these images allows turning over security updates to the build process which means that you can place Packer into a Deployment Pipeline and just schedule monthly image builds so your images are always fresh.

I am going to walk you through integrating Packer into Azure Pipelines. I have a sample [repository](https://github.com/phillipsj/packer-azuredevops-example) out on GitHub with a couple basic packer templates with how I like to organize these.

Let's get started with a step by step walk through.

## Create a Build in Azure DevOps

You can create your own example if you want or you can just pull the repistory outlined above. Select the *Empty Job* template.

![](/images/packer-azuredevops/SelectTemplate.png)

After that select your build agent.

![](/images/packer-azuredevops/SelectingBuildAgent.png)

Now with a basic build when need to start adding task to our Agent.

## Install the Packer Extension

The first step is to enable the following [extension](https://marketplace.visualstudio.com/items?itemName=riezebosch.Packer) in AzureDevOps. This is a wonder tool that was created by [Manuel Riezebosch](https://github.com/riezebosch) that is the basis for how I am approaching my Terraform extension.

Add a task and then search for *Packer*.

![](/images/packer-azuredevops/PackerToolInstallerTask.png)

Once found add the extension to your Azure DevOps account.

![](/images/packer-azuredevops/PackerToolInstallerTaskAdded.png)

With that extension added you know have the option to use Packer tasks.

## Add a Packer Tool Installer task

Click to add a task and search for Packer. Select the Packer Tool Installer task and use the default configuration.

![](/images/packer-azuredevops/AddingPackerTool.png)

Now that we can gaurantee that regardless of the build agent Packer will get installed and setup on our path, let's get to validation our templates.

## Add Packer Validate Build Step

Now we are going to create a validate build step for Packer. This step will be used to validate that the syntax in our templates is correct and doesn't contain any errors. I look at this as my "unit" test for Packer and this is ran on every check-in.

Add a Shell or PowerShell step depedending on your target system.

![](/images/packer-azuredevops/AddingPowerShellTask.png)

Choose to make it an "inline" step and add the following code based on *nix or Windows.

### Bash Validate

```Bash
$DIRECTORY="packer-path"
if [ -d "$DIRECTORY" ]; then
  for f in *; do
    if [ -d ${f} ]; then
        packer validate --syntax-only $f
    fi
done
fi
```

### PowerShell Validate

```PowerShell
$path="packer-path"
if(Test-Path $path) {
    $dirs = Get-ChildItem $path | ?{$_PSIsContainer}
    Foreach($dir in $dirs){
        Get-ChildItem .\*.json | ForEach-Object { packer validate --syntax-only $_.FullName }
    }
}
```

Your task should be configured as the PowerShell task below.

![](/images/packer-azuredevops/PowerShellTaskConfiguration.png)

After that step has been added, let's *Save and Queue* a build to make sure we did it all correctly.

![](/images/packer-azuredevops/SaveAndQueue.png)

## Checking the Build

Now click on the notification for the build.

![](/images/packer-azuredevops/BuildQueued.png)

And it will take you to a screen with the build running. After everything is completed it should look like this:

![](/images/packer-azuredevops/SuccessfulValidationBuild.png)

With the build working, let's go back and at the Packer build step.

## Adding Packer build step

Well we are almost finished with this Pipeline for Packer. Now we just need to add the build step that will actually execute Packer.

Let's create another task that will run the build step. We are going to be explicit here and not as generic as we probably don't want all our Packer templates to build at the same time. We do want validation to work that way because we can use it in a CI workflow.

![](/images/packer-azuredevops/AddingPowerShellTask.png)

Choose to make it an "inline" step and add the following code based on *nix or Windows.

### Bash Build

```Bash
cd ./packer/nginx
packer build nginx.json
```

### PowerShell Build

```PowerShell
cd .\packer\nginx
packer build nginx.json
```

Your task should be configured as the PowerShell task below.

![](/images/packer-azuredevops/PowerShellBuildTaskConfigured.png)

After that step has been added, let's *Save and Queue* a build to make sure we did it all correctly.

![](/images/packer-azuredevops/SaveAndQueue.png)

Just like before, let's go to that new build and see if everything worked as expected.

![](/images/packer-azuredevops/CompletedBuild.png)

## Conclusion

Hopefully this provided enough information on how to integrate Packer into your Azure DevOps Pipeline or any CI/CD solution. If you have any questions feel free to ask me on Twitter, GitHub, etc.

Thanks for reading,

Jamie
