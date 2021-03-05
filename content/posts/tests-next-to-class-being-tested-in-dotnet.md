---
title: "Tests Next to Class Being Tested in .NET"
date: 2021-03-04T19:56:54-05:00
tags:
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
- Fixie
- Testing
---

I am back with trying something new that again is common in Go and popular in JavaScript too. We will see what it would look like to have tests inside the same project next to the class. 

Let's get started by creating a new .NET class library project.

```Bash
$ dotnet new classlib -n Calculator
```

Now we need to remove the Class1.cs and create the Calculator.cs Our Calculator.cs is going to look like this.

```CSharp
namespace Calculator {
    public class Calculator {
        public static int Add(int a, int b) {
            return a + b;
        }

        public static int Subtract(int a, int b) {
            return a - b;
        }

        public static int Multiply(int a, int b) {
            return a * b;
        }

        public static int Divide(int a, int b) {
            return a / b;
        }
    }
}
```

Now we need to add our testing dependencies to our project. Edit your csproj file and add the following item group. This will add Fixie, Fixie.Console, and Shouldly.

```XML
<ItemGroup>
    <PackageReference Include="Fixie" Version="2.2.2" />
    <DotNetCliToolReference Include="Fixie.Console" Version="2.2.2" />
    <PackageReference Include="Shouldly" Version="4.0.3" />
</ItemGroup>
```

Now we can create our CalculatorTests class in the CalculatorTests.cs file.

```CSharp
using System;
using Shouldly;

namespace Calculator {
    public class CalculatorTests {
        public void ShouldAdd() {
            Calculator.Add(2, 3).ShouldBe(5);
        }

        public void ShouldSubtract() {
            Calculator.Subtract(3, 2).ShouldBe(1);
        }

        public void ShouldMultiply() {
            Calculator.Multiply(1, 2).ShouldBe(2);
        }

        public void ShouldDivide() {
            var data = new[] {
                new {A = 1, B = 1, Expected = 1, ErrorExpected = false},
                new {A = 4, B = 2, Expected = 2, ErrorExpected = false},
                new {A = 4, B = 0, Expected = 0, ErrorExpected = true}
            };

            foreach (var item in data) {
                try {
                    Calculator.Divide(item.A, item.B).ShouldBe(item.Expected);
                    item.ErrorExpected.ShouldBeFalse();
                }
                catch (DivideByZeroException e) {
                    item.ErrorExpected.ShouldBeTrue();
                }
            }
        }
    }
}
```

Now our project directory looks like the following.

```Bash
$ ls -l
bin/
obj/
Calculator.cs
Calculator.csproj
CalculatorTests.cs
```

This is a little different from what we would typically see in .NET. Let's double-check that it all works as expected.

```Bash
$ dotnet restore && dotnet fixie
dotnet fixie
Building ExperimentsTestsWithCode...
Running ExperimentsTestsWithCode

4 passed, took 0.05 seconds
```

## Thoughts

I don't know how I feel about this approach in .NET. Overall I think that this approach for smaller projects would be very doable and would work well. In larger, enterprise-style projects, I have mixed feelings about how successful it would be long term. 

I hope you found this an interesting thought experiment.

Thanks for reading,

Jamie
