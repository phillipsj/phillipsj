---
Title: "Using Azure Front Door with IdentityServer"
date: 2019-07-02T06:51:11
Tags: 
- Azure App Service
- Azure
- Microsoft
- .NET
- Azure Front Door
- IdentityServer
---
# Using Azure Front Door with IdentityServer

In my [previous post](https://www.phillipsj.net/posts/using-azure-front-door-with-dotnet-core), I covered some of the changes you need to make to an ASP .NET Core application for all the X-Forwarded headers to be consumed correctly. In this post, we are going to discuss what needs to happen, so [IdentityServer](https://identityserver.io/) works correctly behind Azure Front Door.

## The Problem

When IdentityServer is running behind a load balancer or proxy the Discovery endpoint doesn't return the correct URIs. The reason for this is because the hostname of the App Service or server that is running IdentityServer isn't reporting the correct hostname received from the load balancer or proxy. You could easily use my last post and configure the ForwardedHeaders middleware, but that has security implications, and we are discussing IdentityServer. Fortunately, IdentityServer does provide a solution that allows you to configure the hostname to be a value that you set using the [PublicOrigin](http://docs.identityserver.io/en/latest/reference/options.html#identityserver-options) property in the IdentityServerOptions, thus ignoring the real hostname. Since IdentityServer is not communicating in a way that this would cause an issue, it makes it a natural solution that avoids the potential security issues that may arise from the ForwardedHeaders configuration.

Let's look at an example to demonstrate the issue. We have IdentityServer behind an Azure Front Door with the domain, **identity.mydomain.com**. The Azure App Service is named, **myapp.azurewebsites.net**. So the default hostname will be *myapp.azurewebsites.net*. So if we navigate to the Discovery endpoint, which is **https://identity.mydomain.com/.well-known/openid-configuration**, we will see the following abbreviated JSON.

```JSON
{
  "issuer": "https://myapp.azurewebsites.net",
  "jwks_uri": "https://myapp.azurewebsites.net/.well-known/openid-configuration/jwks",
  "authorization_endpoint": "https://myapp.azurewebsites.net/connect/authorize",
  "token_endpoint": "https://myapp.azurewebsites.net/connect/token",
  "userinfo_endpoint": "https://myapp.azurewebsites.net/connect/userinfo",
  "end_session_endpoint": "https://myapp.azurewebsites.net/connect/endsession",
  "check_session_iframe": "https://myapp.azurewebsites.net/connect/checksession",
  "revocation_endpoint": "https://myapp.azurewebsites.net/connect/revocation",
  "introspection_endpoint": "https://myapp.azurewebsites.net/connect/introspect",
  "frontchannel_logout_supported": true,
  "frontchannel_logout_session_supported": true,
  "backchannel_logout_supported": true,
  "backchannel_logout_session_supported": true,
}
```

As you can see the domain in that Discovery endpoint isn't matching the domain in the URL above. By setting the PublicOrigin to **identity.mydomain.com** the Discovery endpoint will return the correct domain in the JSON.

## How to configure Public Origin

Currently, there isn't an option that reads from settings.json, so we will need to do a little work to make this a configurable item that can be changed easily with configuration.

First, we need to add the configuration to our settings.json.

```JSON
{
    "IdentityServer": {
        "PublicOrigin": "identity.mydomain.com"
    }
}
```

Now we need to make sure that we load the settings into the IdentityServerOptions class in our *ConfigureServices* method of Startup.cs.

```C#
public class Startup {
    # Abbreviated for this example
    public void ConfigureServices(IServiceCollection services){
        var identityServerOptions = Configuration.GetSection("IdentityServer");
    }
}
```

Now we need to set our IdentityServerOptions that includes the PublicOrigin property already set.

```C#
public class Startup {
    # Abbreviated for this example
    public void ConfigureServices(IServiceCollection services){
        var identityServerOptions = Configuration.GetSection("IdentityServer");
        services.AddIdentityServer(identityServerOptions);
    }
}
```

If the *identityServerOptions* is null, the options have no impact, and execution occurs as if no arguments existed. With the Public Origing being configured to respond correctly when behind a load balancer or proxy like Front Door, you will now get the following JSON returned from **https://identity.mydomain.com/.well-known/openid-configuration**.

```JSON
{
  "issuer": "https://identity.mydomain.com",
  "jwks_uri": "https://identity.mydomain.com/.well-known/openid-configuration/jwks",
  "authorization_endpoint": "https://identity.mydomain.com/connect/authorize",
  "token_endpoint": "https://identity.mydomain.com/connect/token",
  "userinfo_endpoint": "https://identity.mydomain.com/connect/userinfo",
  "end_session_endpoint": "https://identity.mydomain.com/connect/endsession",
  "check_session_iframe": "https://identity.mydomain.com/connect/checksession",
  "revocation_endpoint": "https://identity.mydomain.com/connect/revocation",
  "introspection_endpoint": "https://identity.mydomain.com/connect/introspect",
  "frontchannel_logout_supported": true,
  "frontchannel_logout_session_supported": true,
  "backchannel_logout_supported": true,
  "backchannel_logout_session_supported": true,
}
```

This JSON now has the correct hostname, solving the issue of the incorrect hostname.

I hope this helps someone with this issue, and as always, please reach out if you have any questions or feedback.

Thanks for reading,

Jamie
