---
Title: "Azure ARM Template Tips"
date: 2018-12-06T21:03:12
Tags: 
- Open Source
- Azure
- Microsoft
- ARM Template
---
# Azure ARM Template Tips

I have had a couple of fun days learning about Azure ARM templates. I learned Terraform without really giving ARM templates a chance and I can say without a doubt it was a solid decision. ARM templates have started growing on me what little I have had to do. Here are some of the items that I have learned about ARM templates that have been important for me to know.

## Resource Groups and Subscriptions

Azure ARM templates work under the assumption that you will always be deploying resources to a single resource group. If you are doing a high-availability configuration that spans multiple regions this makes putting all your infrastructure in a single template to deploy as a unit an issue. Here is a list of things that you need to know.

* Only five resource groups can be used in a single deployment.
* If a resource group or subscription isn't specified then the values for the parent template are used.
* The account being used for the deployment needs to have permissions to that subscription.
* Subscription doesn't need to be supplied if you are not deploying across subscriptions.

If you need to specify different subscriptions or resource groups then you will need to use the *Microsoft.Resources/deployments* type and add the *resourceGroup* and *subscriptionId* properties. You can read more [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-cross-resource-group-deployment).

## resourceId Function

The [resourceId](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-resource#resourceid) has a lot more functionality that you typically see. 

Look at this example:

```JSON
{
          "apiVersion": "2015-01-01",
          "type": "providers/links",
          "name": "Microsoft.Resources/SiteToHub",
          "dependsOn": [
            "[variables('uniqueAppName')]",
            "[variables('notificationHubName')]"
          ],
          "properties": {
            "targetId": "[resourceId('Microsoft.NotificationHubs/namespaces/NotificationHubs', variables('notificationHubNamespace'), variables('notificationHubName'))]"
}
```

If you look at *targetId* you will see **resourceId** being used. Notice there are three parts defined that, those are the *resourceType*, *resourceName1*, and *resourceName2*. This is what you will typically see in most examples which can be a little deceiving because there are two optional parameters at the start of the signature. Those two optional parts are you guessed it, **subscriptionId** and **resourceGroupName**.  

Here is the full signature:

```
resourceId([subscriptionId], [resourceGroupName], resourceType, resourceName1, [resourceName2]...)
```

Since those two items are optional it is good to register that these two default to the parent template values. I found this out the hard way because I was referencing a resource in a different resource group. Once I added the optional resource group name my issue disappeared. The issue was manifesting as a *NotFound* error saying that my resources could not be found in the resource group regardless of the fact that it did. It knew what it needed, but couldn't get past the first item listed above.

## Incorrect Segment Lengths

Now this one is a doozy and probably the one I have found the most confusing. There exist two rigid rules when defining types and names for resources in ARM templates. Here is the [link](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-invalid-template-errors#solution-2---incorrect-segment-lengths) to the official documentation if you want to read it. I have condensed it.

The rules as follows:

* A root level resource must have one less segment in the name than the resource type.
* Child resources must have the same number of segments.

Now the child resource one is interesting and if you read the documentation you will see that it says that once you add the parent and child types and names together it still makes one less. I know, I was thinking the same thing. Now it is time for some examples. I am using the [101-sql-with-failover-group](https://github.com/Azure/azure-quickstart-templates/blob/master/101-sql-with-failover-group/azuredeploy.json) template in the Azure Quickstart Templates as my example.

### Root Level Naming

```JSON
{
    "type" : "Microsfot.SqlServer/servers",
    "name" : "mySqlServer"
}
```

As you can see that is one less segment than in the type. If you were to concat both of those together you get what looks like a resource id.

```
Microsoft.SqlServer/servers/mySqlServer
```

Now take the subscription id, resource group name, and that segment and you can pretty much build the URI for the REST API. So now we can start to see what is happening.

### Child Resources

Recall that a child resource must only have one segment and one type. Let's see this in practice.

```JSON
"resources": [
    {
      "type": "Microsoft.Sql/servers",
      "name": "mySqlServer",
      "resources": [
        {
          "type": "failoverGroups",
          "name": "myFailoverGroup"
        }
      ]
    }
]
```

So not much different than above, still one more segment in the type once you add them together than in the names. It will generate something like this:

```
Microsoft.SqlServer/servers/mySqlServer/failoverGroups/myFailoverGroup
```

Now here is the key piece of information that I found extremely difficult. If you want to use any kind of [interation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-multiple) in your ARM templates you cannot use that functionality in a child resource, **only a parent resource**. This is extremely important to understand because in the context of a failover group, we are going to want to add multiple servers to the group. To achieve this we will need to move the failOverGroup up to the parent level.

Here is what that would look like.

```JSON
"resources": [
    {
        "type": "Microsoft.Sql/servers/failoverGroups",
        "name": "myFailoverGroup"
    }
]
```

Now if you were to run this it would error immediately. The type is correct, however, the name has two fewer segments than the type. What do we do? What needs to happen to make it work? This is where you get the Invalid Template error and pull out what little hair you have left. Well as it turns out you just have to you just need to add the **SqlServer Name** that the fail-over group will be associated with. So here it is after the change.

```JSON
"resources": [
    {
        "type": "Microsoft.Sql/servers/failoverGroups",
        "name": "[concat('mySqlServer', '/', 'myFailoverGroup')]"
    }
]
```

Now we have a two segment name with our three segment type which meets our rule of one less. My limited understanding tells me that this done this way so that the full URI of the REST API can be built and knowing that the first part of the name is the sqlServer fills in that blank that can't be resolved because we no longer has the fail-over group nested.

## Property Iteration

This one was a little confusing, but not that bad. [Property Intereation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-multiple#property-iteration) is when you need to add multiple items to a property dynamically. The example I am going to use is going to be adding your secondary servers to a failover group. Again, I am referencing the [template](https://github.com/Azure/azure-quickstart-templates/blob/master/101-sql-with-failover-group/azuredeploy.json) from before.

We are going to start with this slimmed down section.

```JSON
"resources": [
    {
      "type": "Microsoft.Sql/servers",
      "name": "[parameters('sqlServerPrimaryName')]",
      "resources": [
        {
          "type": "failoverGroups",
          "name": "[parameters('sqlFailoverGroupName')]",
          "properties": {
            "partnerServers": [
              {
                "id": "[resourceId('Microsoft.Sql/servers/', parameters('sqlServerSecondaryName'))]"
              }
            ]
          }
        }
      ]
    }
]
```

Now let's go ahead and add our variable for our array to make it easier to follow.

```JSON
"variables": {
    "secondaryServers" : ["mySecondary1", "mySecondary2"]
},
"resources": [
    {
      "type": "Microsoft.Sql/servers",
      "name": "[parameters('sqlServerPrimaryName')]",
      "resources": [
        {
          "type": "failoverGroups",
          "name": "[parameters('sqlFailoverGroupName')]",
          "properties": {
            "partnerServers": [
              {
                "id": "[resourceId('Microsoft.Sql/servers/', parameters('sqlServerSecondaryName'))]"
              }
            ]
          }
        }
      ]
    }
]
```

Now that we have our array, we need to implement our iteration over the **partnerServers** to add the ID of all our secondary servers. Now remember that we can't iterate over a child resource, so we need to refactor to put the fail-over group at the root level.

```JSON
"variables": {
    "secondaryServers" : ["mySecondary1", "mySecondary2"]
},
"resources": [
        {
          "type": "Microsoft.Sql/servers/failoverGroups",
          "name": "[concat(parameters('sqlServerPrimaryName'), '/', parameters('sqlFailoverGroupName'))]",
          "properties": {
            "partnerServers": [
              {
                "id": "[resourceId('Microsoft.Sql/servers/', parameters('sqlServerSecondaryName'))]"
              }
            ]
          }
        }
      ]
```

Now that we are at the root level, let's understand what the result we want. We want the following JSON inserted into our **partnerServers** array above.

```JSON
[
    {
        "id": "[resourceId('Microsoft.Sql/servers/', 'mySecondary1')]"
    },
    {
        "id": "[resourceId('Microsoft.Sql/servers/', 'mySecondary2')]"
    }
]
```

So let's start by refactoring and adding in our copy. **copy** will replace the *partnerServers* section and will need to have the *name*, *count*, and *input* properties.

```JSON
"variables": {
    "secondaryServers" : ["mySecondary1", "mySecondary2"]
},
"resources": [
        {
          "type": "Microsoft.Sql/servers/failoverGroups",
          "name": "[concat(parameters('sqlServerPrimaryName'), '/', parameters('sqlFailoverGroupName'))]",
          "properties": {
              "copy": [{
                "name": "",
                "count": "",
                "input": {}
            }]
          }
        }
      ]
```

Now that we have the *copy* in place we are going to zoom in our focus on it.

```JSON
"copy": [
    {
        "name": "",
        "count": "",
        "input": {}
    }
]
```

The *name* property needs to be the name of the property that we want this data to be, in this case, it is *partnerServers*.

```JSON
"copy": [
    {
        "name": "partnerServers",
        "count": "",
        "input": {}
    }
]
```

We want *count* to be based on the length of our variable *secondaryServers*.

```JSON
"copy": [
    {
        "name": "partnerServers",
        "count": "[length(variables('secondaryServers')]",
        "input": {}
    }
]
```

Now our *input* needs to be the property that we want to set inside the *partnerServers* property. We know this is the ID of the secondary server.

```JSON
"copy": [
    {
        "name": "partnerServers",
        "count": "[length(variables('secondaryServers')]",
        "input": {
            "id" : ""
        }
    }
]
```

Now we just need to make sure that we build the *id* property correctly and to do that we will finally use the *copyIndex* function which is the whole reason we even did all of this.

```JSON
"copy": [
    {
        "name": "partnerServers",
        "count": "[length(variables('secondaryServers')]",
        "input": {
            "id" : "[resourceId('Microsoft.Sql/servers/', variables('secondaryServers')[copyIndex('partnerServers')])]"
        }
    }
]
```

Now, this is a little more complex and I will walk you through it. We replace our *secondaryServerName* with our array that we defined in our variables section. Since it is an array we can grab values based on the index. So to determine which iteration we are on, we use the *copyIndex* function. Since this is **NOT** a resource iteration we cannot use **copyIndex()**, we have to specify the name of the copy object, so it ends up being **copyIndex('partnerServers')** which is the name of our copy.

So here is the complete template to achieve a simple property iteration.

```JSON
"variables": {
    "secondaryServers" : ["mySecondary1", "mySecondary2"]
},
"resources": [
    {
        "type": "Microsoft.Sql/servers/failoverGroups",
        "name": "[concat(parameters('sqlServerPrimaryName'), '/', parameters('sqlFailoverGroupName'))]",
        "properties": {
            "copy": [
                {
                    "name": "partnerServers",
                    "count": "[length(variables('secondaryServers')]",
                    "input": {
                        "id" : "[resourceId('Microsoft.Sql/servers/', variables('secondaryServers')[copyIndex('partnerServers')])]"
                    }
                }
            ]
        }
    }
]
```

## Conclusion

I know this turned out to be a long post and I apologize. I think this is valuable information and hopefully, it will save you time and effort when you starting doing more advanced templates using ARM.

Thanks,

Jamie
