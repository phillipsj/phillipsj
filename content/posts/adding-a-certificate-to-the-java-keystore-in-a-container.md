---
title: "Adding a Certificate to the Java Keystore in a Container"
date: 2024-06-05T20:25:00-04:00
tags:
  - Containers
  - Java
---

This was a fun little bit of knowledge to learn, as I haven't worked with Java very much. I didn't have a certificate
available that was required to be available to trust the endpoint that was being called. Normally, I would add
the certificate to the host, but it seems Java requires it to be added to the keystore. I also didn't have the
certificate handy, so I needed to download the public version to add. After fully understanding the problem and a
little searching on the web, I found enough of the different pieces to get a solution.

Here is how my Dockerfile finally ended up. I use `openssl` to get the full certificate chain and output that to a file,
and then I clean up the format. Finally, I use the `keytool` to import the full certificate into the keystore.

```Dockerfile
FROM docker.io/amazoncorretto:22

RUN yum install -y openssl

RUN openssl s_client -host http.cat -port 443 -showcerts 2>&1 | \
    sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > temp.pem \
    && openssl x509 -in temp.pem -out real.pem \
    && keytool -importcert -file ./real.pem -keystore \
    "/lib/jvm/jre/lib/security/cacerts" -alias httpcat -storepass \
    changeit --noprompt \
    && rm -f real.pem temp.pem
```

After doing this, everything started working as expected.

## Wrapping Up

There may be a better way to do it, this is just what I was able to piece together by reading several different
blog posts on the topic. Adding a certificate to the keystore apparently seems common enough in my search that I figured I would write up my
solution, which I hope helps the next person and/or my future self.

Thanks for reading,

Jamie