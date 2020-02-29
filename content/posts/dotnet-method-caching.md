---
title: "Dotnet Method Caching"
date: 2020-02-28T22:05:50-05:00
draft: true
---


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
|    Method |  N |           Mean |         Error |        StdDev |
|---------- |--- |---------------:|--------------:|--------------:|
|    GetFib | 10 |       593.3 ns |       9.59 ns |       8.97 ns |
| GetFibLru | 10 |     2,465.1 ns |      29.70 ns |      27.78 ns |
|    GetFib | 20 |    75,243.5 ns |   1,835.96 ns |   1,717.35 ns |
| GetFibLru | 20 |     2,487.0 ns |      49.49 ns |      58.91 ns |
|    GetFib | 30 | 9,402,211.4 ns | 233,313.38 ns | 295,066.73 ns |
| GetFibLru | 30 |     2,561.3 ns |      51.06 ns |      47.76 ns |
