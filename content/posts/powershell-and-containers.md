---
title: "PowerShell and Containers"
date: 2020-11-02T22:30:16-04:00
tags:
- Open Source
- PowerShell
- PowerShell Containers
- Microsoft And Linux
- Containers
- Docker
---

Did you know that Microsoft published official container images for PowerShell? Those official images can be found [here](https://hub.docker.com/_/microsoft-powershell), and one cool thing to note is that there are even some ARM images. It is incredibly cool that these are provided as it makes shipping PowerShell tools simpler or hosting any PowerShell based script. I have two different use cases that I can demonstrate that make these pretty cool. The first demo is going to be using the Alpine image as the base image for building a container that hosts a [Polaris](https://github.com/PowerShell/Polaris) based REST API, like I [blogged](https://www.phillipsj.net/posts/powershell-rest-api-with-polaris/) about a few weeks ago. The second demo will be to host a PowerShell script that needs to run as a sidecar to a SQL Server container. Let's dive into these demos.

## Hosting a Polaris REST API in a container

The first item will be to build our Polaris API. We will keep this really simple and just have two endpoints, one that returns a list and the other that will produce a single value. Create *api.ps1* and add the following.

```PowerShell
Import-Module Polaris

$data = @(
    @{Id="1";Name="Jamie"}
    @{Id="2";Name="Chuck"}
   )

New-PolarisRoute -Path "/api/people" -Method GET -Scriptblock {
    $Response.Json(($data | ConvertTo-Json))
} 

New-PolarisRoute -Path "/api/people/:id" -Method GET -Scriptblock {
    $person = $data | Where-Object { $_.Id -eq $Request.Parameters.id }
    $Response.Json(($person | ConvertTo-Json))
} 

# Start the server
$app = Start-Polaris -Port 8082 -MinRunspaces 1 -MaxRunspaces 5 -UseJsonBodyParserMiddleware -Verbose # all params are optional

while($app.Listener.IsListening){
    Wait-Event callbackcomplete
}
```

Now we can create our Dockerfile. We will be using the most recent Alpine image as our base. Then we will need to install Polaris, copy our api.ps1, and set the command that the container needs to execute.

```Dockerfile
FROM mcr.microsoft.com/powershell:7.0.3-alpine-3.10-20201027

SHELL ["pwsh", "-Command"]

RUN Install-Module -Name Polaris -Force

COPY api.ps1 api.ps1

CMD ["pwsh", "-File", "api.ps1"]
```

Now I chose to set the default shell to be PowerShell, which isn't necessary, but you would need to make sure that you execute all PowerShell commands as you do from Bash. Let's build our container.

```Bash
$ docker build -t polaris-api:latest .
Successfully tagged polaris-api:latest
```

Finally, we can run our new container.

```Bash
$ docker run -d -p 5000:8082 polaris-api:latest
```

Now for a few queries to make sure that it works.

```Bash
$ http get http://localhost:5000/api/people
HTTP/1.1 200 OK
Content-Length: 90
Content-Type: application/json
Date: Mon, 02 Nov 2020 02:27:07 GMT
Server: Microsoft-NetCore/2.0

[
    {
        "Id": "1",
        "Name": "Jamie"
    },
    {
        "Id": "2",
        "Name": "Chuck"
    }
]
```

```Bash
$ http get http://localhost:5000/api/people/2
HTTP/1.1 200 OK
Content-Length: 34
Content-Type: application/json
Date: Mon, 02 Nov 2020 02:28:15 GMT
Server: Microsoft-NetCore/2.0

{
    "Id": "2",
    "Name": "Chuck"
}
```

That's it for this demo.

## PowerShell sidecar for SQL Server

This is just a silly little demo; however, it will show what can be possible. We will create a PowerShell script that uses the SqlServer module to execute a query against an Adventure Works database container continuously to generate load. This example will use Docker Compose to run both containers, and this scenario would work just fine on Kubernetes. 

Here is our simple PowerShell script to query. One thing to note is that I am going to leverage the exit code. When the always restart is configured, the exit code will trigger compose/Kubernetes to restart the container if the exit code is 1. This will make sure that our container keeps trying to reconnect to the database. Create *query.ps1*, notice that we are using an environment variable to pass in our ConnectionString.

```PowerShell
Write-Host "Starting query script..."

Import-Module -Name SqlServer

$ErrorActionPreference = 'Stop'

while($true) {
    Write-Host "Executing query..."
    Invoke-Sqlcmd -ConnectionString $env:ConnectionString -Query "SELECT * FROM [Sales].[vSalesPerson]"
}
```

Now we can define our Dockerfile to create our container.

```Dockerfile
FROM mcr.microsoft.com/powershell:7.0.3-alpine-3.10-20201027

SHELL ["pwsh", "-Command"]

RUN Install-Module -Name SqlServer -Force

COPY query.ps1 query.ps1

CMD ["pwsh", "-File", "query.ps1"]
```

Let's build our container.

```Bash
$ docker build -t psquery:latest .
Successfully tagged psquery:latest
```

It's time to create our Docker Compose file, create *docker-compose.yml* in the same directory. We will be defining two containers, our SQL Server container with Adventure Works and our psquery container.

```YAML
version: "3.3"
services:
  db:
    image: phillipsj/adventureworks:latest
    ports:
      - "1433:1433"
  pwsh:
    image: psquery:latest
    restart: always
    environment:
      - ConnectionString=Server=db;Database=AdventureWorks2019;User Id=sa;Password=ThisIsNotASecurePassword123;
    depends_on:
      - db
```

We can now run our *docker-compose up* command to bring up both containers. The psquery container will fail until SQL Server is fully up. However, we have set it to return an exit code and configured the restart policy to be always. So Docker will continuously restart the container, and at some point, it will be able to connect and start executing the query in a loop. Expanding on this idea, you could put in pauses and vary the queries to generate a database workload.

```Bash
$ docker-compose up
Starting db_1 ... done
Starting pwsh_1 ... done
Attaching to db_1, pwsh_1
.........................
```

## Conclusion

These are just two examples of how you can leverage the PowerShell container to run a PowerShell script. The examples aren't the most feature-rich, yet should provide you with an excellent base to start using PowerShell more with containers. 

Thanks for reading,

Jamie
