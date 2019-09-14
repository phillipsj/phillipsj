---
Title: Cake.XdtTransform
date: 2015-10-21T20:00:00
Tags:
- Open Source
- Cake
RedirectFrom: blog/html/2015/10/21/cake_xdttransform
---

As part of moving our Orchard build over to Cake, I was trying to find a good way to do the config transfomrs.  Cake offers a pretty good XML transform methods, but I wanted a solution that used the XDT transform. A little quick googling and I stumbled across this Github [issue](https://github.com/cake-build/cake/issues/321), so with this post I created an addin that adds this functionality. Not realy a big deal, I didn’t think it was necessary to pull that into the core as it adds an extra dependency that is probably not really needed, but it is a nice to have. You can find it up on Nuget also.
