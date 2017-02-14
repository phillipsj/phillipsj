---
Title: "Azure: Deploying MkDocs to App Service"
Published: 02/13/2017 18:34:39
Tags: 
- Azure
- Cloud
- Open Source
- Tutorials
---
# Azure: Deploying MkDocs to App Service

[MkDocs](http://www.mkdocs.org/) is an great tool to use to build project documentation. My team at work has been using it to create system documentation, consisting of user guides, features, etc. We may look to start using [Wyam](https://wyam.io/) for this in the future, for now, MkDocs has served us and it works on Windows with minimum fuss. As with all of our newer sites, we are hosting on Azure using App Service, with the minimum amount of traffic our documentation receives, free or shared plans work the best. 

I am going to walk you all through how to configure the App Service and the continuos deployment feature that is present. So here goes:

**I will use the term *blade*, that refers to the panels that slide out in Azure.**

## Step 1:  From your Azure Subscription click on *App Services*.

![](/images/other-tutorials/deploy-mkdocs/select-app-services.png)

## Step 2:  Add on the App Services blade.

![](/images/other-tutorials/deploy-mkdocs/add-app-service.png)

## Step 3:  A new blade will open, click on Web App.

![](/images/other-tutorials/deploy-mkdocs/select-web-app.png)

## Step 4:  Click *Create*.

![](/images/other-tutorials/deploy-mkdocs/click-create-web-app.png)

## Step 4:  A new blade will open, enter requested fields. I like to group my resources together by function, but feel free to add to an existing one if you want. I selected a free plan that I already had created. I am also going to turn on *Application Insights* to provide me some analytics. Finally, click *Create* and you should get a notification that it is being deployed.

![](/images/other-tutorials/deploy-mkdocs/click-create-web-app-2.png)

Now that you have deployed App Service, it is time to navigate to it and start wiring it up for deployments. Click on the *Deployment Options* and then click on configure, pick the source control option that you are using and follow the prompts.

![](/images/other-tutorials/deploy-mkdocs/deployment-options.png)

![](/images/other-tutorials/deploy-mkdocs/deployment-source.png)

With that now out of the way, it is time to get to the fun part. Azure uses a tool called [Kudu](https://github.com/projectkudu/kudu) to drive deployments for Azure App Services. So we are going to create a Kudu file for the application that will be checked into the repository. This Kudu file will use the python that is already configured to build our app, then we will use a Kudu command to copy the compiled site to the folder that deploys it.  

So the first thing we are going to do is to create a *.deployment* file. The first couple of lines is going to tell Kudu which folder to deploy. We have to run the compile of the MkDocs so we will need to define a custom deployment script.

```
[config]
command = deploy.cmd
```

Now we need to wire up installing MkDocs and running the build command. We need to create a custom *deploy.cmd* file that we want to execute. Luckily, we can use the Azure CLI tools to generate the basic template for python. 

Put the command line tools in ASM mode.

```
azure config mode asm
```

Now generate the *deploy.cmd* with the following command.

```
azure site deploymentscript --python
```

Below is the script with some modifications. I changed the deployment source to be the *site* folder which is default for mkdocs. I then added step 5 which runs the mkdocs build.

```
@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

:: ----------------------
:: KUDU Deployment Script
:: Version: 1.0.9
:: ----------------------

:: Prerequisites
:: -------------

:: Verify node.js installed
where node 2>nul >nul
IF %ERRORLEVEL% NEQ 0 (
  echo Missing node.js executable, please install node.js, if already installed make sure it can be reached from current environment.
  goto error
)

:: Setup
:: -----

setlocal enabledelayedexpansion

SET ARTIFACTS=%~dp0%..\artifacts

IF NOT DEFINED DEPLOYMENT_SOURCE (
  SET DEPLOYMENT_SOURCE=%~dp0%.
)

IF NOT DEFINED DEPLOYMENT_TARGET (
  SET DEPLOYMENT_TARGET=%ARTIFACTS%\wwwroot
)

IF NOT DEFINED NEXT_MANIFEST_PATH (
  SET NEXT_MANIFEST_PATH=%ARTIFACTS%\manifest

  IF NOT DEFINED PREVIOUS_MANIFEST_PATH (
    SET PREVIOUS_MANIFEST_PATH=%ARTIFACTS%\manifest
  )
)

IF NOT DEFINED KUDU_SYNC_CMD (
  :: Install kudu sync
  echo Installing Kudu Sync
  call npm install kudusync -g --silent
  IF !ERRORLEVEL! NEQ 0 goto error

  :: Locally just running "kuduSync" would also work
  SET KUDU_SYNC_CMD=%appdata%\npm\kuduSync.cmd
)
goto Deployment

:: Utility Functions
:: -----------------

:SelectPythonVersion

IF DEFINED KUDU_SELECT_PYTHON_VERSION_CMD (
  call %KUDU_SELECT_PYTHON_VERSION_CMD% "%DEPLOYMENT_SOURCE%\site" "%DEPLOYMENT_TARGET%" "%DEPLOYMENT_TEMP%"
  IF !ERRORLEVEL! NEQ 0 goto error

  SET /P PYTHON_RUNTIME=<"%DEPLOYMENT_TEMP%\__PYTHON_RUNTIME.tmp"
  IF !ERRORLEVEL! NEQ 0 goto error

  SET /P PYTHON_VER=<"%DEPLOYMENT_TEMP%\__PYTHON_VER.tmp"
  IF !ERRORLEVEL! NEQ 0 goto error

  SET /P PYTHON_EXE=<"%DEPLOYMENT_TEMP%\__PYTHON_EXE.tmp"
  IF !ERRORLEVEL! NEQ 0 goto error

  SET /P PYTHON_ENV_MODULE=<"%DEPLOYMENT_TEMP%\__PYTHON_ENV_MODULE.tmp"
  IF !ERRORLEVEL! NEQ 0 goto error
) ELSE (
  SET PYTHON_RUNTIME=python-2.7
  SET PYTHON_VER=2.7
  SET PYTHON_EXE=%SYSTEMDRIVE%\python27\python.exe
  SET PYTHON_ENV_MODULE=virtualenv
)

goto :EOF

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Deployment
:: ----------

:Deployment
echo Handling python deployment.

:: 1. KuduSync
IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
  call :ExecuteCmd "%KUDU_SYNC_CMD%" -v 50 -f "%DEPLOYMENT_SOURCE%" -t "%DEPLOYMENT_TARGET%" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd"
  IF !ERRORLEVEL! NEQ 0 goto error
)

IF NOT EXIST "%DEPLOYMENT_TARGET%\requirements.txt" goto postPython
IF EXIST "%DEPLOYMENT_TARGET%\.skipPythonDeployment" goto postPython

echo Detected requirements.txt.  You can skip Python specific steps with a .skipPythonDeployment file.

:: 2. Select Python version
call :SelectPythonVersion

pushd "%DEPLOYMENT_TARGET%"

:: 3. Create virtual environment
IF NOT EXIST "%DEPLOYMENT_TARGET%\env\azure.env.%PYTHON_RUNTIME%.txt" (
  IF EXIST "%DEPLOYMENT_TARGET%\env" (
    echo Deleting incompatible virtual environment.
    rmdir /q /s "%DEPLOYMENT_TARGET%\env"
    IF !ERRORLEVEL! NEQ 0 goto error
  )

  echo Creating %PYTHON_RUNTIME% virtual environment.
  %PYTHON_EXE% -m %PYTHON_ENV_MODULE% env
  IF !ERRORLEVEL! NEQ 0 goto error

  copy /y NUL "%DEPLOYMENT_TARGET%\env\azure.env.%PYTHON_RUNTIME%.txt" >NUL
) ELSE (
  echo Found compatible virtual environment.
)

:: 4. Install packages
echo Pip install requirements.
env\scripts\pip install -r requirements.txt
IF !ERRORLEVEL! NEQ 0 goto error

REM Add additional package installation here
REM -- Example --
REM env\scripts\easy_install pytz
REM IF !ERRORLEVEL! NEQ 0 goto error
:: You can do the theme here or in your requirements.txt
env\scripts\pip install mkdocs-bootswatch

:: 5. Build mkdocs
echo Building mkdocs
env\scripts\mkdocs build

:: 6. Copy web.config
IF EXIST "%DEPLOYMENT_SOURCE%\web.%PYTHON_VER%.config" (
  echo Overwriting web.config with web.%PYTHON_VER%.config
  copy /y "%DEPLOYMENT_SOURCE%\web.%PYTHON_VER%.config" "%DEPLOYMENT_TARGET%\web.config"
)

popd

:postPython

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
goto end

:: Execute command routine that will echo out when error
:ExecuteCmd
setlocal
set _CMD_=%*
call %_CMD_%
if "%ERRORLEVEL%" NEQ "0" echo Failed exitCode=%ERRORLEVEL%, command=%_CMD_%
exit /b %ERRORLEVEL%

:error
endlocal
echo An error has occurred during web site deployment.
call :exitSetErrorLevel
call :exitFromFunction 2>nul

:exitSetErrorLevel
exit /b 1

:exitFromFunction
()

:end
endlocal
echo Finished successfully.

```

