---
title: "Ask Jamie: Reducing Layers between Commit to Prod"
date: 2020-10-31T12:42:59-04:00
tags:
- DevOps
- Opinion
- Ask Jamie
---

I posted a tweet on Twitter asking what people would like to know about DevOps and automation. I said I would share my experiences and opinions based on questions asked with a blog post. I had a few people ask outstanding questions, and this is one of many posts answering those questions.

The first question asked was the following:

{{< tweet user="Brad_Knowles" id="1322197407896162304" >}}

With a follow up providing more detail:

{{< tweet user="Brad_Knowles" id="1322197536774434819" >}}

This is a tough question and one that is difficult to start addressing. DevOps is all about culture, and to be successful, you have to facilitate the cultural shifts necessary to let the changes succeed and drive success.

I have found that I typically focus on items within my control and not worry about the loci of control. That focus on things that I can change directly allows momentum to be generated, and from that place of momentum, you can slowly start pushing culture and practices from there. Let's jump into the question above, and we will do some from the perspective of a developer, which I believe is the person's role asking the question.

## Removing the friction to QA

I would start by focusing on getting my code to the test/QA stage in the workflow. The goal is to automate as many of these steps with quality gates as to enforce checks that will lower the friction and drive focus to the most necessary items. An example of a quality gate would be check-in/merge policies implemented in your source control system.

Do your code reviews get bogged down by formatting? If so, then you should look to implement a merge policy that leverages linting as either a pass or fail process. If the linting fails, then the code doesn't need to be reviewed yet. When I say code linting, I mean style checking, coding standards, etc. There are tools like Flake or PyLint in Python, Prettier in JavaScript or StyleCop for C#. These all allow you to define rules for formatting, naming, etc. These should be part of the build process and possible pre-commit hooks that help devs get it cleaned up before submitting a PR.

Do you require builds to be successful before accepting a PR? If not, then a successful CI build is another quality gate before code can be reviewed. We don't want code that doesn't compile to be merged in.

Do you have unit tests that are executed as part of your build process? If you don't' then you should. Execute your unit tests as part of your CI. Fail your build if the tests don't pass. That will signal to the reviewer that the code isn't ready to be reviewed.

At this point, you have enough gates in place then code reviews can be more focused as you have removed a lot of noise in the system. There should be little to no exceptions to these gates/policies. Either it meets your standard, or it doesn't, so choose these standards carefully.

In addition to these, think about adding tools like vulnerability/security scanners to your CI process. This will allow your team to address security concerns as part of the development and raise awareness of any issues. This will help with your security team and compliance, as these will be documented. It additionally demonstrates that you are mitigating these issues consistently.

## Testing before integrations

I feel this should be automated as much as possible. I am not saying altogether to remove manual verification. I am just saying that if you have automated QA/integration tests, run those on your integration branch or on your dev branch. Try to do as much as you can earlier in the process before other teams get involved. These demonstrate to other groups that you value their time, and you share their concerns. This allows higher value conversations to occur, and as you push for a more streamlined process, they will trust you because you have started taking responsibility for as much as you can upstream.

## Release cadence

I have discovered that getting a release cadence in place and sticking to it makes things more predictable for the other teams. It can potentially reduce batch sizes making the process less arduous since it isn't a big bang style release that is months of works. Even if it is just frequent deployments to the integration/stage environment, that demonstrates that you are delivering high quality and reliable code that isn't disrupting everyone else. One note to caution on cadence, you could find one too fast for your company, customers, etc. I ran into this issue where deploying when the feature is ready was too often; a week was too often. The business and customers could only tolerate a two-week release cadence; anything more was just overwhelming. Our team always released something on that two-week mark, even if it was small for consistency.

## It takes time

This is already a long list, especially if you haven't put any of these items in place. As you start introducing these items, it will initially slow you down. However, it will speed you up in the long run. I have found this stuff addictive, as it adds a sense of security and removes all the cognitive load required to make sure it was all handled. As the team gets more comfortable and builds confidence, the groups that interact with you will grow more comfortable and confident in your team. As that happens, you can start making additional suggestions to streamline the process, making it quicker. Make sure to record bug counts, build times, development times, velocity, etc. Not for the typical reasons, but as a way to track that these changes are making a difference. At that point, you will hopefully have several allies in other departments/teams and data that you can then approach the change control board with when you ask to start streamlining that part of the process.

## Conclusion

I hope this helps you get started with improving the time it takes from the inception of a feature to production. These are all small steps that will require a lot of work to get in place and adopted. These small steps will exponentially add up to drastically change your culture and practices. Just be patient.

Thanks for reading,

Jamie

