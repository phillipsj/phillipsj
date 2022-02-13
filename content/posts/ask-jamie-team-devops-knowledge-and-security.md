---
title: "Ask Jamie: Team DevOps Knowledge and Security"
date: 2020-11-18T20:50:54-05:00
tags:
- DevOps
- Opinion
- Ask Jamie
---

I am back with another excellent set of questions on Twitter concerning team knowledge and security.

{{< tweet user="sinclairinat0r" id="1322988042454503424" >}}

I have touched on these in a previous, just a little indirectly, and I will cover them more in-depth here.

## How many devs on a team should be knowledgeable about DevOps?

I just sighed while writing this because you probably know I am going to say all team members. DevOps is about culture, and culture requires the whole team to participate. The more the group owns, the more they will be empowered to experiment and improve those processes. Not everyone on a team will be as interested in the same items, which means that more in-depth knowledge will be distributed among individuals. That is perfectly fine as long as most people will be able to troubleshoot and support the basics of the processes you have. Everyone should be able to fix a breaking build or deployment pipeline. Everyone should handle basic container builds or high-level infrastructure as code if you have those in place. Expecting everyone to handle intricate details of your CI server, infrastructure as code, or a tool like Docker is not realistic. Those require additional specialization that many devs may not have an interest in. It's hard to keep up with languages or framework features, so a desire to add depth in DevOps processes may not be feasible. Keeping as much as you can in the documentation, doing reviews of these processes as a team, and pairing are great ways to increase comfort and build confidence. 

I would also suggest adding something like a triage assignment that rotates through the team responsible for these items when they break. The expectation wouldn't be that they have to handle it alone. It's that they are the first to try and then get support when they need it. This will ensure that everyone can learn and gain the experience that will be required when people take a vacation or leave. 

## Security in DevOps

I don't know where the statement originated, but the quote "Security is built-in, not bolted on" applies to DevOps. You need to make it part of the SDLC, software development lifecycle, as upstream as possible. Let's dig in.

As with many things in DevOps, making security part of the culture is a wise move. The closer to the development process you can address security concerns, the better. One way to do that is with a static analysis security tool, a SAST. There are commercial tools like [WhiteSource Bolt](https://www.whitesourcesoftware.com/free-developer-tools/bolt) or [Black Duck](https://www.blackducksoftware.com/) for scanning your source code. There are also plenty of open source tools like [Security Code Scan](https://github.com/security-code-scan/security-code-scan) or [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/) that would be an excellent place to start. My opinion is to get started with something and then slowly improve it as needed in the true DevOps spirit. The initial goal of using one of these tools is to raise awareness and get developers thinking about security while coding. Collect the data during CI, decide if it should fail the build. In addition, I would suggest just collecting and reviewing monthly as a team. This is all information that can be shared with auditors or internal security teams. This is also important data to provide if there is a data breach. 

In addition to scanning your source code, if you are publishing container images, I would suggest using a tool like [trivy](https://github.com/aquasecurity/trivy) or [grype](https://github.com/anchore/grype). These will raise your awareness of CVEs that may exist inside your base container or be introduced by something you added. You can address these before they make it into production and potentially prevent a more severe issue. Again, this makes a statement to your security team or auditors that you are at least thinking about security. 

One last note, make the outputs of these tools a part of your build artifact. That gives traceability, much like making sure to track anything you need to address as work items tied to commits. When you have to trace all of these items, which I hope you don't have to do, it will be more comfortable.

## Conclusion

That is all I have immediately on my mind about these topics. If there are any details or questions anyone has about the tools that I listed, please reach out, and I will share what I know.

Thanks for reading,

Jamie

 
