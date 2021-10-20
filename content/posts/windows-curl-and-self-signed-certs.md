---
title: "Windows, curl, and Self-signed Certs"
date: 2021-10-19T21:11:35-04:00
tags:
- Windows
- curl
- SSL
- Self-signed Certs
---

Today was an exciting day that had some twists and turns. Given that many of the searches didn't return good information, I decided to create a post. Let me set the stage for the issue I was working on.

## Background

Today, I was working on a script using PowerShell. The original script was written in Bash, and we needed the same script with feature parity for Windows. We decided a while back that we would try to make full use [curl](https://curl.se) to keep with that parity and because it is an excellent way for downloading files compared to what ships with PowerShell. However, that is where the issue creeps up. Part of the process that I was working on checked to see if a self-signed cert was used. If so, then download it. Once that cert is downloaded, we use the `--cacert` flag with our curl commands to validate our requests. 

## The Issue

Here is what that command looks like that is being executed.

```Bash
$ curl --cacert <path to cert file> -fL https://<ip>/healthz
```

We could leverage the `--insecure` flag to bypass the check, but that isn't desirable for our use case. The command above works just as expected on Linux. Once on Windows, this happens.

```Bash
$ curl --cacert <path to cert file> -fL https://<ip>/healthz
curl: (77) schannel: next InitializeSecurityContext failed: SEC_E_UNTRUSTED_ROOT (0x80090325) - The certificate chain was issued by an authority that is not trusted.
```

We received an error that it isn't a trusted cert. This is what would happen even if we didn't pass the `--cacert` flag. The conclusion that I came to is that Windows wasn't using the cert at all. I tried pointing to the directory containing the cert using the `--capath` flag, the environment variables listed on the site, and even renaming the cert and placing it on the PATH. None of those methods worked. I then checked *Invoke-RestMethod* with passing in the certificate to see if that would work.

```PowerShell
$cert = Get-PfxCertificate <path to cert file>
Invoke-RestMethod https://<ip>/healthz -Certificate $cert
```

That command fails too, and from the error that came back, it seemed that something about how Windows handles the certs causes an issue.

## The Solution

After a bit of experimentation and digging around, I finally figured out a combination that actually worked. It's a multifaceted solution, so we will start at the basics. I first wanted to get this working with PowerShell. After that, getting it to work with curl would be easier, in my opinion. My research led me to the fact that I would need to load the self-signed cert into the local machine *Root* certificate store. I was able to achieve that with the following PowerShell snippet.

```PowerShell
Import-Certificate -FilePath <path to cert file> -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
```

Once that was imported into the local machine *Root* store, I tried executing the *Invoke-RestMethod* again, this time with the `-Certificate` flag.

```PowerShell
Invoke-RestMethod https://<ip>/healthz 
```

Do you know what happened? It just worked without an issue. So now PowerShell was detecting the cert and not throwing an error because it is self-signed. Now it was time to test curl. I shouldn't have to specify the cert now with curl either.

```Bash
$ curl -fL https://<ip>/healthz
curl: (35) schannel: next InitializeSecurityContext failed: Unknown error (0x80092012) - The revocation function was unable to check revocation for the certificate.
```

Darn it, another error. This time it's an error that I can't seem to replicate with PowerShell, so now it was something narrowed down to curl. After a quick check of the curl [manpage](https://curl.se/docs/manpage.html), I discovered the `--SSL-no-revoke` flag, which is Windows only. This tells curl to not check the CA for a revocation list. Since this is self-signed and we are not hosting our CA, we will need to inform curl to not make this check. Here is what the full command looks like that works.

```Bash
$ curl --ssl-no-revoke -fL https://<ip>/healthz
```

That's it. We needed to add the self-signed cert to the local machine *Root* store and disable the curl revocation check. 

## Wrapping Up

Now you may be asking about just skipping the certificate check, which we could do. However, since we have a copy of the certificate, it is ideal to leverage that to make sure that we are as secure as we can possibly be using self-signed certs. Ignoring the revocation isn't the optimal solution, yet enabling that functionality would push us to host our own certificate authority and publish a revocation list. At that point, I think most people wouldn't be leveraging self-signed certificates or would already have a certificate authority. 

I hope this helps others put the pieces together to get this to work.

Thanks for reading,

Jamie
