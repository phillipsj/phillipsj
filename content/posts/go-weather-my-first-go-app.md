---
title: "Go Weather: My First Go App"
date: 2020-03-06T20:23:47-05:00
tags:
- go
- golang
- gopher
- Open Source
- OSS
---

About six months ago, I wrote this [post](https://www.phillipsj.net/posts/rusty-weather-my-first-rust-app/) about writing an app in [Rust](https://www.rust-lang.org/). It was a Python app that I created as part of a training course. I keep getting pulled into projects that require knowledge of golang, so I decided to build an app that I understood my needs so it would be easier to grok. I am impressed by the fact that I only needed a single external dependency. I probably could have done it without it, but I liked it's API, that library was [Colly](http://go-colly.org/). Here is the app.

```golang
package main

import (
    "bufio"
    "fmt"
    "github.com/gocolly/colly"
    "os"
)

type report struct {
    Loc       string
    Temp      string
    Scale     string
    Condition string
}

func main() {
    PrintHeader()

    reader := bufio.NewReader(os.Stdin)

    fmt.Println("What zipcode do you want the weather for (97201)?")
    zipcode, err := reader.ReadString('\n')

    if err != nil {
        fmt.Println("Cannot read the input.")
    }

    report := GetHtmlFromWeb(zipcode)
    fmt.Printf("The temp in %s is %s %s and %s.", report.Loc, report.Temp, report.Scale, report.Condition)
}

func PrintHeader() {
    fmt.Println("---------------------------------")
    fmt.Println("           WEATHER APP")
    fmt.Println("---------------------------------")
}

func GetHtmlFromWeb(zipcode string) report {
    url := fmt.Sprintf("http://www.wunderground.com/weather-forecast/%s", zipcode)
    report := report{}
    c := colly.NewCollector()

    c.OnError(func(_ *colly.Response, err error) {
        fmt.Println("Something went wrong:", err)
    })

    c.OnHTML(".city-header > h1:nth-child(2) > span:nth-child(1)", func(e *colly.HTMLElement) {
        report.Loc = e.Text
    })

    c.OnHTML(".condition-icon > p:nth-child(2)", func(e *colly.HTMLElement) {
        report.Condition = e.Text
    })

    c.OnHTML(".current-temp > lib-display-unit:nth-child(1) > span:nth-child(1) > span:nth-child(1)", func(e *colly.HTMLElement) {
        report.Temp = e.Text
    })

    c.OnHTML(".current-temp > lib-display-unit:nth-child(1) > span:nth-child(1) > span:nth-child(2) > span:nth-child(1)", func(e *colly.HTMLElement) {
        report.Scale = e.Text
    })

    c.Visit(url)
    return report
}
```

That is the entirety of the application. I was able to create this much faster than I did in Rust. However, I had to handle a few errors that were not obvious, which I think is more of the fact that I don't have the golang idioms down yet. Overall, it was a fun experience, and I don't know why I avoided learning more about it.

Thanks for reading,

Jamie
