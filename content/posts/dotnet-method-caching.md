---
title: ".NET Method Caching"
date: 2020-02-29T21:05:50-05:00
tags:
- Open Source
- Dotnet Core
- .NET Core
- .NET
- Microsoft And Linux
- Tools
---

I wrote a post a few months back on [memoization in Powershell](https://www.phillipsj.net/posts/memoization-in-powershell/). I decided to revisit what this looks like in .NET. In Python, it is supported out of the box. Python provides a [LRU Cache](https://docs.python.org/3/library/functools.html#functools.lru_cache) decorator that lets you use memoization on any method. The code below is what memoization looks like using the decorator.

```python
@lru_cache(maxsize=None)
def fibonacci(number):
    if number < 2:
        return number

    return fibonacci(number - 2) + fibonacci(number - 1)
```

This code is also an excellent example of using aspect-oriented programming, abbreviated AOP. This capability got me thinking about what this would look like in .NET, specifically C#. The thought would be to leverage an attribute on a method that would implement the cache. AOP isn't something readily available in .NET, so we are going to lean on the excellent [PostSharp](https://www.postsharp.net/) library, which provides a cache attribute for us. Python and PowerShell both offer a simple way to time execution. In .NET, I think it is a more robust solution to leverage a tool like [BenchmarkDotNet](https://benchmarkdotnet.org/). Let's create a new project and add our NuGet libraries.

```bash
$ dotnet new console -o lru && cd lru
$ dotnet add package BenchmarkDotNet
$ dotnet add package PostSharp.Patterns.Caching
```

Once configured, you can copy the code below. The *GetFibonacciLru* method is the method that implements the PostSharp Cache attribute. The only configuration required is setting up the caching backend. If you look in the *Fibonacci* class Setup method, you will see that the caching backend is a memory cache. PostSharp also supports a Redis cache depending on what you need. The remaining code is just bootstrapping for the benchmarking.

```csharp
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Running;
using PostSharp.Patterns.Caching;
using PostSharp.Patterns.Caching.Backends;

namespace lru {
    public class Fibonacci {
        private int number;

        [Params(10, 20, 30)] public int N;

        [GlobalSetup]
        public void Setup() {
            number = N;
            CachingServices.DefaultBackend = new MemoryCachingBackend();
        }

        [Benchmark]
        public int GetFib() => GetFibonacci(number);

        [Benchmark]
        public int GetFibLru() => GetFibonnaciLru(number);

        private int GetFibonacci(int number) {
            if (number < 2) {
                return number;
            }
            return (GetFibonacci(number - 2) + GetFibonacci(number - 1));
        }

        [Cache]
        private int GetFibonnaciLru(int number) {
            if (number < 2) {
                return number;
            }
            return (GetFibonnaciLru(number - 2) + GetFibonnaciLru(number - 1));
        }
    }

    class Program {
        static void Main(string[] args) {
            var summary = BenchmarkRunner.Run<Fibonacci>();
        }
    }
}
```

Now we can execute our benchmark to see the difference. We are going to pass three different starting numbers: 10, 20, 30. These values will allow the test to be quick and still provide enough transactions to demonstrate the difference memoization can have. Let's run our test, making sure to do it in *Release* mode.

```bash
$ dotnet run -c release
```

After it finishes executing, you should see a chart like this one. Let's look at the results.

|    Method |  N |           Mean |         Error |        StdDev |
|---------- |--- |---------------:|--------------:|--------------:|
|    GetFib | 10 |       593.3 ns |       9.59 ns |       8.97 ns |
| GetFibLru | 10 |     2,465.1 ns |      29.70 ns |      27.78 ns |
|    GetFib | 20 |    75,243.5 ns |   1,835.96 ns |   1,717.35 ns |
| GetFibLru | 20 |     2,487.0 ns |      49.49 ns |      58.91 ns |
|    GetFib | 30 | 9,402,211.4 ns | 233,313.38 ns | 295,066.73 ns |
| GetFibLru | 30 |     2,561.3 ns |      51.06 ns |      47.76 ns |

The first thing that I noticed is calculating a Fibonacci sequence for a small number, and the memoization is slower. This result has been the case in most languages. However, as soon as you increase the number of calculations, the caching kicks in. As we go even larger, we are starting to have a consistent performance with the caching.

## Conlusion

These results aren't shocking. It worked as I expected while I also learned a new option that is out there for .NET. PostSharp provides this capability, and you can even use the attribute with database transactions, which there are examples. The surprising thing for me is that this isn't something shipped out of the box. There are similar capabilities in ASP .NET Core with the OutputCache attribute, something like this in the base class library would be beautiful.

Thanks for reading,

Jamie
