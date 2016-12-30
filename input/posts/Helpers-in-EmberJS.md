---
Title: Helpers in EmberJS
Published: 2014-11-04 19:00:00
Tags:
- EmberJS
- Helpers
- Handlebars
- Ember-CLI
RedirectFrom: blog/html/2014/11/04/helpers_in_emberjs.html
---

EmberJS uses Handlebars as its template engine. To extend it, you create what Ember calls helpers. There are several ways in Ember to tackle a problem, but some are more optimal than others.

I needed to create tags that use the **mailto** and **tel" attributes. So achieve this I created helpers so my templates are a little more semantic to read and understand what is happening.

The first helper I created was a mailto helper. Using Ember-CLI is a nice way to get started. Remember that helpers kind of require a multipart name, so make sure not to create one with a single name as it tends to generate errors in EmberJS. Another tip is to make sure that you wrap your html tag in the Ember.Handlebars.SafeString method so it doesn’t escape the html when rendering.

Getting Started:

Lets create the mailto helper to start.

'''
$ ember g helper mailtoLink
'''

Now navigate to the helper file and add this code.

```
import Ember from 'ember';

export function mailtoLink(input) {
   var mailTo = '<a href="mailto:' + input + '">';
   mailTo += input + '</a>';
   return new Ember.Handlebars.SafeString(mailTo);
}

export default Ember.Handlebars.makeBoundHelper(mailtoLink);
```

Now create the telLink helper to start.

'''
$ ember g helper telLink
'''

Now navigate to the helper file and add this code.

```
import Ember from 'ember';

export function telLink(input) {
  var tel = '<a href="tel:' + input + '">';
  tel += input + '</a>';
  return new Ember.Handlebars.SafeString(tel);
}

export default Ember.Handlebars.makeBoundHelper(telLink);
```

Now to use these you can just call these in your templates like so:

```
<p>Email: {{mailto-link email}}</p>
<p>Phone: {{tel-link phone}}</p>
```

Ember makes lots of things really easy, but sometimes it not very clear how to do others. 

Hope you find this helpful.