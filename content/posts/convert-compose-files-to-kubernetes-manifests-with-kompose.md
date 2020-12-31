---
title: "Convert Compose Files to Kubernetes Manifests With Kompose"
date: 2020-12-31T12:54:14-05:00
tags:
- Open Source
- Linux
- Docker
- DevOps
- Kubernetes
---

A few posts back, I discussed creating a [compose](https://www.phillipsj.net/posts/self-hosted-rss-using-miniflux/) file for Miniflux. I will deploy Miniflux to Kubernetes, and I could convert this to a Kubernetes manifest by hand. However, it's been a while since I have given [Kompose](https://kompose.io/) a spin in a year or so. I decided this would be an excellent time to give it a try again. Let's get it installed so we can convert that Docker compose file.

```Bash
$ curl -L https://github.com/kubernetes/kompose/releases/download/v1.22.0/kompose-linux-amd64 -o kompose
$ chmod +x kompose && mv ./kompose ~/.local/bin/kompose
renamed 'kompose' -> '/home/phillipsj/.local/bin/kompose'
```

Now that we have it installed, we can navigate to the same directory with our Docker-compose file and execute.

```Bash
$ ls
docker-compose.yml

$ kompose convert --out miniflux.yaml
```

It ran without error. Let's see what it generated.

```YAML
apiVersion: v1
items:
  - apiVersion: v1
    kind: Service
    metadata:
      annotations:
        kompose.cmd: kompose convert --out miniflux.yaml
        kompose.version: 1.22.0 (955b78124)
      creationTimestamp: null
      labels:
        io.kompose.service: web
      name: web
    spec:
      ports:
        - name: "80"
          port: 80
          targetPort: 8080
      selector:
        io.kompose.service: web
    status:
      loadBalancer: {}
  - apiVersion: apps/v1
    kind: Deployment
    metadata:
      annotations:
        kompose.cmd: kompose convert --out miniflux.yaml
        kompose.version: 1.22.0 (955b78124)
      creationTimestamp: null
      labels:
        io.kompose.service: db
      name: db
    spec:
      replicas: 1
      selector:
        matchLabels:
          io.kompose.service: db
      strategy: {}
      template:
        metadata:
          annotations:
            kompose.cmd: kompose convert --out miniflux.yaml
            kompose.version: 1.22.0 (955b78124)
          creationTimestamp: null
          labels:
            io.kompose.service: db
        spec:
          containers:
            - env:
                - name: POSTGRES_DB
                  value: miniflux
                - name: POSTGRES_PASSWORD
                  value: m1n1f7ux
                - name: POSTGRES_USER
                  value: miniflux
              image: postgres:13-alpine
              name: db
              resources: {}
          restartPolicy: Always
    status: {}
  - apiVersion: apps/v1
    kind: Deployment
    metadata:
      annotations:
        kompose.cmd: kompose convert --out miniflux.yaml
        kompose.version: 1.22.0 (955b78124)
      creationTimestamp: null
      labels:
        io.kompose.service: web
      name: web
    spec:
      replicas: 1
      selector:
        matchLabels:
          io.kompose.service: web
      strategy: {}
      template:
        metadata:
          annotations:
            kompose.cmd: kompose convert --out miniflux.yaml
            kompose.version: 1.22.0 (955b78124)
          creationTimestamp: null
          labels:
            io.kompose.service: web
        spec:
          containers:
            - env:
                - name: ADMIN_PASSWORD
                  value: m1n1f7ux
                - name: ADMIN_USERNAME
                  value: miniflux
                - name: CREATE_ADMIN
                  value: "1"
                - name: DATABASE_URL
                  value: postgres://miniflux:m1n1f7ux@db/miniflux?sslmode=disable
                - name: RUN_MIGRATIONS
                  value: "1"
              image: miniflux/miniflux:2.0.26
              name: web
              ports:
                - containerPort: 8080
              resources: {}
          restartPolicy: Always
    status: {}
kind: List
metadata: {}
```

This output isn't too bad, and we need to add our ingress to it. Add this to the list of items at the top.

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: miniflux-ingress
spec:
  rules:
  - http:
      paths:
      - path: /miniflux
        backend:
          serviceName: web
          servicePort: 80
```

We can do a deployment to our kind cluster after that change. If you want to learn about setting up kind, check out this [post](https://www.phillipsj.net/posts/opensuse-kubernetes-dev-with-kind/). I have my ingress setup on port 6000, and your's may be different depending on how you configured kind.

```Bash
$ kubectl apply -f miniflux.yaml 
ingress.networking.k8s.io/miniflux-ingress created
service/web created
deployment.apps/db created
deployment.apps/web created
```

Let's see if our pods have started up.

```Bash
$ kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
db-6f74fb8d8d-8bv9v    1/1     Running   0          56s
web-648795fc64-4h8rv   1/1     Running   3          56s
```

Notice that the web pod has restarted three times, and that is because it had to restart while waiting on the database pod to become available. These restarts are expected and working as we want. Let's see if we can connect.

```Bash
$ curl http://localhost:6000/miniflux 
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Sign In - Miniflux</title>
.......Omitted........
```

Yep, it's up and running as we had hoped. Hopefully, you found this quick introduction to Kompose useful and exciting. It has improved since I last used it and I still don't 100% like the output because of all the Kompose annotations in the output. It may be useful for some, just not something that I like.

Thanks for reading,

Jamie
