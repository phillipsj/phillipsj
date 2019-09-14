---
Title: "AWS EKS and Kubernetes External DNS"
date: 2018-06-08T20:46:32
Tags: 
- Kubernetes
- AWS
- EKS
- Route53
---
# AWS EKS and Kubernetes External DNS

I have been using the [Kubernetes External DNS](https://github.com/kubernetes-incubator/external-dns) addon lately when building out my clsuters. It provides a nice way to get a friendly external DNS entry for your exposed services. The installation walks you through using it with [KOPS](https://github.com/kubernetes/kops). Now that [EKS](https://aws.amazon.com/eks/) is GA, here is what is required to get it working correctly.

The first step is to create a policy that can be attached to the IAM Role that gets created for your EKS nodes.

Here is the policy:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:ListResourceRecordSets"
            ],
            "Resource": ["*"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": ["*"]
        }
    ]
}

``` 
Note that I am not restricting based on resources. I would encourage you to consider your needs here, but this should get your started.

If you are using Terraform, then here is how to create the policy with it:

```
resource "aws_iam_policy" "external-dns-policy" {
    name = "K8sExternalDNSPolicy"
    path = "/"
    description = "Allows EKS nodes to modify Route53 to support ExternalDNS."

    policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "route53:ListHostedZones",
                    "route53:ListResourceRecordSets"
                ],
                "Resource": ["*"]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "route53:ChangeResourceRecordSets"
                ],
                "Resource": ["*"]
            }
        ]
    }
    EOF
}

```  

Now that has been setup, I would execute your yaml for installing the External DNS bits.

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: external-dns
rules:
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get","watch","list"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","watch","list"]
- apiGroups: ["extensions"] 
  resources: ["ingresses"] 
  verbs: ["get","watch","list"]
---
apiVersion: rbac.authorization.k8s.io/v
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: external-dns
subjects:
- kind: ServiceAccount
  name: external-dns
  namespace: default
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: external-dns
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      serviceAccountName: external-dns
      containers:
      - name: external-dns
        image: registry.opensource.zalan.do/teapot/external-dns:v0.5.2
        args:
        - --source=service
        - --source=ingress
        - --domain-filter=my-domain.com # will make ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones
        - --provider=aws
        - --policy=upsert-only # would prevent ExternalDNS from deleting any records, omit to enable full synchronization
        - --aws-zone-type=public # only look at public hosted zones (valid values are public, private or no value for both)
        - --registry=txt
        - --txt-owner-id=my-identifier
```

Now you can try deploying a test service that will use the external dns.

```
apiVersion: v1
kind: Service
metadata:
  name: nginx
  annotations:
    external-dns.alpha.kubernetes.io/hostname: nginx.my-domain.com.
spec:
  type: LoadBalancer
  ports:
  - port: 80
    name: http
    targetPort: 80
  selector:
    app: nginx

---

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx
spec:
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        ports:
        - containerPort: 80
          name: http
```

This is a real quick post on how to wire it all up with EKS. You should definately checkout the *External DNS* project if you are looking for a solution that creates external dns entries based on your exposed services.
