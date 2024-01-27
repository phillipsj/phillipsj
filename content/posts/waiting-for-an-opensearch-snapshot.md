---
title: "Waiting for an OpenSearch Snapshot"
date: 2024-01-27T12:22:02-05:00
tags:
- Open Source
- Python
- AWS
- OpenSearch
---

I ran into an interesting challenge while doing some automation tasks. Taking manual snapshots of [OpenSearch](https://opensearch.org/)
is an interesting challenge that I just didn't expect. Everything isn't very clear and I learned a lot figuring this out. Given
that it was more challenging than expected I thought I would create a post to share what I discovered for future reference
for myself and everyone else that will come across this post.

## The Problem

There were additional steps that needed to happen after taking a manual snapshot which created an interesting problem. You make
a manual snapshot request, then the snapshot needs to happen which can happen quickly, or it can take several minutes depending
on the index and other conditions. The additional steps that I needed to perform only needed to occur after the snapshot had
been completed. What I needed to do was wait for the snapshot to be complete before proceeding. 

## Existing Code Samples

Amazon and OpenSearch have good code samples to get you started using both CLI tools like cURL and Python. Here is one of the
examples for taking a manual snapshot. Here are the links to the docs:

* https://docs.aws.amazon.com/opensearch-service/latest/developerguide/managedomains-snapshots.html
* https://opensearch.org/docs/latest/tuning-your-cluster/availability-and-recovery/snapshots/snapshot-restore/

I have included a basic snippet derived from the docs above showing how to initiate the snapshot from Python:

```Python
import boto3
import requests
from requests_aws4auth import AWS4Auth

host = ''
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, "us-west-1", "es", session_token=credentials.token)

url = f"{host}/_snapshot/<repository>/<snapshot>"

response = requests.put(url, auth=awsauth)
print(response.text)
```

The above code does indeed create the snapshot. However, the snapshot isn't complete before the response has been returned.
If you want to perform additional processing then you have to take additional steps which we will review below.

## Waiting for a manual snapshot

There are two options that I have found on how to make sure that the snapshot is complete before you take any additional 
steps. The first option is to poll an endpoint checking the status and the second option is to not submit the snapshot request
as an asynchronous request. Either option solves the problem and it really depends on your needs and how long a snapshot takes
to complete. Let's go over these solutions.

### Checking the Snapshot Status

This is the first option that I mentioned. This is where we poll the status endpoint checking the state of the status. The docs
state that the following [statuses](https://opensearch.org/docs/latest/api-reference/snapshots/get-snapshot-status/#snapshot-states) 
are possible:

* SUCCESS
* IN_PROGRESS
* PARTIAL
* FAILED

We can make a call to `_snapshot/<repository>/<snapshot>/_status` to get the status. The Python for that would look like this:

```Python
import boto3
import requests
from requests_aws4auth import AWS4Auth

host = ''
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, "us-west-1", "es", session_token=credentials.token)

url = f"{host}/_snapshot/<repository>/<snapshot>"

response = requests.put(f"{url}?wait_for_completion=true", auth=awsauth)

if response.status_code != 200:
    return

status_url = f"{host}/_snapshot/<repository>/<snapshot>/_status"
snapshot_response = requests.get(status_url, auth=awsauth)
snapshot_status = snapshot_response.json()
current_state = snapshot_status["state"]

while snapshot_status.state == "IN_PROGRESS"
    status_resposne = requests.get(status_url)
    status = status_resposne.json()
    current_state = status["state"]
    

if current_state == "SUCCESS":
    print("Snapshot complete!")
else:
    print(f"Snapshot failed: {current_state}")
```

That is a rough implementation of how to check for the status. Checking for status is probably the correct solution if you
have snapshots that take a long time.

### Waiting during the HTTP Request

This is the second option where instead of submitting an asynchronous API request, we add the query parameter 
[`wait_for_completion=true`](https://opensearch.org/docs/latest/tuning-your-cluster/availability-and-recovery/snapshots/snapshot-restore/#take-snapshots) 
which will make the HTTP call a synchronous request which will not return until the snapshot has been completed. Let's
see what that looks like in Python.

```Python
import boto3
import requests
from requests_aws4auth import AWS4Auth

host = ''
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, "us-west-1", "es", session_token=credentials.token)

url = f"{host}/_snapshot/<repository>/<snapshot>"

response = requests.put(f"{url}?wait_for_completion=true", auth=awsauth)
print(response.text)
```

Not much of a change, but now the request is blocking so you know when it completes that the snapshot is complete.

## Wrapping Up

I hope you found this helpful and it saves you a little time. I know that I will be referencing it in the future as I'm 
sure I will run across this scenario again. 

Thanks for reading,

Jamie
