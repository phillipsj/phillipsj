---
title: "Rustup and Kate: All You Need for Rust Development"
date: 2020-12-26T19:07:12-05:00
tags:
- Rust
- Rustacean
- Open Source
- Rustup
- openSUSE
---

I like working with Rust, and [rustup](https://rustup.rs/) is one of those tools that make it enjoyable. Installing a single tool that helps you manage your Rust environment is fantastic, and it helps update it as you need. They did a great job of making it a cross-platform tool to keep it consistent. One of the other features of rustup is that you can install additional components like [RLS](https://github.com/rust-lang/rls), the Rust Language Server. RLS is an LSP, language server protocol, implementation for Rust used with many editors, even Kate. Kate is an official KDE application, so it should be available, if not already installed, on most Linux distros that have KDE available. It is one of my favorite text editors and is lightweight. I am going to walk you through getting RLS installed, and Kate configured to leverage it.

## Installing RLS

Once you have rustup installed on your system, all you need to do is execute the following command.

```Bash
$ rustup component add rls rust-analysis rust-src
info: downloading component 'rls'
info: installing component 'rls'
info: using up to 500.0 MiB of RAM to unpack components
  8.3 MiB /   8.3 MiB (100 %)   7.5 MiB/s in  1s ETA:  0s
info: downloading component 'rust-analysis'
info: installing component 'rust-analysis'
info: downloading component 'rust-src'
info: installing component 'rust-src'
```

Now we have the Rust Language Server installed. We can go about configuring Kate.

## Turning on LSP support in Kate

Let's open Kate and go to *Settings --> Configure Kate* then you can click on the *Plugins* section under *Applications* in the window that pops up.


![](/images/rustup-kate/kate-plugins.png)

Once that is enabled, you should now see an LSP menu and tab in Kate.

![](/images/rustup-kate/lsp-enabled-kate.png)

We can test this out by creating a Rust project and see that the LSP plugin is working with RLS.

## Testing it out

The first step is to create a Rust project using cargo.

```Bash
$ cargo new hello
Created binary (application) `hello` package
```

Now let's open **hello.rs** in Kate and then click on the LSP tab at the bottom. You should see that RLS is detected.

![](/images/rustup-kate/rls-detected-kate.png)

RLS is detected, and we can see it in action providing use with completion and info.

![](/images/rustup-kate/rls-in-action-kate.gif)

That's pretty slick, in my opinion, to see Kate work with minimal configuration.

## Conclusion

Rust has a great community and ecosystem behind it that makes it easy to get going. Combine that with the incredible KDE community, and you can have a working dev environment with just one command and a plugin.

Thanks for reading,

Jamie
