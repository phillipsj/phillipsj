---
Title: 'Book Club: Confident Ruby'
Published: 2014-09-22 20:00:00
Tags:
- Book Club
- Confident Code
RedirectFrom: blog/html/2014/09/22/book_club_confident_ruby
---

I recently started ready the book “Confident Ruby” by Avdi Grimm. I have been a long time listener to the Ruby Rogues and I have been interested in this book for sometime. Since I started a new job and we didn’t have a book club, I thought this would be a good opportunity to be held accountable to read it.

I like the idea of writing confident code in general. I find myself writing lots of null checks, try-catch blocks, etc. and I really do think it clutters up your code, decreases clarity, and minimizes the story that you are trying to tell. Since Ruby is a dynamic language and I primarily work in a static typed language, so you have to think about how some of the patterns in the book
are applied. I discovered if I think in terms of interfaces, then I can use “duck typing” like features. This makes me think about using more interfaces along my application boundary to ensure that objects meet the criteria that I need so I don’t have to type check.

Another great point that was brought up was using the automatic conversion methods and features of the framework to ensure that inputs meet the criteria that your method needs. This makes me think more closely about how I have chosen to implement or not implement the ToString method on my own objects.

Hopefully, more of the patterns and ideas in the book are solidified and I hope to add examples of how these can be applied to the code that I write in .NET.

Thanks for reading!