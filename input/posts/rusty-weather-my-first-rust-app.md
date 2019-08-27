---
Title: "Rusty Weather: My first Rust App"
Published: 08/26/2019 20:58:40
Tags: 
- Rust
- Rustacean
- Open Source
---
# Rusty Weather: My first Rust App

I have wanted to learn a new language and framework, as well as I, know C# and .NET for many years. I have dabbled in several different ones, but the only one that I seemed to come back to continually was Python. After trying all kinds of languages over the last couple years, I decided I would give [Rust](https://www.rust-lang.org/) a try. I have only been a consumer of garbage collected runtimes, so I was a bit hesitant to give it a try.  But I am finding that I have enough knowledge now that I am not intimidated by it. The safety of the language prevents me from getting myself in trouble, and I like the features that are from a more functional paradigm. It is also cross-platform and works equally well on Windows as it does Linux/macOS which is impressive. I will also go out on the limb and say that [Cargo](https://doc.rust-lang.org/cargo/) is one of the best package management/build tools that I have used.

When I am learning, I like to build applications that do things that I have found fun, and making this app was no exception. I adopted the idea from this Python [app](https://github.com/talkpython/python-jumpstart-course-demos/blob/master/apps/05_weather_client/final/program.py) that I did as part of the [Python Jumpstart by building 10 Apps](https://training.talkpython.fm/courses/explore_python_jumpstart/python-language-jumpstart-building-10-apps) course from [TalkPython](https://talkpython.fm/). You can check out my entire repo [here](https://github.com/phillipsj/rustyweather), but I will provide my first pass and my final pass.

Here is my first pass at the app. I used *unwrap* pretty extensively, which is skipping out on some of the safety and a tuple for my return type. However, it functions just like the Python version.

```Rust
use std::io;
use std::format;
use scraper::{Html, Selector};

fn main() {
    print_header();

    println!("What zipcode do you want the weather for (97201)?");

    let mut code = String::new();
    io::stdin().read_line(&mut code).expect("Cannot read the input.");

    let html = get_html_from_web(&code);
    let report = get_weather_from_html(&html);

    println!("The temp in {} is {} {} and {}.", report.0, report.1, report.2, report.3)
}

fn print_header() {
    println!("---------------------------------");
    println!("           WEATHER APP");
    println!("---------------------------------");
}

fn get_html_from_web(zipcode: &str) -> String {
    let url = format!("http://www.wunderground.com/weather-forecast/{}", zipcode);
    let mut resp = reqwest::get(&url).unwrap();
    resp.text().unwrap()
}

fn get_weather_from_html(html: &str) -> (String, String, String, String) {
    let document = Html::parse_document(html);
    let loc_selector = Selector::parse(".city-header > h1:nth-child(2) > span:nth-child(1)").unwrap();
    let condition_selector = Selector::parse(".condition-icon > p:nth-child(2)").unwrap();
    let temp_selector = Selector::parse(".current-temp > lib-display-unit:nth-child(1) > span:nth-child(1) > span:nth-child(1)").unwrap();
    let scale_selector = Selector::parse(".current-temp > lib-display-unit:nth-child(1) > span:nth-child(1) > span:nth-child(2) > span:nth-child(1)").unwrap();

    let loc = document.select(&loc_selector).last().unwrap().inner_html();
    let condition = document.select(&condition_selector).last().unwrap().inner_html();
    let temp = document.select(&temp_selector).last().unwrap().inner_html();
    let scale = document.select(&scale_selector).last().unwrap().inner_html();

    println!("{}", loc);
    println!("{}", condition);
    println!("{}", temp);
    println!("{}", scale);

    (loc, condition, temp, scale)
}
```

I decided this wasn't good enough and didn't see to be what a Rustacean would have created, so I went back to coding. I think this example is a little better. I still have some usage of *unwrap*, however in this situation if the CSS selectors error then I want it to panic.

```Rust
use std::io;
use std::format;
use reqwest::Error;
use scraper::{Html, Selector};

struct Report {
    loc: String,
    temp: String,
    scale: String,
    condition: String
}

fn main() {
    print_header();

    println!("What zipcode do you want the weather for (97201)?");

    let mut code = String::new();
    io::stdin().read_line(&mut code).expect("Cannot read the input.");

    let weather = match process_zipcode(&code) {
        Ok(report) => report,
        _ => String::from("An error occured while processing.")
    };

    println!("{}", weather);
}

fn process_zipcode(input: &str) -> Result<String, Error> {
    let html = get_html_from_web(&input)?;
    let formatted = match  get_weather_from_html(&html) {
        Some(report) => format!("The temp in {} is {} {} and {}.", report.loc, report.temp, report.scale, report.condition),
        None => String::from("An error occured while parsing the weather report.")
    };
    Ok(formatted)
}

fn print_header() {
    println!("---------------------------------");
    println!("           WEATHER APP");
    println!("---------------------------------");
}

fn get_html_from_web(zipcode: &str) -> Result<String, Error> {
    let url = format!("http://www.wunderground.com/weather-forecast/{}", zipcode);
    let mut resp = reqwest::get(&url)?;
    resp.text()
}

fn get_weather_from_html(html: &str) -> Option<Report> {
    let document = Html::parse_document(html);
    let loc_selector = Selector::parse(".city-header > h1:nth-child(2) > span:nth-child(1)").unwrap();
    let condition_selector = Selector::parse(".condition-icon > p:nth-child(2)").unwrap();
    let temp_selector = Selector::parse(".current-temp > lib-display-unit:nth-child(1) > span:nth-child(1) > span:nth-child(1)").unwrap();
    let scale_selector = Selector::parse(".current-temp > lib-display-unit:nth-child(1) > span:nth-child(1) > span:nth-child(2) > span:nth-child(1)").unwrap();

    let loc = document.select(&loc_selector).last()?.inner_html();
    let condition = document.select(&condition_selector).last()?.inner_html();
    let temp = document.select(&temp_selector).last()?.inner_html();
    let scale = document.select(&scale_selector).last()?.inner_html();

    Some(Report { loc: loc, temp: temp, scale: scale, condition: condition})
}
```

I have already started writing a few more apps in Rust; two of these apps are personal projects that I have started in other languages. I plan to port this to Rust and get these released. After completion, I think I will have a good feel for the language and ecosystem. So far I can report that for me, it is everything you hear people say about it. It's easy, powerful, and has a great ecosystem.

Thanks for reading,

Jamie
