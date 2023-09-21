---
title: "DIY Azure PIM With Kubernetes and the Azure Operator"
date: 2023-09-20T22:18:33-04:00
tags:
- Python
- Azure
- Microsoft
- Open Source
- Kubernetes
- Azure Operator
---

I have been wanting to learn the [Azure Operator](https://azure.github.io/azure-service-operator/) for about a year. I often find it difficult to spend the time to learn something unless I have a real-world problem to solve, or I just get curious. It seems that the time has finally come for me to dive into it. The problem to be solved has been something that our team has been discussing for some time. A self-service opportunity for getting temporary permissions, not just in one cloud but potentially in any cloud and Kubernetes. There is an [Azure PIM](https://learn.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure) for Azure that requires a specific licensing level, and it only works for Azure. There are similar solutions out there that can provide this type of functionality, however, as with all solutions, they come with their intricacies. We have been slowly moving to a more Kubernetes-focused workflow using tools like [ArgoCD](https://argo-cd.readthedocs.io/en/stable/), [ArgoWorkflows](https://argoproj.github.io/argo-workflows/), and [ArgoRollouts](https://argoproj.github.io/rollouts/). We also invest in many CNCF projects, as I'm sure many places do. With that, I thought that having a solution that was Kubernetes-based would be an interesting idea, so I decided to see if I could build a quick prototype using the Azure Operator and [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/).

## The Design

The initial thought would be to use the Azure Operator to create a [RoleAssignment](https://azure.github.io/azure-service-operator/reference/authorization/v1api20200801preview/#authorization.azure.com/v1api20200801preview.RoleAssignment). I would then attach an annotation or label to the RoleAssignment that set an expiration time, let's say 30 minutes. I would then create a CronJob that would run every five minutes and look for all RoleAssignment objects with the annotation or label. Then use the RoleAssignment status to get the `createdOn` property to do a little datetime math to determine if the RoleAssignment should be deleted. This is a little rough, yet enough to prove the idea. Who knows, maybe I will make an operator for it.

## Azure Operator Setup

Originally, I made notes about my installation. I have decided that I want to walk you through it, and I would encourage everyone to walk through their [YAML installation guide](https://azure.github.io/azure-service-operator/guide/installing-from-yaml/). I tried the Helm installation and I couldn't get it to work, the YAML guide worked. There are a few things that I ran across while trying to get it fully working. Installing version `v2.2.0` solved those issues, so I suggest installing that version.

Lastly, you will need to assign the Azure Operator service principal the [Role Based Access Control Administrator](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#role-based-access-control-administrator-preview) role in the subscription to which you will be assigning roles.

## Creating a RoleAssignment

After following the guide and creating a resource group, I decided I was ready to test creating a role assignment. I created a user to test with the Microsoft Entra ID. Reading through the docs, it seems that the Azure Operator requires that the RoleAssignment is owned by an Azure Resource. I created a resource group named `pim-rg`. The manifest is below:

```
apiVersion: resources.azure.com/v1api20200601
kind: ResourceGroup
metadata:
  name: pim-rg
  namespace: pim
spec:
  location: eastus
```

Once that manifest is applied to the cluster, we will need to create a RoleAssignment. I decided I would use the `Virtual Machine Contributor` role. Create the following YAML to create the `RoleAssigment` using the Azure Operator. Don't forget to add the principal ID of the user or group you want to assign the role.

```YAML
apiVersion: authorization.azure.com/v1api20200801preview
kind: RoleAssignment
metadata:
  name: user-vm-contrib
  namespace: pim
spec:
  # This resource can be owner by any resource. In this example, we've chosen a resource group for simplicity
  owner:
    name: pim-rg
    group: resources.azure.com
    kind: ResourceGroup
  # This is the Principal ID of the AAD identity to which the role will be assigned
  principalId: <insert principal id here of the user>
  roleDefinitionReference:
    # This ARM ID represents "Virtual Machine Contributor" - you can read about other built-in roles here: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
    armId: /subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c
```

Now we can apply that RoleAssignment to our cluster.

```Bash
$ kubectl apply -f role.yaml
roleassignment.authorization.azure.com/user-vm-contrib created

$ microk8s kubectl get roleassignment -n pim
NAME              READY   SEVERITY   REASON      MESSAGE
user-vm-contrib   True               Succeeded
```

Now that we have a role created, let's update it by adding a label called `role-expiration: 30m`.

```YAML
apiVersion: authorization.azure.com/v1api20200801preview
kind: RoleAssignment
metadata:
  name: user-vm-contrib
  namespace: pim
  labels:
    # This is minutes
    role-expiration: 30
spec:
  # This resource can be owner by any resource. In this example, we've chosen a resource group for simplicity
  owner:
    name: pim-rg
    group: resources.azure.com
    kind: ResourceGroup
  # This is the Principal ID of the AAD identity to which the role will be assigned
  principalId: <insert principal id here of the user>
  roleDefinitionReference:
    # This ARM ID represents "Virtual Machine Contributor" - you can read about other built-in roles here: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
    armId: /subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c
```

With all of that in place, let's create our CronJob.

## The CronJob

We are going to write this using Python. Let's create `job.py` and our `Dockerfile` in a directory called `aso-cron`.

```
$ mkdir aso-cron && cd aso-cron && touch job.py Dockerfile
```

Now let's put the following in our Dockerfile.

```Dockerfile
FROM python:3.11
RUN pip install kubernetes
WORKDIR /app
COPY . /app
CMD ["python", "job.py"]
```

In our Dockerfile we are installing the official [Kubernetes Client](https://github.com/kubernetes-client/python). Now we need to write our Python to query for our label in our namespace.

```Python
from datetime import datetime, timedelta
from kubernetes import client, config


def main():
    config.load_incluster_config()
    group = "authorization.azure.com"
    version = "v1api20200801preview"
    plural = "roleassignments"
    namespace = "pim"
    api = client.CustomObjectsApi()
    role_assignments = api.list_namespaced_custom_object(
        group,
        version,
        namespace,
        plural,
        label_selector="role-expiration",
    )

    for role_assignment in role_assignments["items"]:
        expiration = role_assignment["metadata"]["labels"]["role-expiration"]
        split = role_assignment["status"]["createdOn"].split(".")
        created = split[0]
        created_on = datetime.strptime(created, "%Y-%m-%dT%H:%M:%S")
        elapsed_time = datetime.now() - created_on
        if elapsed_time > timedelta(minutes=float(expiration)):
            api.delete_namespaced_custom_object(
                group=group,
                version=version,
                name=role_assignment["metadata"]["name"],
                namespace=namespace,
                plural=plural,
                body=client.V1DeleteOptions(),
            )
            print("Resource deleted")


if __name__ == "__main__":
    main()
```

In the above code, we are using the Kubernetes client to list all custom objects in our `pim` namespace that have the `role-expiration` label. We then loop through those getting out the value of the label, then comparing that against the created time. If the current time is outside of the created time plus the number of minutes specified in the label, the resource gets deleted. When the resource is deleted the role assignment should be removed.

Now we can create our container for our job and push it to Docker hub.

```Bash
$ docker build . -t role-expiration:v0.1.0
$ docker push role-expiration:v0.1.0 phillipsj/role-expiration:v0.1.0
```

Finally, we can create our CronJob manifest that will run every five minutes in our PIM namespace.

```YAML
apiVersion: batch/v1
kind: CronJob
metadata:
  name: role-expiration
  namespace: pim
spec:
  schedule: "* */5 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: role-expiration
            image: phillipsj/role-expiration:v0.1.0
            imagePullPolicy: IfNotPresent
          restartPolicy: OnFailure
```

## Bringing it all together

We made it, we can now create our `RoleAssignment` and then we can create our `CronJob`. After the amount of time has passed, the role assignment should be deleted. You can always decrease the expiration time if you just want to see it work. Here are some quick kubectl commands you can run.

```Bash
$ kubectl get cronjob -n pim
$ kubectl get roleassignment -n pim
$ kubectl describe roleassignment user-vm-contrib -n pim
$ kubectl describe cronjob role-expiration -n pim
```

## Wrapping Up

I thought this was a cool use of the Azure Operator and a CronJob. It opens the door for all kinds of automation driven by labels or annotations. I'm sure there are ways this can be approved and I have some ideas around that. Stay tuned for some future posts around this idea.

Thanks for reading,

Jamie
