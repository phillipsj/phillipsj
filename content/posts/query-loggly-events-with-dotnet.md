---
title: "Query Loggly Events With .NET"
date: 2023-03-05T21:30:18-05:00
tags: 
- Open Source
- .NET
- .NET Core
- Tools
- Loggly
---

I haven't done a lot of .NET development lately and I found this a fun little program to create. I needed to be able to query [Loggly](https://www.loggly.com) to get a list of events. Loggly returns a max number of results, if your results are larger than that max then your results become paginated. Loggly paginates using a [JSON API](https://jsonapi.org/) inspired next link. After a little research as to what the latest recommended approach is, I discovered [Flurl](https://flurl.dev/). Flurl is pretty cool and made this fairly easy to construct the URL cleverly. I also discovered [PollyFlurl](https://github.com/SaahilClaypool/PollyFlurl) which provides a nice API around using Polly with Flurl. Okay, enough with the background info, let's get into it.

The first step is to look at the JSON structure that is returned from querying the [Loggly Events API](https://documentation.solarwinds.com/en/success_center/loggly/content/admin/paginating-event-retrieval-api.htm). The example that has the bits I'm concerned about are provided below.

```JSON
{
    "events": [],
    "next": "<next URL>"
}
```

I plan to use the raw JSON of the event, so I don't need to parse that into a full class in C#. I'm going to use the System.Text.Json library, specifically the [JsonElement](https://learn.microsoft.com/en-us/dotnet/api/system.text.json.jsonelement?view=net-7.0) to handle the events array. This allows me to access the raw JSON as I need. This resulted in a class that looks similar to this:

```csharp
using System.Text.Json;

namespace EventsFetcher; 

public class LogglyResults {
    public List<JsonElement>? Events { get; set; }
    public string? Next { get; set; }
}
```

Now we can put Flurl to use building out our API call and deserializing the JSON into a C# result. Once we make the initial query, we need to check if the results are paginated which means the next link is provided. If the next link is provided, we can make a while loop that will keep making a call to the next link as long as it isn't null or empty. This will allow us to collect all events that occurred during the time specified in the query. You will notice the `RetryTransientErrors` call that is provided by PollyFlurl. That's an extension method that wraps up the policies in a nice fluent API.

```csharp
using EventsFetcher;
using Flurl;
using Flurl.Http;
using PollyFlurl;

var accountName = "<loggly subdomain>";
var apiKey = "<api key>";

var result = await $"https://{accountName}"
            .AppendPathSegment("apiv2")
            .AppendPathSegment("events")
            .AppendPathSegment("iterate")
            .SetQueryParams(new { 
                q = "*", 
                from = "-10m", 
                until = "now", 
                size = "100"})
            .WithOAuthBearerToken(apiKey)
            .RetryTransientErrors()
            .GetAsync()
            .ReceiveJson<LogglyResults>();

if (result is not null) {
    var logs = result.Events;
    var nextLink = result.Next;
    while (!string.IsNullOrEmpty(nextLink)) {
        var nextResult = await nextLink
            .WithOAuthBearerToken(apiKey)
            .RetryTransientErrors()
            .GetAsync()
            .ReceiveJson<LogglyResults>();
        if (nextResult is not null) {
            logs.AddRange(nextResult.Events);
            nextLink = nextResult.Next;
        }
    }
    Console.WriteLine(logs.Count);
}
```

That's it for the basics. I'm sure this can be improved and I do have a few additional ideas that I will share once I test those out.

## Conclusion

As with most of my posts, I hope you found this helpful. If you have any info to share with me, please reach out on GitHub, LinkedIn, or Mastodon.

Thanks for reading,

Jamie