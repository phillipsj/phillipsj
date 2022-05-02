---
title: "Deserializing JSON or YAML With Rust"
date: 2022-05-01T21:05:52-04:00
tags: 
- Rust
- Rustacean
- Open Source
- JSON
- YAML
- serde
---

It's been almost a year since I have written any [Rust](https://www.rust-lang.org/). I am a little rusty, to say the least, and things have changed a little. I will say that every time I come back to a functional style of programming after being away it feels more natural. I wanted to know how to deserialize a JSON or YAML file. In Go, it would be pretty easy to do it with struct tags and an if check. I stumbled across the [serde](https://crates.io/crates/serde) crate which provided the features I wanted. That crate allows you to easily deserialize almost any format into a struct. I created a simple test JSON and YAML file to deserialize.

I created the file called `data.json` with the following:

```JSON
{
  "firstName":"Jamie",
  "lastName": "Phillips",
  "address": {
  "street": "123 Test St",
  "city": "Testville"
  }
}
```

I also created a file called `data.yaml` with the same data, just as YAML.

```YAML
firstName: Jamie
lastName: Phillips
address:
  street: 123 Test St
  city: Testville
```

Next, I started creating my Rust application by defining my structure in my `main.rs`.

```Rust
#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
struct Address {
    street: String,
    city: String,
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(rename_all = "camelCase")]
struct Info {
    first_name: String,
    last_name: String,
    address: Address,
}
```

You will notice that I added several traits to my structs. These traits allow for serialization and deserialization. I then proceeded to create my function that would take in the contents of a file and attempt to deserialize it from YAML, if the YAML failed, then it would try to deserialize it from JSON. I was about to use the `?` operator to make the code a little more condensed.

```Rust
fn get_data(s: &str) -> Result<Info, Box<dyn Error>> {
   return match serde_yaml::from_str::<Info>(s) {
        Ok(data) => Ok(data),
        Err(_e) => {
            let json_data = serde_json::from_str::<Info>(s)?;
            Ok(json_data)
        }
    };
}
```

All that was left was to create my `main` function to be able to compile the application and run it.

```Rust
fn main() -> Result<(), Box<dyn Error>> {
    let data_string = &std::fs::read_to_string("data.json")?;
    let data = get_data(data_string)?;
    println!(
        "{} {} lives on {}, in {}",
        data.first_name, data.last_name, data.address.street, data.address.city
    );
    return Ok(());
}
```

If we execute it, we should see this:

```Bash
$ cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.03s
     Running `target\debug\myapp.exe`
Jamie Phillips lives on 123 Test St, in Testville
```

This worked perfectly for what I wanted to achieve. Rust produced a really terse application that I know will handle behave.

Thanks for reading,

Jamie