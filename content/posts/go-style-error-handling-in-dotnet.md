---
title: "Go-Style Error Handling in .NET"
date: 2021-04-02T12:21:50-04:00
tags:
- Open Source
- .NET Core
- Go
---

When I am learning something new, I like to compare and contrast that to something I know well. When it comes to programming languages, that would be C# for me. I have been learning Go, and I was curious what it could look like to apply the Go style of error handling in C#. In case you aren't aware of the Go style, here is an example.

```Go
func main() {
    m, err := getMessage("Jamie")
    if err != nil {
        fmt.Println(err)
        os.exit()
    }

    fmt.Println(m)
}

func getMessage(n string) (m string, err error) {
    return fmt.Sprintln("Hello %v!", n)
}
```

Go has built-in support for returning multiple values, and you will see this pattern in most Go code. It is a different approach than what most do in C#. To replicate this style in C#, we will need to leverage tuples for the return type and use the destructuring syntax to keep it as close to Go as possible. Here is my take on that style in C#.

```CSharp
class Program {
    static void Main(string[] args) {
        var (m, err) = GetMessage("Jamie");
        if (err is not null) {
            Console.WriteLine(err);
            return;
        }

        Console.WriteLine(m);
    }

    private static (string, string) GetMessage(string name) {
      return ($"Hello {name}!", null);
    }
}
```

What do you think? In some ways, it is cleaner than try-catch. It reminds me a lot of leveraging options in functional langugages.

Thanks for reading,

Jamie