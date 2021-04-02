---
title: ".NET Containers: Windows vs. Linux Part 2"
date: 2021-04-01T21:15:27-04:00
tags:
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
- .NET
- Containers
- Docker
- Kubernetes
- Windows Containers
---

My [previous](https://www.phillipsj.net/posts/dotnet-containers-windows-vs-linux-part-1/) post covered the developer experience. Now I am back looking at performance between Windows and Linux containers for a basic ASP .NET application. I will test the performance using a Python-based tool called [Locust](https://locust.io/). It seems much more approachable than something like JMeter or ApacheBench, and it looks fun to use. The methodology should look familiar. This test was having some fun and learning some new tools, so please read it with that in mind.

## Methodology

The following hardware executed all tests:

```
CPU: Ryzen 5 3600, 6 cores/12 threads
RAM: 32GB DDR4 3200Mhz RAM
SSD: 512GB NVMe Gen3 x4
 OS: Windows 10 20H2
```

I ran the latest version of Docker Desktop for Windows with WSL2 integration enabled with the default WSL2. I used the following [repo](https://github.com/phillipsj/dotnet-container-showdown) on GitHub with the following Dockerfile. I will be running these containers on the same machine that will be executing the load tests. I will be using Python 3.9 and Locust 1.4.3 for the load testing. Here is the *locustfile* that I am using and located in the repo linked above. I am only hitting the two endpoints created from the template.

```Python
import time
from locust import HttpUser, task, between

class ContainerShowdown(HttpUser):
    wait_time = between(1, 2.5)

    @task
    def home(self):
        self.client.get("/")

    @task
    def privacy(self):
        self.client.get("/Home/Privacy")
```

I then used the following for my load test, and once I got to 1k users, I let it run for one minute, then stopped and downloaded the generated report.

```
Total Users: 10k
Spawn rate: 100
```

## Results

Well, this was indeed interesting and insightful. Here are the results.

### Request Statistics Aggregated

This table lists the different environments, with local being just *dotnet run* on the hardware listed above.

Env     | Requests | Fails | Avg (ms) | Avg Size (bytes) | RPS   | Failures/s |
--------|----------|-------|----------|------------------|-------|------------|
Linux   | 23654    | 2485  | 1055     | 1941             | 309.2 | 32.5       |
Windows | 38754    | 0     | 57       | 2169             | 503.0 | 0.0        |
Local   | 40954    | 0     | 4        | 2169             | 518.6 | 0.0        |

I expected Linux to outperform Windows without thinking about the underlying implementation. I believe this is due to how Linux containers on Windows works and the default WSL2 configuration. It would be interesting to see how that compares to not using the WSL2 integration and if I tweaked the WSL2 configuration. I am going to call that an anomaly until I can dig into it. I do find it interesting that I don't feel local performance vs. Windows container performance was all that different. The average request time difference does jump out at me, and I would expect it to be different due to the extra networking. 

## Conclusion

I was surprised by the differences, which mostly make sense to me. Doing these kinds of tests can highlight things about your code, runtime, or platform that you wouldn't usually notice. Just doing local development work, you may never see these differences. Yet, these differences exist and do create an impact at some point. Imagine when doing this in production the insights that you will gain about your application and environment.

I have three significant takeaways from this experiment. The first is that I need to dig into Linux containers on Windows to determine why I received the results. The second is to dig more into Windows container networking to learn more about the increase in latency. The final takeaway is that I need to do the same on Linux to see the difference. 

If you take the time to think about it, these results all make sense. It's just not something that you immediately think.

Thanks for reading,

Jamie