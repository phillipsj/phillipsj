---
Title: Learning Fixie and Should
Published: 2016-07-23 10:22:51
Tags:
- Cake
- Open Source
RedirectFrom: 2016/07/23/Learning-Fixie-and-Should/index.html
---

To be a good steward of my Cake.XdtTransform project, I decided that I needed to add some unit tests. With such a small project with very little functionality, I took it as an opportunity to learn a new tool. I have looked at the [Fixie](http://fixie.github.io/) project a few times, but haven't really given it much thought as I have the most experience with [NUnit](http://nunit.org/) and [xUnit](https://xunit.github.io/). As with any new tool, I wanted to make sure it would work with my intended work flow and of course it does, as it is already in Cake.

To get started all you have to do is use NuGet to install, then you can start writing your tests. The interesting part is that Fixie relies on convention over configuration and doesn't require all the ceremony of attributes. Just create a class that ends with "Tests" in it's name and the test runner will pick it up. Now, if you are used to a framework that provides an assertion library baked in, that is not Fixie. You will have to pick an assertion library that fits your needs. In the examples for Fixie, [Should](https://github.com/erichexter/Should) is used, so I decided I would give it a try. Should is a nice library, but you have to think very differently about how to write your test.

Here is a test in xUnit:

```

 [Fact]
 public void Should_Error_If_Source_File_Is_Null()(){
     // Given
     var fixture = new XdtTransformationFixture {SourceFile = null};
     
     // When
     var result = Record.Exception(() => fixture.TransformConfig());

     // Then
     Assert.IsExceptionWithMessage<ArgumentNullException>(result, "sourceFile");
}

```

And here is a test with Fixie:

```

public void ShouldErrorIfSourceFileIsNull() {
    // Given
    var fixture = new XdtTransformationFixture {SourceFile = null};

    // When
    var result = Record.Exception(() => fixture.TransformConfig());

    // Then
    result.ShouldBeType<ArgumentNullException>().ParamName.ShouldEqual("sourceFile");
}

```

As you can see they are not that different until you get to the assertion. This was the hard part as it is a different way of thinking. You are not comparing two results you are using the result, then you are asserting what the different properties of the result should be. Once I got my mind wrapped around that concept, it became pretty easy to write tests using Should. There are several other choices for assertions and there is a list in the Fixie documentation.

I really like how Fixie is simple to get started with, uses conventions, and doesn't provide an assertion library by default. It has made me think just a little differently about choices. Funny how you don't think you can use a different assertion library with your go to unit testing framework, but you can. So you like Should, I don't see any reason you couldn't use it with your favorite unit testing library. 


