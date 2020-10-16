---
title: "PowerShell REST API with Polaris"
date: 2020-10-15T21:00:32-04:00
tags:
- Open Source
- PowerShell
- Polaris
- REST API
---

PowerShell is a fascinating language that can be used ubiquitously by someone who does system administration, DevOps, or other automation tasks. If the tooling you often work with had the support or only supports PowerShell, this can make it difficult if you needed to build a webhook or some other type of wrapper around that tooling. Fortunately, PowerShell does have a few different web frameworks that can be used to add that functionality and integrate with that tooling seamlessly. Now that we have covered what I see as the primary use case, we will build a REST API that implements GET, POST, PUT, and DELETE HTTP verbs all in PowerShell using the [Polaris](https://github.com/PowerShell/Polaris) module. All of these modules will support all versions of PowerShell, including PowerShell Core running on macOS and Linux.

## Installing Polaris and other modules

The first step is to install the Polaris and [PSSQLite](https://github.com/RamblingCookieMonster/PSSQLite) modules. Let's install Polaris first.

```PowerShell
$ Install-Module Polaris
```

Now we can install PSSQLite

```PowerShell 
$ Install-Module PSSQLite
```

After getting these two modules installed, we can start creating our REST API.

## Creating the REST API

Let's create a file call *app.ps1* that we will use to build our API. In the first few lines of that file, we will import our modules.

```PowerShell
Import-Module Polaris
Import-Module PSSQLite
```

Now that our modules are imported, we are going to create our database schema. Yes, we are going to have a database backing our API. We will check it to see if our table already exists in our database. If not, we will create it.

```PowerShell
$DoesTableExist = "SELECT COUNT(*) as Count FROM sqlite_master WHERE type='table' AND name='PEOPLE';"
$CreateDatabaseQuery = "CREATE TABLE PEOPLE (id INTEGER PRIMARY KEY, name TEXT UNIQUE);"
$DataSource = "/home/phillipsj/code/polaris/People.SQLite"

$tableExist = Invoke-SqliteQuery -Query $DoesTableExist -DataSource $DataSource
if($tableExist.Count -lt 1) {
    Invoke-SqliteQuery -Query $CreateDatabaseQuery -DataSource $DataSource
}
```

The first API route we are going to define is to return all people from our people table.

```PowerShell
New-PolarisRoute -Path "/api/people" -Method GET -Scriptblock {
    $DataSource = "/home/phillipsj/code/polaris/People.SQLite"
    $getId = "SELECT id, name from PEOPLE"
    $data = Invoke-SqliteQuery -DataSource $DataSource -Query $getId
    $Response.Json(($data | ConvertTo-Json))
} 
```

Now that we can return all the people from our table let's create the ability to return a single person.

```PowerShell
New-PolarisRoute -Path "/api/person/:id" -Method GET -Scriptblock {
    $DataSource = "/home/phillipsj/code/polaris/People.SQLite"
    $getId = "SELECT id, name from PEOPLE where id == @id"
    $data = Invoke-SqliteQuery -DataSource $DataSource -Query $getId -SqlParameters @{
      id = $Request.Parameters.id
    }
    if($data.Count -eq 0) {
        $Response.SetStatusCode(404)
        $Response.Send("Person $($Request.Parameters.id) not found!")
    }
    else {
        $Response.Json(($data | ConvertTo-Json))
    }    
}
```

We can return all people and a single person by their id, now we need a way to create a person.

```PowerShell
New-PolarisRoute -Path "/api/person" -Method POST -Scriptblock {
    $DataSource = "/home/phillipsj/code/polaris/People.SQLite"
    if ($Request.Body) {
        $insertQuery = "INSERT INTO PEOPLE (name) VALUES (@name)"
        Invoke-SqliteQuery -DataSource $DataSource -Query $insertQuery -SqlParameters @{
            name = $Request.Body.name
        }

        $getId = "SELECT id from PEOPLE where name == @name"
        $data = Invoke-SqliteQuery -DataSource $DataSource -Query $getId -SqlParameters @{
            name = $Request.Body.name
        }

        $Response.Send("Person $($data.id) created!")
    } else {
        $Response.Send("No data set!")
    }
}
```

Next is to implement PUT so we can update people.

```PowerShell
New-PolarisRoute -Path "/api/person/:id" -Method PUT -ScriptBlock {
    $DataSource = "/home/phillipsj/code/polaris/People.SQLite"

    $updateStmt = "UPDATE PEOPLE SET name = @name WHERE id = @id"
    Invoke-SqliteQuery -DataSource $DataSource -Query $updateStmt -SqlParameters @{
        id = $Request.Parameters.id
        name = $Request.Body.name
    }
    $Response.Send("Updating person $($Request.Parameters.id)")
}
```

Lastly, we need a way to delete a person, we will implement DELETE.

```PowerShell
New-PolarisRoute -Path "/api/person/:id" -Method DELETE -ScriptBlock {
    $DataSource = "/home/phillipsj/code/polaris/People.SQLite"
    $getId = "DELETE from PEOPLE where id == @id"
    Invoke-SqliteQuery -DataSource $DataSource -Query $getId -SqlParameters @{
      id = $Request.Parameters.id
    }
    $Response.Send("Person $($Request.Parameters.id) was deleted")
}
```

All that is left is to start our Polaris application and start our console loop. You will notice that we have the *UseJsonBodyParserMiddleware*, allowing us to parse any request bodies as JSON.

```PowerShell
$app = Start-Polaris -Port 8082 -MinRunspaces 1 -MaxRunspaces 5 -UseJsonBodyParserMiddleware -Verbose # all params are optional

while($app.Listener.IsListening){
    Wait-Event callbackcomplete
}
```

## Running the API

Let's run our API.

```PowerShell
$ ./app.ps1
VERBOSE: Authentication Scheme set to: Anonymous
VERBOSE: App listening on Port: 8082!
```

With it running, you can now use a tool like [Postman](https://www.postman.com/) to exercise the API to populate your database and verify that records are being created.

## Conclusion

This has been a quick post on how to use Polaris. The real utility comes in when there are PowerShell commands available for a piece of server-side software that you may want to wrap in an API to execute those remotely or as part of a process. Another interesting use case is wrapping PowerShell commands in a webhook to trigger jobs from other systems.

Thanks for reading,

Jamie
