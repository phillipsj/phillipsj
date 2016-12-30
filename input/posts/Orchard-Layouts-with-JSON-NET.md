---
Title: Orchard Layouts with JSON.NET
Published: 2015-09-11 20:00:00
Tags:
- Orchard
- Open Source
RedirectFrom: blog/html/2015/09/11/orchard_layouts_with_json_net.html
---

I have been developing a custom module that uses the Dynamic Forms module to programitically create a form. When creating a form you need to also create a layout. Below is an example from the PageCommands.cs in the Orchard Pages module for creating a layout.

```
layout = 
  "{\"elements\": [" +
      "{" +
        "\"typeName\": \"Orchard.Layouts.Elements.Html\"," +
        "\"data\": \"Content=" + Encode(Text) + "\"" +
      "}" +
  "]}";
```

This just looks unpleasing and error prone. I would like to look at creating something like [HtmlTags](https://github.com/DarthFubuMVC/htmltags), which would create a fluent and error free way to
build layouts. However, that is going to take a little effort to get figured out. Until then, I decided I would try to use [JSON.NET](http://www.newtonsoft.com/json) to build the layout. I feel that
using the JSON.NET objects make it easier and less error prone to generate larger layouts.

Here is an example using JSON.NET:

```
var layout = new JObject("elements",
                new JArray(
                    new JObject(
                        new JProperty("typeName", "Orchard.Layouts.Elements.Html"),
                        new JProperty("data", string.Format("Content={0}", Encode(Text)))
                    )
                )
            );
```

I am going to spend some time looking for a better solution. As far as performance goes, it does increase usage a little, but the improvement to readability is worth it.

Thanks for reading.