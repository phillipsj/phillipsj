---
title: "Setting Up Windows GMSA for Kubernetes"
date: 2022-02-13T12:32:37-05:00
tags:
- Active Directory
- Kubernetes
- Windows
- Windows GMSA
- Rancher
- Windows on Kubernetes
- RKE2
- RKE2 on Windows
---

Windows Active Directory provides a feature called [Group Managed Service Accounts](https://docs.microsoft.com/en-us/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview) which allows automatic password management for accounts that can be used by applications and other places where you don't want to use a regular account. You can think of these like service principles in Azure or IAM roles in AWS. This setup can be tricky as it requires that you are using an Active Directory that supports GMSA and that you have it configured correctly. I highly recommend reading the [Getting Started with Group Managed Service Accounts](https://docs.microsoft.com/en-us/windows-server/security/group-managed-service-accounts/getting-started-with-group-managed-service-accounts) page before proceeding. Actually, I would say read it a few times. Here is a high-level overview of what is required.

* Active Directory 2012 or newer, including your schema
* A KDS Root Key configured
* A Domain Joined Windows Kubernetes Node
* Windows GMSA CRD installed your Cluster
* Admission Webhook installed in your Cluster
* Working DNS for your AD, K8s, and Nodes

That is a big list and some of these I am not going to cover in-depth as I won't be able to do them justice. What I will cover is at a high level what needs to happen.

## Prerequisites

I did all of this in my home lab with virtual machines. I configured a Windows Server 2019 and installed Active Directory. I then just followed the configuration wizard, setting my domain to `gmsa.home.arpa`.

After that, I set up an RKE2 cluster using Rancher with one Linux control plane node, one Linux worker node, and one Windows Server 2019 worker node. I joined that Windows Server 2019 worker node to my domain. I also configured a group policy that turned off Windows Firewall for all machines in my domain, you can easily just do this manually.

## Setting up your KDS Root Key in your Active Directory

Check your KDS Root key. This is a good [post](https://timwappat.info/post/2018/09/15/Remove-or-delete-KDSRootKey-(KDS-Root-Key)) about it.

```PowerShell
Get-KdsRootKey
```

If you don't have one you can add a KDS Root Key by doing the following, this is only to be used in testing environments.

```PowerShell
Add-KdsRootKey -EffectiveTime (Get-Date).AddHours(-10)
```

## Joining your Windows Nodes to your Active Directory

Once your KDS root has been confirmed, you can join your Windows worker node to your domain. Log into the Windows worker and start PowerShell as an admin.

```PowerShell
Add-Computer –DomainName gmsa.home.arpa -Credential <ad admin account> -Restart –Rorce
```

Follow the prompts to enter the credentials and to restart. Once it restarts you should be able to log into the worker node with a domain account.

## Installing AD Tools

Here is an overview of the steps that are required and you will need the AD module installed.

* To install the AD module on Windows Server
* To install the AD module on Windows 10 version 1809 or later
* To install the AD module on older versions of Windows 10, see https://aka.ms/rsat

#### Install AD  module Windows Server

```
Install-WindowsFeature RSAT-AD-PowerShell
```

#### Install AD module Windows 10

```
Add-WindowsCapability -Online -Name 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0'
```

## Creating GMSA Account, Security Group, and adding Windows nodes.

Now we can start the GMSA setup by creating our security group, GMSA account, and adding the Windows worker node as a member to our security group. We will need to gather the following information before we start.

* Domain name
* Security Group name
* GMSA Account name
* Windows worker node name

Mine are the following:

* Domain: gmsa.home.arpa
* Security Group: K8sHosts
* GMSA: K8s
* Node: k8swin


Create the security group:

```PowerShell
New-ADGroup -Name "K8s Authorized Hosts" -SamAccountName "K8sHosts" -GroupScope DomainLocal
```

Create the GMSA:

```PowerShell
New-ADServiceAccount -Name "K8s" -DnsHostName "gmsa.home.arpa" -ServicePrincipalNames "host/K8s", "host/gmsa.home.arpa" -PrincipalsAllowedToRetrieveManagedPassword "K8sHosts"
```

Add the Windows worker node to the security group:

```PowerShell
Add-ADGroupMember -Identity "K8sHosts" -Members "k8swin$"
```

Now let's confirm that your worker node can access the GMSA. It should return `True` if everything is configured correctly.

```PowerShell
Test-ADServiceAccount K8s
```

That's it, of course, your domain, groups, and nodes may have different names from mine. Ensure that you have all of that information collected upfront that is listed above. The last step in this section is to gather the GMSA information that you will need to create the GMSA Credential in the next step. I suggest running this on the Windows node as an additional test. Save this information.

```PowerShell
$Get-ADServiceAccount K8s -Server gmsa.home.arpa


DistinguishedName : CN=K8s,CN=Managed Service Accounts,DC=gmsa,DC=home,DC=arpa
Enabled           : True
Name              : K8s
ObjectClass       : msDS-GroupManagedServiceAccount
ObjectGUID        : ea256797-1d80-4df4-9c5a-8e07d2bf83ce
SamAccountName    : K8s
SID               : S-1-5-21-877424436-229169235-27940185-1110
UserPrincipalName :
```

## Install GMSA in your cluster

There is documentation located [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-gmsa/) on how to install GMSA into your cluster. This requires installing the GMSA Credential CRD, the admission webhook, and creating a certificate. There is a script [here](https://github.com/kubernetes-sigs/windows-gmsa/blob/master/admission-webhook/deploy/deploy-gmsa-webhook.sh) to make that easier. I have a PR open for adding a GMSA chart to the [Windows GMSA](https://github.com/kubernetes-sigs/windows-gmsa) chart [here](https://github.com/kubernetes-sigs/windows-gmsa/pull/55). Rancher will soon have a GMSA chart included, currently experimental, that will show up in the Apps & Marketplace. Both charts support using [Cert-Manager](https://cert-manager.io/) for generating your certificate if you have it installed in your cluster. If you install using the script you will need to create your GMSA by hand, if you use the chart, you can create it as part of the deployment. The information in the previous step contains most of the information you need. Here is an example of the GMSA Credential

```YAML
apiVersion: windows.k8s.io/v1
kind: GMSACredentialSpec
metadata:
  name: gmsa-k8s  #This is an arbitrary name but it will be used as a reference
credspec:
  ActiveDirectoryConfig:
    GroupManagedServiceAccounts:
    - Name: K8s   #Username of the GMSA account
      Scope: GMSA  #NETBIOS Domain Name
    - Name: K8s   #Username of the GMSA account
      Scope: gmsa.home.arpa #DNS Domain Name
  CmsPlugins:
  - ActiveDirectory
  DomainJoinConfig:
    DnsName: gmsa.home.arpa  #DNS Domain Name
    DnsTreeName: gmsa.home.arpa #DNS Domain Name Root
    Guid: ea256797-1d80-4df4-9c5a-8e07d2bf83ce  #GUID
    MachineAccountName: K8s #Username of the GMSA account
    NetBiosName: GMSA  #NETBIOS Domain Name
    Sid: S-1-5-21-877424436-229169235-27940185-1110 #SID of GMSA
```

We can now deploy a workload to test that it works.

## Test Workload

This is a workload to test the GMSA Credential that you created. Notice the `securityContext` with `windowsOptions`.

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: with-gmsa-creds
  name: with-gmsa-creds
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      run: with-gmsa-creds
  template:
    metadata:
      labels:
        run: with-gmsa-creds
    spec:
      serviceAccount: windows-gmsa
      securityContext:
        windowsOptions:
          gmsaCredentialSpecName: k8s
      containers:
      - image: mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019
        imagePullPolicy: Always
        name: iis
      nodeSelector:
        kubernetes.io/os: windows
```

Now we can exec into our pod and test that it is joined to the domain with our GMSA.

```Bash
$ kubectl exec -it <pod-name> powershell.exe -Command "nltest.exe /parentdomain"
```

This should return success and show the correct domain info.

## Troubleshooting

Here is a link to Microsoft's troubleshooting [guide](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/gmsa-troubleshooting).

## Wrapping Up

This is a relatively short post for a very complex setup. My advice would be to take your time, do each step at a time and ensure that it step is working correctly before proceeding to the next. There are lots of places that can cause issues. If you find that it isn't working once you reach the end, I would suggest going all the way back to the first step and re-validating each one and you should be able to work out your issue. Connectivity is also another of those topics that I didn't mention. Ensuring that all of your nodes have connectivity and that your Windows worker can connect correctly to your Active Directory server is a good item to check off your list. If you run into any issues, reach out and I may be able to help.

Thanks for reading,

Jamie
