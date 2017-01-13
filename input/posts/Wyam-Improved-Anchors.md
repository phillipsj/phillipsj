---
Title: 'Wyam: Improved Anchors'
Published: 1/12/2017
Tags:
- Open Source
- Wyam
---

After reading another awesome [post](http://www.digitaltapestry.net/posts/wyam-anchors-and-code-copy) by [wekempf](http://www.digitaltapestry.net) mentions that the H1 tag in the header is getting the anchor added too.  After a little peak at the documentation, all you need to do is add a CSS selector on the add method to limit it to all H1 tags in the content.

### Original

```
anchors.add();
```

### Improved

```
anchors.add('#content > h1');  // Notice the CSS selector added here.
```

This a quick little tweak to correct the issue.

Thanks,

Jamie
