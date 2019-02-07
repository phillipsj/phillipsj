---
Title: "Crystal on Azure App Service"
Published: 02/06/2019 21:48:49
Tags: 
- Azure
- Cloud
- Crystal
- Open Source
---
# Crystal on Azure App Service

I have been investigating new languages, and [Crystal](https://crystal-lang.org/) caught my attention. I have always been a fan of Ruby. However, environment configuration has always been complicated, and I was running a lot of Windows at the time. I thought what better way to play around with the language than to create a simple web server and deploy it to my cloud, Azure. I am going to leave installation up to you, however, since I am using a Docker container, you don't need to install anything if you don't want to test it locally.

## Creating our App

Let's start by creating our directories and files.

```Bash
$ mkdir cr-azure
$ cd cr-azure
$ touch Dockerfile
$ mkdir src
$ cd src
$ touch azureTest.cr
```

Now let's open the *azureTest.cr* file and add the following:

```Ruby
require "http/server"

server = HTTP::Server.new do |context|
    context.response.content_type = "text/plain"
    context.response.print "Hello from Azure! The time is #{Time.now}"
end

puts "Listening on http://127.0.0.1:7777"

server.listen("0.0.0.0", 7777)
```

That is it, that is all the Crystal we need to write. Open the *Dockerfile* next and add the following:

```Dockerfile
FROM crystallang/crystal:0.27.2

RUN mkdir /app
WORKDIR /app
ADD . /app/

RUN crystal build src/azureTest.cr --release

CMD ./azureTest
```

This dockerfile downloads the Crystal Docker image, and we will run a build from it to produce our binary that we execute. Finally, we will build our Docker container.

```Bash
$ docker build -t cr-azure .
```

Once that is complete you can test it by running the command below and navigating to [http://localhost:7777](http://localhost:7777) in your browser or by using wget.

```Bash
$ docker run --name cr-azure -p 7777:7777 --rm -it cr-azure:latest
```

Testing that it works using wget:

```Bash
$ wget -nv -O- http://localhost:7777
Hello from Azure! The time is 2019-02-07 03:03:19 +00:002019-02-06 22:03:19 URL:http://localhost:7777/ [56/56] -> "-" [1]
```

Now you need to tag it with your Docker Hub account and push as that is what we will be deploying to Azure. Alternatively, you can use my located at [phillipsj/cr-azure](https://hub.docker.com/r/phillipsj/cr-azure) if you want.

## Creating the App Service in Azure

I feel like using the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) to do this tonight. Let's login to Azure using the CLI.

```Bash
$ az login
```

I only have one subscription, so I will not be setting the account that I want to use. Now it's time to create our Resource Group.

```Bash
$ az group create --name Crystal-RG --location "East US"
```

Next is the App Service Plan, notice that this command is using the *--is-linux* flag, which tells Azure that we want to deploy Linux containers. Also, note that we are using the *B1* SKU, that is basic that is the minimal plan that supports Linux containers.

```Bash
$ az appservice plan create --name Crystal-AP --resource-group Crystal-RG --sku B1 --is-linux
```

Here is the fun part, we can now create our App Service. You will need the image name that you want to deploy, and if you use my image then you can run it as is:

```Bash
$ az webapp create --resource-group Crystal-RG --plan Crystal-AP --name Crystal-AS --deployment-container-image-name phillipsj/cr-azure:latest
```

The last step before we can test our handy work is to set the port in Azure. We are using port 7777 if you followed along with me if you used a different port then make changes accordingly. We need to tell Azure what port we used so it can listen on that port in our Docker container. By default, it listens on port 80 which will not work without changes to our image.

```Bash
$ az webapp config appsettings set --resource-group Crystal-RG --name Crystal-AS --settings WEBSITES_PORT=7777
```

Now it's time for the actual test, did it work.

```Bash
$ wget -nv -O- http://crystal-as.azurewebsites.net
Hello from Azure! The time is 2019-02-07 03:22:05 +00:002019-02-06 22:22:05 URL:http://crystal-as.azurewebsites.net/ [56/56] -> "-" [1]
```

That's it, and it is pretty simple and easily achievable in about half an hour.

## Conclusion

I hope you found this useful and fun. Something about Ruby syntax and Python that I find fun compared to .NET, I haven't figured out how to put some words to it. When I figure out how to explain it, I will put a post together.

Thanks for reading,

Jamie

**If you enjoy the content then consider [buying me a coffee](https://www.buymeacoffee.com/aQPnJ73O8).**