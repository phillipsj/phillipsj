---
title: "Uploading a CSV Workout to TrainingPeaks using AI"
date: 2026-07-26T16:26:43-04:00
tags:
- Training
- Cycling
- Bikes
- MTB
- Mountain Bike
- OSS
- Open Source
- MCP
- AI
- Python
---

I don't discuss my enjoyment of cycling here much; however, it's probably one of my favorite activities. My preference is mountain biking, but being on a bicycle of any kind creates a lot of joy for me. I have been doing training plans for about the last year, and I am using [TrainingPeaks](https://www.trainingpeaks.com) to purchase the plans and track them. However, it seems that there isn't an easy way as an `athlete` user to be able to create plans and upload them. However, after having Claude take a strength routine that I wanted to incorporate, I discovered that there are several methods available that leverage some application APIs to enable you to upload a workout. The first step is to get the plan you want to create in a format that will allow it to be uploaded.  

Here is a quick example of the format.

| Column | Purpose | Example |
|---|---|---|
| `Title` | Workout name shown on the calendar | `ABF Press Day — Week 1 (Single KB)` |
| `WorkoutType` | Sport/category | `Strength` |
| `WorkoutDescription` | Full instructions/notes for the session | `Warm-up: 5min joint mobility... Main: 5 ladders of 1-2-3...` |
| `PlannedDuration` | Duration in **decimal hours** (not minutes) | `0.5` = 30 min, `0.4167` ≈ 25 min |
| `WorkoutDay` | Date, ISO format | `2026-07-27` |

{{< note >}}

- Duration must be decimal hours, not `HH:MM` or minutes — a 25-minute session is `0.4167`, not `25`.
- `WorkoutDay` uses plain `YYYY-MM-DD`, no time component.
- Every column in the full header needs to be present for a well-formed export-style CSV, even if most are left empty — that's why the full file has ~44 columns despite only 5 mattering for planning.
{{< /note >}}

After I created my plan exactly how I wanted it, I started looking at the solutions to upload it. I decided to choose integrating this MCP server that I found for TrainingPeaks called [trainingpeaks-mcp](https://github.com/JamsusMaximus/trainingpeaks-mcp). A quick glance through the [README](https://github.com/JamsusMaximus/trainingpeaks-mcp/blob/main/README.md) and I was up and running in a matter of minutes. A quick restart of Claude Desktop and I was connected. I provided my CSV that I had created earlier to Claude, and it got to work using the MCP server to push the plan to my calendar. Since I had been looking at the [TrainingDojo](https://trainingdojo.app) previously as an example, Claude decided to use their recommendation of uploading the first three workouts of the plan fo for me to inspect. A quick check in the TrainingPeaks App and I was good, so I told Claude to finish it up. AI in general has started making a lot of the mundane tasks much easier. I was able to make a plan, quickly convert it into a CSV, and then use existing tools to do the grueling tasks of creating it. Typically with TrainingPeaks, a lot of this has to happen manually in the UI.

Just a cool little story that I thought I would share.

Thanks for reading,

Jamie
