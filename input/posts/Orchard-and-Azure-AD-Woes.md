---
Title: Orchard and Azure AD Woes!
Published: 2015-10-08 20:00:00
Tags:
- Orchard
- Azure
- Owin
- Open Source
RedirectFrom: blog/html/2015/10/08/orchard_and_azure_ad_woes.html
---

So my team and I have been using Orchard CMS to build the next version of our product. Since we have been using Azure AD for authentication for our applicaions it only made sense to wire Orchard and Azure AD together. The typical way that it is suggested to be done is to Microsoft.Owin.Security.OpenIdConnect middleware.

So we wired this up for Orchard, which was not a straight forward feat given the sparse documentation around OWIN integration. This all worked great locally and
on our dev server. We decided to finally push a versiont to Azure to work through our [Hudson Bay Start](http://www.stickyminds.com/article/hudsons-bay-start), it would be awful to be close to a deadline and find any suprises.

Well, I was hopeful as I have deployed stock Orchard to Azure several times getting a feel for how it is going to work. The calamity struck, we were ramping up to have some folks from another part of our business assist with creating content, however, I enabled our custom modules and click the signin link and BAM! I was greated with the following error:

**The data protection operation was unsuccessful. This may have been caused by not having the user profile loaded for the current thread’s user context, which may be the case when the thread is impersonating.**

```
[CryptographicException: The data protection operation was unsuccessful. This may have been caused by not having the user profile loaded for the current thread's user context, which may be the case when the thread is impersonating.]
   System.Security.Cryptography.ProtectedData.Protect(Byte[] userData, Byte[] optionalEntropy, DataProtectionScope scope) +514
   System.Security.Cryptography.DpapiDataProtector.ProviderProtect(Byte[] userData) +75
   Microsoft.Owin.Security.DataHandler.SecureDataFormat`1.Protect(TData data) +93
   Microsoft.Owin.Security.OpenIdConnect.<ApplyResponseChallengeAsync>d__c.MoveNext() +1342
   System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task) +13877064
   System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task) +61
   Microsoft.Owin.Security.Infrastructure.<ApplyResponseCoreAsync>d__b.MoveNext() +531
   System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task) +13877064
   System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task) +61
   Microsoft.Owin.Security.Infrastructure.<ApplyResponseAsync>d__8.MoveNext() +631
   System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task) +13877064
   System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task) +61
   Microsoft.Owin.Security.Infrastructure.<TeardownAsync>d__5.MoveNext() +318
   System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task) +13877064
   System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task) +61
   System.Runtime.CompilerServices.TaskAwaiter.ValidateEnd(Task task) +13877209
   Microsoft.Owin.Security.Infrastructure.<Invoke>d__0.MoveNext() +1371
   System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task) +13877064
   System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task) +61
   System.Runtime.CompilerServices.TaskAwaiter.GetResult() +28
   Microsoft.Owin.Security.Infrastructure.<Invoke>d__0.MoveNext() +1107
   System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task) +13877064
   System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task) +61
   System.Runtime.CompilerServices.TaskAwaiter.GetResult() +28
   Orchard.Mvc.Routes.<ProcessRequestAsync>d__5.MoveNext() in C:\Users\jphillips\code\ifb-blue-orchard\src\Orchard\Mvc\Routes\ShellRoute.cs:181
   System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task) +13877064
   System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task) +61
   System.Web.TaskAsyncHelper.EndTask(IAsyncResult ar) +69
   System.Web.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute() +611
   System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean& completedSynchronously) +137
```

I quickly started googling and found several suggestions. I tried several different approaches, until I pulled out [dotPeek](https://www.jetbrains.com/decompiler/) and dug a little through
_Microsoft.Owin.Security_ and noticed that I needed a different IDataProtectionProvider that doesn’t use DPAPI. I finally got to a [this](http://stackoverflow.com/questions/23455579/generating-reset-password-token-does-not-work-in-azure-website) on StackOverflow.  The suggestion there was to implement the following:

```
public class MachineKeyProtectionProvider : IDataProtectionProvider
{
    public IDataProtector Create(params string[] purposes)
    {
        return new MachineKeyDataProtector(purposes);
    }
}

public class MachineKeyDataProtector : IDataProtector
{
    private readonly string[] _purposes;

    public MachineKeyDataProtector(string[] purposes)
    {
        _purposes = purposes;
    }

    public byte[] Protect(byte[] userData)
    {
        return MachineKey.Protect(userData, _purposes);
    }

    public byte[] Unprotect(byte[] protectedData)
    {
        return MachineKey.Unprotect(protectedData, _purposes);
    }
}
```

Now that I had this implementation, I tried several of the other posts on StackOverflow trying to use Autofac to inject the dependency in, however it was working.

Again, I turned to dotPeek and was taking a look at what was going on with this method:

```
app.GetDataProtectionProvider()
```

While looking at the method, I noticed this other extension method.:

```
app.SetDataProtectionProvider(IDataProtectionProvider provider)
```

So I added the following to my OwinMiddleware class in my Orchard Module and **IT WORKED!**

```

```
public class OwinMiddlewares : IOwinMiddlewareProvider {
        public ILogger Logger { get; set; }

        public OwinMiddlewares() {
            Logger = NullLogger.Instance;
        }

        public IEnumerable<OwinMiddlewareRegistration> GetOwinMiddlewares() { 
            var middlewares = new List<OwinMiddlewareRegistration>();
            middlewares.Add(new OwinMiddlewareRegistration
            {
                Priority = "9",
                Configure = app => {
                    app.SetDataProtectionProvider(new MachineKeyProtectionProvider());
                }
            });
            return middlewares;
        }
}
```

This has been a two day issue that we have beent trying to determine what the cause. I will be able to sleep soundly tonight.

Hope someone else finds this helpful.