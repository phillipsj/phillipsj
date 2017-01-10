---
Title: 'Wyam: Bootstrap Fun'
Published: 1/9/2017
Tags:
- Open Source
- Wyam
---

After reading this great [post](http://www.digitaltapestry.net/posts/alerts-in-wyam) by [wekempf](http://www.digitaltapestry.net) it made me think about block qoutes and how it can help me deliver a better block qoute experience. [wekempf](http://www.digitaltapestry.net) also posted an awesome cheatsheet for [Markdig](https://github.com/lunet-io/markdig/), the markdown engine for Wyam, [here](http://www.digitaltapestry.net/posts/markdig-cheat-sheet). Markdig provides a lot of additional functionaly that is just nice to have, I am grateful someone documented it in an easy to understand format. So I decided to have a little fun with block qoutes and a few other random bits.

# Standard Block Qoutes

In markdown using the following:

### Code:

```markdown
> Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante.
>
> &mdash; <cite>Source Title<cite>
```

### Result:

> Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante.
>
> &mdash; <cite>Source Title<cite>

# Other options

Bootstrap has lots of fun classes and with the ability to place a div and style it anyway that you want you can do the following to spruce it up.

### Well:

```markdown
:::{.well}
> Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante.
>
> &mdash; <cite>Source Title<cite>
:::
```

### Well Result:

:::{.well}
> Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante.
>
> &mdash; <cite>Source Title<cite>
:::

And don't worry, we can get extremely crazy.

### Panel:

```markdown
:::{.panel .panel-primary}
:::{.panel-body}
> Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante.
> 
> &mdash; <cite>Source Title<cite>
:::
:::
```

### Panel Result:

:::{.panel .panel-primary}
:::{.panel-body}
> Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante.
> 
> &mdash; <cite>Source Title<cite>
:::
:::

This just sparked my interest and thought I would see how far I could take it. Hope someone finds this useful.  

Thanks,

Jamie
