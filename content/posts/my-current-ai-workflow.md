---
title: "My Current AI Workflow"
date: 2026-07-21T18:29:08-04:00
tags:
- Tools
- Processes
- AI
---

First thing every morning, I open Claude Desktop, and I start off by brainstorming the three things I want to get done that day. I have been in that pattern for several years after having read [“Getting Results the Agile Way”](https://gettingresults.com).  After I list the three things I need done, I will look at email, Slack, etc., and see if there are any other tasks I need to add to my list. Then I ask Claude to create me a Jira issue for each task, then help me plan the task. I provide all the context that I think is required, then have it validate that it’s enough. That information gets added to the Jira task.

If the information is determined to not be enough, then I do a quick planning session with Claude Code to update the issue with the correct information.  

After all the Jira issues get created and provided with details, I open Claude Code in my workspace directory, which has all of my source code and some cues on how to navigate. Then I have it list out the Jira issues that need to be completed and tell it to get to work.

I have created skills and rules that guide Claude on how I want feature branches named based on the Jira Issue ID, how I want all commits squashed, and to not push any code or create any PRs. I also have a documentation skill and rules that help Claude understand when documentation needs to be created and how it needs to be added to the wiki.

After tasks are complete, I review each commit that was created. This usually involves looking over all the code changes, the docs, etc., to ensure that it meets my personal standards. After that, I push to the remote repository and open a pull request.

That’s it; that is all there is to the workflow I have been using for the last couple of months now. It has taken me a little bit of time to figure out how I wanted to work with AI. I was originally using it integrated into my IDE; however, I was still doing a lot of the manual work of making sure Jira had issues tracked and making manual lists.
