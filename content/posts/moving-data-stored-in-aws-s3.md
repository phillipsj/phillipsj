---
title: "Moving Data Stored in AWS S3"
date: 2024-01-28T12:49:18-05:00
tags:
- Open Source
- Python
- AWS
- S3
- Data
- Amazon
---

If you have known me or have been following this blog for a while, you know that I've traditionally been much more Azure-focused.
While I have been more focused on Azure, that doesn't mean that I don't know or use other clouds. This may be an unpopular
opinion, but I feel that at the end of the day, all clouds are the same. They may have different names for things, but the majority
of the concepts are the same and are applicable. Enough of this, let's get into discussing moving data around in S3. 

Now you may be asking why we need to move data around. Well, there are many reasons the most common being in my experience
moving assets/data between environments and backing up data. You may be surprised about the backup use case, just remember that
replication isn't a backup and it's a good practice to have at least three copies sourced in different locations. Given these
use cases, what are the normal options available in AWS? I have narrowed it down to these six different options listed below, 
not taking third-party solutions into account.

* AWS Data Sync
* AWS S3 Replication
* AWS CLI
* AWS S3 Batch Operations
* AWS SDKs

Each one of these has its list of restrictions and uses which we will cover in at least a high-level overview. I have
found that each one of these options works well enough if it fits what you want to achieve.

## Breaking the options down

Let's get this party started as I know you are just as excited as I am about it. 

### AWS Data Sync

AWS Data Sync is probably the newest solution from AWS as it was released in 2023. It has a wide variety of storage solutions
it supports a total of around 20. If you have specific known locations that you need sync data between then you can use this
to schedule the syncs and just let it run. It has capabilities to move large amounts of data quickly and it supports incremental 
updates. I think it's a great solution if you need to constantly sync assets from on-premises to the cloud, cloud to cloud,
or if you want to move assets between production and lower environments. These are all known locations that aren't defined
dynamically. There are some limitations with the more frustrating ones being that [ACLs have to be disabled](https://aws.amazon.com/datasync/faqs/). This has ruled
it out as a solution multiple times for me as the primary use case of the bucket required ACls to be enabled. If you 
can configure buckets to work with it, it's a good option.

* [Data Sync FAQs](https://aws.amazon.com/datasync/faqs/)

### S3 Replication

S3 Replication is exactly as it sounds, it's a replication of existing resources between one or many buckets. If you just
need to replicate data and you can meet the [requirements](https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html#replication-requirements) then it is probably the option for you.
The biggest requirement is that the source bucket must have versioning enabled, the other requirement to make it mind is
that the destination bucket has to be configured the same as the source. Not much to say about this option. It's a very 
common use case and that is exactly why it's offered as a service. Outside of pure replication workflows, it doesn't  
fit nor would I expect it.

* [Replication Docs](https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html)

### AWS CLI

The AWS CLI is a pretty straightforward tool to use, there are a ton of [S3 Commands](https://docs.aws.amazon.com/cli/latest/reference/s3/)
available with the ones specific to this post being `cp, mv, and sync`. The `cp` and `mv` commands operate on a single file
while the `sync` command operates on a directory or prefix. Depending on your needs of moving the data will depend on your approach.
Sync will let you move directories or prefixes to a new bucket and a new directory or prefix. Since the other two commands 
operate on an individual file you have a lot more control. The two biggest limitations with using this tool in my opinion is that
it's a little more challenging to do complex workflows and speed. As soon as you move past Bash, then you might as well jump into 
using one of the SDKs. The speed is limited to how you are working with the data and where it is running. It's not the fastest
option out of all of these.

### S3 Batch Operations

[S3 Batch Operations](https://docs.aws.amazon.com/AmazonS3/latest/userguide/batch-ops.html) are pretty cool as they give 
you a lot of flexibility. You can create a manifest of the files you want to operate on, then you submit a job that can
be almost any S3 operation. You can create lambdas to perform additional processing as part of the job which gives you 
even more flexibility. As far as moving data goes, you can copy from the existing bucket to a new one keeping the prefixes
or defining a new prefix to move the data. This by far has been the quickest method of moving large amounts of data. Gigs
of data can be moved in minutes whereas a CLI sync can take much longer. The biggest downside to using it is the extra setup 
complexity. The S3 Batch operation needs its role with the correct permissions in the source and destination buckets.
Once I had this figured out and put in IaC it became less of a hassle. I wouldn't manage this manually. 

### AWS SDKs

What can I say here? This is the ultimate in flexibility and allows the most customization. Anything you want to
do with moving around data you can do it. There is, however, one big drawback to using the SDKs. If you need performance,
this isn't the option. Most operations are going to occur one at a time. You are trading flexibility for speed.
You can use libraries like [multiprocessing](https://docs.python.org/3/library/multiprocessing.html) to parallelize the 
operations and you can tune the SDK clients a little, but the speed isn't going to come close to these other options.

## Wrapping Up

This is just a quick overview of the different options and what I have found to be the pain points with each one. Now I 
will share my favorite solution, it's the S3 Batch Operations solution. I can customize a little by creating my 
manifests and I can tweak the destination location, oh and it's fast. I think I will eventually follow up with a post
on using it in Python in the future.

Thanks for reading,

Jamie
