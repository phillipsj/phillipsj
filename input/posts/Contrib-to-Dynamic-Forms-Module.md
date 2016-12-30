---
Title: Contrib to Dynamic Forms Module
Published: 10/1/2015
Tags:
- Orchard
- Dynamic Forms
RedirectFrom: blog/html/2015/10/01/contrib_to_dynamic_forms_module.html
---

Orchard CMS has this really cool module called Dynamic Forms.  It allows users to create forms that can create submissions, bind to content types, or tie into workflows. It is really powerful, but still a little rough around the edges. The new 1.9.2 release is going to provide lots of polish to this feature.

One item I noticed today was that there are form fields for most types of inputs that you can create for content.  However, there is not a form field for URLs. Probably not a big deal, however the particular reason that I am using Dynamic Forms is for a content type that does have a URL field and that input needs to be validated. So I quickly got in and got dirty. I created a URL form field and just finished my pull request.  I hope it get accepted. If you would like to take a look you can hope over to my [github](https://github.com/phillipsj) and take a look.