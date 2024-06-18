---
title: "New Relic SQL Server Monitoring With gMSA"
date: 2024-06-17T20:13:05-04:00
tags:
  - New Relic
  - Observability
  - SQL Server
  - Windows GMSA
---

[Group managed service accounts](https://learn.microsoft.com/en-us/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview),
called gMSA, are a great way to allow automated processes to access resources using a domain account without worry about
rotating passwords. One big issue with gMSA is that some software doesn't work using it. I need to set the New Relic SQL
Server plugin to monitor SQL Server using a gMSA, which took a little digging to work out how to make that happen. The
existing documentation can be
found [here](https://docs.newrelic.com/docs/infrastructure/host-integrations/host-integrations-list/microsoft-sql/microsoft-sql-server-integration/).
That document covers using a domain account, a traditional domain account, not a gMSA. There are a few undocumented
tweaks needed to make this work. Let me walk you through it. Follow the documentation above until you configure
the `mssql-config.yml` file. Once you are at that point, you can pick up here.

### gMSA Permissions:

Grant your gMSA account administrative privileges on your Windows machine. I would suggest making this a dedicated
machine since you will be granting admin to the gMSA. The gMSA account needs these privileges for the next step.

### New Relic Agent Setup:

Open `Services` and set the **New Relic Infrastructure Agent** service to *Log On As* your gMSA account.

### SQL Server Integration Configuration:

Now, we can configure the `mssql-config.yml` file. This took a little digging. I looked in
the [New Relic MS SQL Integration](https://github.com/newrelic/nri-mssql) repository on GitHub for the MS SQL Server
driver being used in the code. This happened to be [go-msqldb](https://github.com/denisenkom/go-mssqldb), and after some
further research, I found out that it can work with a gMSA using integrated security. This leads me to the following
configuration note, both the username and password should be empty.

```YAML
integrations:
  - name: nri-mssql
    env:
      HOSTNAME: <SQL Server Name>
      PORT: 1433
      USERNAME:
      PASSWORD:
    interval: 15s
    labels:
      environment: production
    inventory_source: config/mssql
```

After saving this in my config file, I needed to run the New Relic CLI to validate my configuration.

### Validating the Configuration

Since we are using a gMSA and a user can't interactively log on as the gMSA to run the test command, we have to find an
alternative route. Fortunately, this is a common issue we can address
using [PsExec](https://learn.microsoft.com/en-us/sysinternals/downloads/psexec). We need to run a PowerShell window as
the gMSA, which can be done with the following command:

```PowerShell
$ .\PSTools\PsExec.exe -u <gMSA> powershell.exe
```

Now, we have a PowerShell window that executes commands as the gMSA. Let's test our config file. You should get the
success message if everything is configured correctly. This assumes you already granted the gMSA permissions on the SQL
Server.

```PowerShell
$ cd "C:\Program Files\New Relic\newrelic-infra"; .\newrelic-infra.exe -dry_run -integration_config_path "C:\Program Files\New Relic\newrelic-infra\integrations.d\mssql-config.yml"
Integration health check finished with success
```

### Restart the New Relic Agent

Okay, this is the last thing that needs to happen. Restart the agent, and you should start seeing the data in New Relic.

```PowerShell
Restart-Service newrelic-infra
```

## Wrapping Up

I hope this helps the next person configure the New Relic agent to use a gMSA. It is the better approach when working
with Windows or MS SQL Server. Hopefully, nothing changes on the New Relic side that requires the username or password
to have a value.

Thanks for reading,

Jamie