---
title: "Dotnet Method Caching"
date: 2020-02-28T22:05:50-05:00
draft: true
---

|    Method |  N |           Mean |         Error |        StdDev |
|---------- |--- |---------------:|--------------:|--------------:|
|    GetFib | 10 |       593.3 ns |       9.59 ns |       8.97 ns |
| GetFibLru | 10 |     2,465.1 ns |      29.70 ns |      27.78 ns |
|    GetFib | 20 |    75,243.5 ns |   1,835.96 ns |   1,717.35 ns |
| GetFibLru | 20 |     2,487.0 ns |      49.49 ns |      58.91 ns |
|    GetFib | 30 | 9,402,211.4 ns | 233,313.38 ns | 295,066.73 ns |
| GetFibLru | 30 |     2,561.3 ns |      51.06 ns |      47.76 ns |
