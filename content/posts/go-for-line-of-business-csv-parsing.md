---
title: "Go for Line of Business: CSV Parsing"
date: 2021-06-11T20:14:49-04:00
tags:
- Go
- Golang
- Line of Business
- CSV
- .NET
---

I tossed out this idea last week about writing about using Go for line of business apps. I don't do many business apps these days, yet the first ten years of my career were pretty much in that space. During that time, I built all kinds of interesting apps, from making crime maps to point-of-sale systems. Most of those applications used .NET, which is pretty standard in line of business applications. Some of these applications just created reports, and others processed various file formats for loading data, with that background, that lead me to think about how Go could be used for these situations and how that compares to using .NET to achieve that same goal. When I say how it compares, I mean how it feels to write the language and how the solutions look. The real goal is to take something I have done dozens of times and apply it to a new language I am learning. Finding the data shouldn't be difficult, and we will use the [City of Austin's](https://www.austintexas.gov/) [Open Data Portal](https://data.austintexas.gov/) to find some data. Funny enough, this was one of those projects that I worked on that created many simples apps for processing CSV files and uploading the data to this very portal.

## The Problem

Let's pull down the [dataset](https://data.austintexas.gov/dataset/City-of-Austin-Tree-Planting/ingu-qjea) trees planted in the City of Austin between 2015-2020. Let's then parse that data and print out the total number of trees planted and trees planted by years.

## In .NET

Here is what this would look like in .NET. I would use the awesome [CsvHelper](https://joshclose.github.io/CsvHelper/) library to read in the data. Here is my .NET app. This solution isn't too bad in 50 lines and having to have a custom converter for a field with some oddities.

**Note: I could use a regex. I just didn't want to write one.**

```CSharp
using System;
using System.Globalization;
using System.IO;
using System.Linq;
using CsvHelper;
using CsvHelper.Configuration;
using CsvHelper.Configuration.Attributes;
using CsvHelper.TypeConversion;

namespace csvparser {
    class PlantedTrees {
        public string Category { get; set; }
        public int Year { get; set; }
        public string Program { get; set; }
        [Name("Funding Source")] public string FundingSource { get; set; }
        [Name("Land Type")] public string LandType { get; set; }

        [Name("Trees Planted or Distributed")]
        [TypeConverter(typeof(TreesPlantedConverter))]
        public int TreesPlanted { get; set; }
    }

    public class TreesPlantedConverter : DefaultTypeConverter {
        public override object ConvertFromString(string text, IReaderRow row, MemberMapData memberMapData) {
            var numberStyle = memberMapData.TypeConverterOptions.NumberStyles ?? NumberStyles.Integer;
            var cleaned = text.Replace(",", "").Replace("\"", "").Replace("Not Reported", "0");
            return int.TryParse(cleaned, numberStyle, memberMapData.TypeConverterOptions.CultureInfo, out var i)
                ? i
                : base.ConvertFromString(text, row, memberMapData);
        }
    }

    class Program {
        static void Main(string[] args) {
            using var reader = new StreamReader("City_of_Austin_Tree_Planting.csv");
            using var csv = new CsvReader(reader, CultureInfo.InvariantCulture);
            var records = csv.GetRecords<PlantedTrees>().ToList();
            var totalPlanted = records.Sum(x => x.TreesPlanted);
            var groups = records.GroupBy(x => x.Year).Select(y => new {
                Year = y.Key,
                Total = y.Sum(z => z.TreesPlanted)
            });
            foreach (var group in groups) {
                Console.WriteLine($"{group.Year} Total: {group.Total}");
            }
            Console.WriteLine($"Total planted: {totalPlanted}");
        }
    }
}
```

The output is the following.

```
2015 Total: 7262
2016 Total: 6133
2017 Total: 6380
2018 Total: 6378
2019 Total: 6969
2020 Total: 4946
Total planted: 38068
```

## In Go

Now let's see what we can do with Go. Go has a package for working with CSVs in [encoding/csv](https://golang.org/pkg/encoding/csv/). It's relatively simple and could work for those straightforward CSV files. It just happens that this one I picked is a little more complex than I want to handle by default, so I figured I would try out the [gocsv](https://github.com/gocarina/gocsv) package. It appears to have a lot of the functionality that is required. Let's see the Go code.

**Note: I could use a regex. I just didn't want to write one.**

```Go
package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/gocarina/gocsv"
)

type PlantedTrees struct {
	Category      string       `csv:"Category"`
	Year          int          `csv:"Year"`
	Program       string       `csv:"Program"`
	FundingSource string       `csv:"Funding Source"`
	LandType      string       `csv:"Land Type"`
	TreesPlanted  TreesPlanted `csv:"Trees Planted or Distributed"`
}

type TreesPlanted struct {
	int
}

func (t *TreesPlanted) UnmarshalCSV(csv string) (err error) {
	c := strings.ReplaceAll(csv, "\"", "")
	c = strings.ReplaceAll(c, ",", "")
	c = strings.ReplaceAll(c, "Not Reported", "0")
	t.int, err = strconv.Atoi(c)
	return err
}

func main() {
	records, err := os.OpenFile("City_of_Austin_Tree_Planting.csv", os.O_RDWR|os.O_CREATE, os.ModePerm)
	if err != nil {
		panic(err)
	}
	defer records.Close()

	var data []*PlantedTrees
	if err := gocsv.UnmarshalFile(records, &data); err != nil {
		panic(err)
	}

	total := 0
	for _, d := range data {
		total = total + d.TreesPlanted.int
	}

	groups := make(map[int]int)
	for _, d := range data {
		sum := 0
		for _, i := range data {
			if i.Year == d.Year {
				sum = sum + i.TreesPlanted.int
			}
		}
		if _, ok := groups[d.Year]; !ok {
			groups[d.Year] = sum
		}
	}

	for key, value := range groups {
		fmt.Println(key, "total: ", value)
	}
	fmt.Println("total planted: ", total)
}
```

This code isn't all the different from the previous example in C#. There are libraries out there that will let you approach things in a familiar way which will ease the transition to a new language. Here is the output:

```
2015 Total: 7262
2016 Total: 6133
2017 Total: 6380
2018 Total: 6378
2019 Total: 6969
2020 Total: 4946
Total planted: 38068
```

## Next steps

I have a few more of these types of posts written down. I have contemplated the use of Go for all kinds of apps, and in many ways, it would be a perfectly suitable language to do a lot of these tasks. Line of business applications don't get a lot of attention these days, yet I would say that it's an area that consumes developer time.

Thanks for reading,

Jamie
