---
Title: 'Ember Helpers: Testing'
date: 2014-11-17T19:00:00
Tags:
- EmberJS
- Helpers
- Handlebars
- Ember-CLI
RedirectFrom: blog/html/2014/11/17/ember_helpers_testing
---

Following up with my last post, I forgot to address one of the key development practices that I am finding that Ember makes extremely easy, testing.  So I am going to show you how to test the helpers that were created in the previous post.

In the previous post we ran the following command:

```
$ ember g helper <helper name>
```

This command generates both the helper and its corresponding test. Open the corresponding test file for the mailToLink helper.  We are going to write a test that makes sure it generates the correct link.

```
test('generates correct link', function(){
  var result = mailtoLink('test@test');
  equal(result, '<a href="mailto:test@test">test@test</a>');
});
```

See how easy that was, the test for the telLink helper is just as easy:

```
test('generates correct link', function(){
  var result = telLink('8675309');
  equal(result, '<a href="tel:8675309">8675309</a>');
});
```

Really basic tests, but since Ember allows you to easily build your application in a modular fashion it should keep that code you do write very succinct and simple.
