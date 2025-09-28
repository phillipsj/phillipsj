---
title: "The AWS Rust SDK Experience"
date: 2025-09-28T12:24:21-04:00
tags:
- Rust
- Rustacean
- Open Source
- AWS
- AWS Rust SDK
- DevContainers
---

I finally found the opportunity to use [Rust](https://rust-lang.org) in a real application. I needed to create an [AWS Lambda](https://aws.amazon.com/lambda/), which wasn't very complex, and AWS has a [Rust SDK](https://aws.amazon.com/sdk-for-rust/), so the stars aligned. I have been wanting to use Rust more over the years, and I can say that the experience has been great. The AWS SDK appears comprehensive and has many features I enjoyed using.

One of the signatures for an EventBridge event is `EventBridge<T1 = Value>`, which I like. The `T` allows you to build a custom type using [serde](https://serde.rs) to deserialize the detail property on the EventBridge JSON object. There are a few attributes you have to define, which I hope to cover in a future post, that make it a little easier.

The last thing I have to say on the AWS Rust SDK side is that the unit testing story is good. I don't think it's as full-featured as the Python story. I decided to rely on mocks using [mockall](https://docs.rs/mockall/latest/mockall/), when in Python, I would have used [Moto](https://pypi.org/project/moto/). Moto isn't so manual as everything is already mocked and tracks the state.

I have been slow to adopt [Dev Containers](https://microsoft.github.io/code-with-engineering-playbook/developer-experience/devcontainers-getting-started/) in my IDE workflow, and I tried that out on this project. Why did I take so long to try them out? After some trial and error, I settled on using a custom Dockerfile for my dev container. I used the [cargo-lambda](https://www.cargo-lambda.info) base image, then I installed clippy, fmt, and [just](https://github.com/casey/just). One minor annoyance is having to authorize the [Q Developer](https://aws.amazon.com/q/developer/) extension when the container is rebuilt.

These are just some quick thoughts from my first experience using the AWS Rust SDK. I look forward to writing about other interesting things that I discover along the way in this area.

Thanks for reading,

Jamie
