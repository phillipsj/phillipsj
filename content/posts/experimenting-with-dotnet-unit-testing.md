---
title: "Experimenting With .NET Unit Testing"
date: 2021-03-02T19:39:29-05:00
tags:
- Open Source
- .NET Core
- Microsoft And Linux
- Tools
- Fixie
- Testing
---

While learning more about Go, I have started finding a few interesting approaches that differ from the typical conventions seen in .NET. I decided that I would experiment around with some of these differences. Two approaches have interested me, and we are doing to discuss one of them in this post. That one approach has been how to run tests with multiple inputs. The approach with xUnit and many other frameworks look like below. You can also pull [this](https://github.com/phillipsj/dotnet-unit-testing-experiments) GitHub repo with all the code and then more in it.

```CSharp
[Theory]
[InlineData(1, 2, 3)]
[InlineData(2, 3, 5)]
public void ShouldAdd(int a, int b, int expected) {
    var actual = Calculator.Add(a, b);
    Assert.Equal(expected, actual);
}
```

Hopefully, that looks familiar. In Go, the pattern seems to be to use an array and loop through running the tests. Here is an example.

```CSharp
[Fact]
public void ShouldAdd() {
    var data = new[] {
        new {A = 1, B = 2, Expected = 3},
        new {A = 2, B = 3, Expected = 5}
    };

    foreach (var item in data) {
        var actual = Calculator.Add(item.A, item.B);
        Assert.Equal(item.Expected, actual);
    }
}
```

I kind of like it compared to having all those attributes. It is very different. Let's look at what division would look like with this approach and when you expect an exception.

```CSharp
[Fact]
public void ShouldDivide() {
    var data = new[] {
        new {A = 1, B = 1, Expected = 1, ErrorExpected = false },
        new {A = 4, B = 2, Expected = 2, ErrorExpected = false },
        new {A = 4, B = 0, Expected = 0, ErrorExpected = true }
    };
            
    foreach (var item in data) {
        try {
            var actual = Calculator.Divide(item.A, item.B);
            Assert.Equal(item.Expected, actual);
            Assert.False(item.ErrorExpected);
        }
        catch (DivideByZeroException e) {
            Assert.True(item.ErrorExpected);
        }
   }         
}
```

This technique has been an interesting thought experiment and may lead to me adopting some of these. I hope you enjoyed it too.

Thanks for reading,

Jamie
