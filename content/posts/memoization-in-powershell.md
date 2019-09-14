---
Title: "Memoization in PowerShell"
date: 2019-06-03T21:06:46
Tags: 
- Open Source
- Microsoft And Linux
- Tools
- PowerShell
---
# Memoization in PowerShell

I have been working on improving my Computer Science knowledge, it has grown over the years, and I know that improving it will help my imposter syndrome. With that said, I have been spending my time reading [Classic Computer Science Problems in Python](https://amzn.to/317OnvR), this is a fantastic book, and I am confirming what I do know and learning all kinds of new information. One of the first exercises is about recursion and how you can leverage memoization to save some calculation time. I find that I learn best by taking it and applying to other languages that I know, so I decided that applying it in PowerShell sounded like fun. The problem that you use recursion to solve is a Fibonacci calculator.

My first attempt in PowerShell without memoization.

```PowerShell
#! /usr/bin/env pswsh

function Get-Fibonacci
{
    param([parameter(Mandatory)][int]$Number)

    if ($Number -lt 2)
    {
        return $Number
    }

    return (Get-Fibonacci($Number - 2)) + (Get-Fibonacci($Number - 1))
}

Get-Fibonacci(10)
```

Not too bad, the return is a little funky and provides me some more to learn about PowerShell to maybe clean that up. However, this will result in 170+ calls to the Get-Fibonacci function to compute for just 10. Memoization will allow us to cache the results and reduce the number of requests we make. This is all good, however, let's see if we can get some hard numbers. We can use the **Measure-Command** to get us the timing of the method.

```PowerShell
#! /usr/bin/env pswsh

function Get-Fibonacci
{
    param([parameter(Mandatory)][int]$Number)

    if ($Number -lt 2)
    {
        return $Number
    }

    return (Get-Fibonacci($Number - 2)) + (Get-Fibonacci($Number - 1))
}

Measure-Command { Get-Fibonacci(10) }
```

Now when we execute we should see the following:

```Bash
$ ./fib.ps1
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 0
Milliseconds      : 32
Ticks             : 323102
TotalDays         : 3.73960648148148E-07
TotalHours        : 8.97505555555556E-06
TotalMinutes      : 0.000538503333333333
TotalSeconds      : 0.0323102
TotalMilliseconds : 32.3102
```

We can see that it took 32.31 milliseconds to run. Let's implement memoization and see how much faster this gets. We are going to use a PowerShell hash table to store our calculated values. Here is the code:

```PowerShell
#! /usr/bin/env pswsh

# Hash table with default values
$Memo = @{0 = 0; 1 = 1}

function Get-Fibonacci
{
    param([parameter(Mandatory)][int]$Number)

    if(-not $Memo.ContainsKey($Number))
    {
        $Memo[$Number] = (Get-Fibonacci($Number - 2)) + (Get-Fibonacci($Number - 1))
    }

    return $Memo[$Number]
}

Measure-Command { Get-Fibonacci(10) }
```

Let's see how much time we saved.

```Bash
$ ./fib.ps1
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 0
Milliseconds      : 9
Ticks             : 94255
TotalDays         : 1.09091435185185E-07
TotalHours        : 2.61819444444444E-06
TotalMinutes      : 0.000157091666666667
TotalSeconds      : 0.0094255
TotalMilliseconds : 9.4255
```

Wow, we saved 21.88 milliseconds by adding in a cache for our already calculated values. This opens up even more questions as the Python examples show being able to decorate a method with *lru_cache* will automatically do the memoization for you. I don't see any [Least Recently Used](), LRU, cache available in PowerShell or in C#. There may be libraries that do it, but not in the standard library. If anyone knows that it exists, please let me know.

I hope you found this fun and useful.

Thanks for reading,

Jamie
