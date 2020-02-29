---
title: "NAS as a DB Server"
date: 2020-02-29T12:26:39-05:00
tags:
- NAS
- SQL Server
- Linux
- Hardware
---

Someone had read this [post](https://www.phillipsj.net/posts/sql-server-on-qnap-nas/) and asked if I thought a NAS would be a good choice for running an MS SQL and MySQL database for a Small Business.  The short answer is yes; I actually do think that it would be a good use for a NAS. NASes are an expensive purchase and running a database on it for back-office applications or running a website with light traffic would get even more value out of it. There are a few caveats to specs when deciding to purchase a NAS to host a database.

1. Max out the RAM
2. Choose non-ARM CPU based system like Intel
3. Fast storage

Databases like to use RAM, especially SQL Server. You will want to be also leveraging other capabilities of the NAS like for shared storage, so having plenty of RAM available is going to be key. While MySQL is available for ARM-based systems, MS SQL Server for Linux is currently only available for x86/amd64 processors.

## QNAP specifics

Now the actual question was asking about the [TVS-872XT](https://www.qnap.com/en-us/product/tvs-872xt/). I am currently running a [TS-251+](http://www.qnapworks.com/TS-251-Plus.asp) that I upgraded to have 8GB of RAM. The quad-core Intel Celeron has plenty of power and does a good job of running MS SQL for Linux that I use for doing development. I have been planning to use my NAS to host my database for TeamCity and a few other home systems.  

With all of that said, I think that the 8th gen Core i5 hex-core CPU along with maxing out the RAM to 32GB in the TVS-872XT would be an awesome all in one system that I personally would feel comfortable using to run things like databases and [NextCloud](https://nextcloud.com/) in addition to all the backups and other storage that it would be used to do. Now the question is how would I run these items, that's easy, I would leverage [Container Station](https://www.qnap.com/solution/container_station/en/). Container Station is QNAP's tool for running containers on your NAS.

Two items to keep in mind when doing it is to make sure that you create volumes in container station to mount to your containers to use for your database file storage and set CPU and Memory limits on the containers that you run. I would start out by getting the baseline usage on your NAS, which will let you know how many resources you have available to dedicate to your databases. I would then look at the minimum requirements for each database engine that you plan to run and start with limiting your resources based on that.

In the case of MySQL, it is recommended to have 6GB of RAM with a minimum of 4GB of RAM. I think to start with 4GB of RAM dedicated to that container is probably fine with a CPU limit of 17%, which is roughly a single core.

MS SQL Server for Linux has the recommended minimum set to at 2GB, but my experience tells me that if I was going to run a real application, I would start with 4GB with a CPU limit of 17%, which is a roughly a single core.

I would then run the desired applications and keep an eye on perceived performance and CPU/Memory usage on the NAS. From there, I would either add or decrease resources as required to meet my needs.

Hopefully, this is useful, and basically just my opinion. I do believe that NASes can be leveraged for many small businesses for hosting applications and provide a nice easy way to manage those capabilities. I will add that external backup will become even more important, along with making sure that you are leveraging mirroring on your NAS.

Thanks for reading,

Jamie
