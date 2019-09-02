---
Title: "CLI Parsing with Rust"
Published: 09/02/2019 10:18:11
Tags: 
- Rust
- Rustacean
- Open Source
- Pax
---
# CLI Parsing with Rust

Now that I have my previous F# code converted to Rust, it is time for me to start adding the new features and creating a CLI application. Besides deciding the command structure, there is the parsing that has to happen. Rust has a few things in the standard library to aid us in this, and it would be suitable for a small and basic CLI application. As the complexity increases, in this case, two primary commands with several subcommands, the standard library will start making it more difficult. After reviewing [StructOpt](https://crates.io/crates/structopt) and [clap](https://crates.io/crates/clap) I decided that I would roll with clap to get this app off the ground.

Clap takes an interesting approach as it uses the builder pattern to build our your CLI. I like that, but I did get a little lost within the parentheses at times. 

So here is how to build out a basic app in clap, of course, it is hello world.

```Rust
use clap::{Arg, App, SubCommand};

fn main() {
    let matches = App::new("A simple app")
        .version("0.1.0")
        .author("Jamie Phillips")
        .subcommand(
            SubCommand::with_name("hello")
                .about("Prints hello <name>!")
                .arg(
                    Arg::with_name("name")
                        .help("your name")
                        .required(false)
                        .default_value("world"),
                ),
        )
        .get_matches();

    match matches.subcommand() {
        ("hello", Some(hello_matches)) => {
            println!("Hello {}!", hello_matches.value_of("name").unwrap());
        }
        _ => unreachable!(),
    };
}
```

The cool thing about clap is that I can focus on providing the information about the commands that I care about and you get help and version commands for free. The info above feeds into the help system as documentation. There are a couple of other exciting items happening. I have configured my argument not to be required, but I am providing a default value. By setting a default value, the help documentation will include that in the help for that command. The section that is using that is matching the commands can get a little tedious due to the tuple, but so far it isn't caused many issues for me navigating the commands.

Let's build this and execute the app on the command line.

```Bash
$ ./simpleapp.exe --help
A simple app 0.1.0
Jamie Phillips

USAGE:
    simpleapp.exe [SUBCOMMAND]

FLAGS:
    -h, --help       Prints help information
    -V, --version    Prints version information

SUBCOMMANDS:
    hello    Prints hello <name>!
    help     Prints this message or the help of the given subcommand(s)
```

That output is cool, and I didn't even need to define most of it. We also have help specific to our hello command.

```Bash
$ ./simpleapp.exe hello --help
Prints hello <name>!

USAGE:
    clitest.exe hello [name]

FLAGS:
    -h, --help       Prints help information
    -V, --version    Prints version information

ARGS:
    <name>    your name [default: world]
```

Now let's execute the hello command.

```Bash
$ ./simpleapp.exe hello
Hello world!

$ ./simpleapp.exe hello jamie
Hello Jamie!
```

I just wanted to provide a quick little tour of clap and show some of the features that I am leveraging with the subcommands and default values.

Thanks for reading,

Jamie
