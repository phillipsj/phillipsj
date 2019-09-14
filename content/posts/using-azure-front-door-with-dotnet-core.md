---
Title: "Using Azure Front Door with .NET Core"
date: 2019-06-30T20:42:34
Tags: 
- Azure App Service
- Azure
- Microsoft
- .NET
- Azure Front Door
- IdentityServer
---
# Using Azure Front Door with .NET Core

[Front Door](https://azure.microsoft.com/en-us/services/frontdoor/) is a new service offered by Azure that takes the concepts of an Application Gateway and combines it with the global capabilities of Traffic Manager. It is a [layer 7](https://en.wikipedia.org/wiki/OSI_model#Layer_7:_Application_Layer) service that provides load balancing, routing, and a web application firewall distributed globally. By using a load balancer instead of a Traffic Manager, you can get near-instant failover to another node instead of waiting until the DNS failover takes place. It also takes the overhead of managing an Application Gateway per region and making sure you architect it correctly to handle disaster recovery, etc. Using Front Door with basic applications, especially applications that are not communicating with other sites, it pretty much works out of the box. However, things are different when you are operating across many applications and using identity management across those applications with something like [IdentityServer](https://identityserver.io/).

## Issue

IdentityServer uses the [Host header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Host) to create the redirect URL for the redirect that happens once a user authenticates. If your ASP .NET Core application isn't configured to work behind a proxy or load balancer like Front Door, then the Host header will not match the redirect URIs, and therefore the correct redirect will not get generated. There is documentation [here](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/proxy-load-balancer?view=aspnetcore-2.2) that outlines how to configure your ASP .NET Core application behind a proxy or load balancer. The documentation can be a little confusing, especially the part about being careful with the configuration due to security. Now, this is generic documentation, so what should this look like when configuring for Front Door. I have a [GitHub repository](https://github.com/phillipsj/dotnetcore-frontdoorservice-issue) that has a README with directions that will walk you through the different configurations and the default behavior. The different stages are tagged, and those tags correlate with the various sections in the markdown.

## Explanation

ASP .NET Core usually is running on the application server called [Kestrel](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/servers/kestrel?view=aspnetcore-2.2), Kestrel isn't a web server. Since Kestrel isn't a web server, there are limitations, so it is generally a good idea to run it behind ones like Nginx or IIS. When running on Azure App Service, you will be using IIS as a proxy and to make sure that the correct hostname is getting configured by ASP .NET Core, the use of [X-Forwarded Headers](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/x-forwarded-headers.html) overcomes this limitation. These headers let ASP .NET Core know what hostname to use so that URLs and the host header are correctly set. These headers are all fine if you can trust the headers you are receiving, so from a security perspective, you need to ensure that you are getting headers from a trusted source. The ForwardedHeaders middleware in ASP .NET Core uses a decent set of defaults to ensure that you are secure. It sets the KnownProxies and KnownNetworks to what is called *LoopBack* which means that basically, it is only going to trust itself for that information. That is great when the app isn't running behind an additional load balancer or if other applications are not consuming the Host header.

The Front Door service can serve multiple domains, so it relies on setting the X-Forwarded Headers to let the backend applications know what hostname and Host header it is serving the requests. As you can guess, the default FowardedHeaders middleware settings will ignore the X-Forwarded headers being sent by Front Door because it isn't in the list of KnownProxies and KnownNetworks. So, how do we solve this issue?

## Solution

If you followed the link to the repository above you will have seen the solution, but let's dig into it. If you dig around in the documentation, the recommendation is to set the ForwardedHeader middleware like below:

```C#
# Startup.cs

services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = 
        ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto | ForwardedHeaders.XForwardedHost;
               
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();                
});
```

What we are doing in this snippet of code is telling it that we want ASP .NET Core to use all the headers we have listed above, especially the X-Forwarded-Host header. Then we clear out the KnownNetworks and KnownProxies, basically telling it to use headers from anyone. That statement should be alarming because that means that anyone can send in a Host header and we would return that hostname. This configuration will open us up to all kinds of bad mojo and MITM attacks. The obvious solution would be to find the IPs and network ranges used by Front Door, which isn't a bad approach, but remember, this is a cloud service and those things can change, even though the [docs](https://docs.microsoft.com/en-us/azure/frontdoor/front-door-faq#how-do-i-lock-down-the-access-to-my-backend-to-only-azure-front-door) say they will try not to make those changes. After a discussion on Twitter concerning this very issue, we need to consider what is happening in Front Door. Front Door [removes](https://docs.microsoft.com/en-us/azure/frontdoor/front-door-http-headers-protocol#client-to-front-door-service) the headers that we are concerned about being spoofed. According to Microsoft in this [tweet](https://twitter.com/Tratcher/status/1143204794640633857) this is okay in the context because it is a known environment, that environment would be Azure, the machines are only accessible via the service reverse proxies, and the forwarding is limited to only one hop, which means it only read the last set of headers. One additional thing is to make sure that you set AllowedHosts and limit that to the hosts that you are going to allow to send headers. AllowedHosts will provide additional security that will reduce your exposure. All of this in this post is going to be the default behavior with [ASP .NET Core 3](https://devblogs.microsoft.com/aspnet/forwarded-headers-middleware-updates-in-net-core-3-0-preview-6/). So the final solution should look like the following:

```C#
# Startup.cs

services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = 
        ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto | ForwardedHeaders.XForwardedHost;
               
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();         
    
    // Put your front door FQDN here and any other hosts that will send headers you want respected
    options.AllowedHosts = new List<string>() { "myfrontdoor.azurefd.net", "app.domain.com", "myapp.azurewebsites.net" };
});
```

## Conclusion

I hope you found this useful as this took a little tinkering to workout and to arrive at a solution specifically for Front Door. Many people helped me with understanding this issue and jumping in to assist. Thank you to all that helped me arrive at this solution. If you see any areas that are misrepresented or need clarification, please let me know.

Thanks for reading,

Jamie
