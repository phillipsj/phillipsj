---
title: "Odd Issue Using BytesIO With Boto3"
date: 2023-09-27T20:16:51-04:00
tags:
- Boto3
- AWS
- S3
- Python
---

I've been trying to use more Python lately and I ran across an odd issue that I had to solve. I don't know if it's something that I'm doing incorrectly, a bug, or just a quirk.

> Hey this is Jamie from the future. I wasn't doing it correctly. Anytime you want to read an IO
> stream object in Python it's always best practice to call seek and set it to the beginning or
> just use the getvalue function.

## The Problem

I needed to convert a list of objects to a CSV, and then upload that CSV to an S3 bucket. This was a small CSV file so I wanted to do it all in-memory to save having to perform any disk IO. The Boto3 library has a [upload_fileobj](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3/client/upload_fileobj.html) function that can take a file-like object that is in binary mode. The Python [csv](https://docs.python.org/3/library/csv.html) module can support any object that supports the methods required for what you need to do. Since I wanted to write, I could use many of the classes in the IO package. I decided I would use [StringIO](https://docs.python.org/3/library/io.html#io.StringIO) with the [csv.writer](https://docs.python.org/3/library/csv.html#csv.writer) to get an in-memory stream of my CSV file. I then can convert that text stream into a binary stream to pass to *upload_fileobj* function.

## The Code

This is an example of the initial solution that I developed.

```Python
stream = StringIO()
writer = csv.writer(stream)
writer.writerow(['Test1', 'Test2'])
writer.writerow(['TestA', 'TestB'])

client = boto3.client('s3')
client.upload_fileobj(BytesIO(stream.read().encode()), 'upload_bucket', 'csv_key'))
```

One key thing to point out is that getting the value of the *StringIO* stream and then encoding it to bytes is the easiest way to convert it to a ByteIO object. After that, the in-memory CSV is pushed to my S3 bucket. When I went to verify that it all worked, I noticed that the file was empty. It took me way too long to figure it and that's why I decided to write a post. I was only getting the value of the stream from the current index which is where the writer had stopped writing. After a little research, I realized that I would need to set *seek* on the stream to set it back to the start of the stream.

Here is the improved code:

```Python
stream = StringIO()
writer = csv.writer(stream)
writer.writerow(['Test1', 'Test2'])
writer.writerow(['TestA', 'TestB'])
stream.seek(0)

client = boto3.client('s3')
client.upload_fileobj(BytesIO(stream.read().encode()), 'upload_bucket', 'csv_key'))
```

After that tweak, I ran my test again and when I verified my uploaded file, it had all the content.

## Realizations While Writing This Post

After starting this blog post, I realized that if using the *read* function on any IO object, you are required to set the stream position back to the start of the stream when using a writer of any sort as it's ready to receive the next write. Then I realized that I probably shouldn't be using *read* at all, I can just call *getvalue* and it will get all the contents of the stream. Here is the final example that is a little cleaner.

```Python
stream = StringIO()
writer = csv.writer(stream)
writer.writerow(['Test1', 'Test2'])
writer.writerow(['TestA', 'TestB'])

client = boto3.client('s3')
client.upload_fileobj(BytesIO(stream.getvalue().encode()), 'upload_bucket', 'csv_key'))
```

## Wrapping Up

It's always a journey when you start using a programming language more for tasks you aren't as familiar with. I learned a lot of intricacies that I take for granted in the languages that I know better. I hope someone else finds this helpful or amusing.

Thanks for reading,

Jamie
