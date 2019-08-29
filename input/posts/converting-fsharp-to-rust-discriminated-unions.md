---
Title: "Converting F# to Rust: Discriminated Unions"
Published: 08/28/2019 20:50:29
Tags: 
- Rust
- Rustacean
- Open Source
- F#
- .NET
---
# Converting F# to Rust: Discriminated Unions

Almost a year ago, I created an application in F# that was a file structure generator. I created it in F# to get a better feel for functional, and it was a pretty cool project. My friend [Cameron](http://blog.thesoftwarementor.com/) helped me design some of the parts. I never really finished the vision that I had for that project and to finish it, I am going to convert it from F# to Rust. It's a simple project, but it should prove to be useful for myself and any others working with Terraform.

The first thing I wanted to work on in this app is to figure out how to convert a [Discriminated Union](https://fsharpforfunandprofit.com/posts/discriminated-unions/) that leverages recursive types in F# to the correct type in Rust. This example may not be my final solution, but it is an exercise in converting some existing code. I think my naming may need some work, and I am open to suggestions.

Here is the type in F#:

```F#
type Folder = File of string | Folder of string * Folder list
```

The idea of this time is I can have a folder, and it can either have a file or a folder with a list of *folders types*. After reading through this [blog post](https://mwhittaker.github.io/blog/ocaml_lists_in_rust/) and relying on the fact that both languages have roots in [OCaml](https://en.wikipedia.org/wiki/OCaml), here is my Rust version.

```Rust
enum Folder {
    File(String),
    Folder(String, Vec<Folder>)
}
```

It compiles, and I can use it almost the same fashion as I do in my F# code. I was surprised that it was so straight forward and reasonably intuitive to convert. I plan to do more posts as I convert this app over.

Thanks for reading,

Jamie
