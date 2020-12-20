---
title: "Supporting Restarts With Container-Based Apps"
date: 2020-12-19T23:01:27-05:00
tags:
- Linux
- Containers
- Kubernetes
- Open Source
- Docker
---

This may seem like an odd conversation. Most applications have external dependencies, which end up being a data source of some sort, like a database. These applications will not function due to the database's availability, which introduces concerns in a container world. Once upon a time, Docker compose supported having defined dependencies to ensure that containers start in a specific order. This feature would ensure that your database was created and healthy before starting the app container, connecting to that database. Removal of the feature happened because the current opinions have changed. That change was that apps should detect if the database is available or not and handle it. To understand how this impacts applications, we need to discuss what is available in tools like Docker and Kubernetes.

Docker and Kubernetes both have restart policies for containers. The restart policy determines what the platform should do if the container stops running. The exit code of the application will determine how to interpret the policy. An exit code of zero means that the application exited with success, and an exit code of one means there was a failure. If you had the restart policy set to *always*, then an exit code of one was returned by the application, the platform will restart it. Returning exit codes from your application becomes very important to the operation of your containers.

Now that how and what the platform expects, we need to understand what this means for our application. When building an application for that environment, it will be wise to enable proper exit codes for your application to make stopping and failures more graceful. Since our application requires the database, we should write our application to check if the database is available. If not, exit the application with an exit code of one. Docker and Kubernetes, if the restart policy is *always*, will detect a non-zero exit code and automatically restart the container. That loop will continue for a specified time or until the database reports that it is available, at which time the application will start functioning.  Returning exit codes for your applications make them robust and fault-tolerant. Let's look at some pseudo-code.

```
func int main() {
  var databaseAvailable = CheckDatabase()
  if not databaseAvailable { return 1 } // failure exit code
  
  ApplicationStart()
}
```

As you can see, we checked if the database was ready for our application to operate. If not, then we exit with a non-zero exit code. The exit code will trigger the platform based on the restart policy to perform additional actions. The result is a more robust application.

I will do some posts with this in action. Next time you are running an app, what it's behavior. I know that Grafana does this exact behavior.

Thanks for reading,

Jamie
