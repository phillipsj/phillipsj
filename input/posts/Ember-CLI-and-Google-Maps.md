---
Title: Ember-CLI and Google Maps
Published: 2014-11-19 19:00:00
Tags:
- EmberJS
- Ember-CLI
- Mapping
- GIS
RedirectFrom: blog/html/2014/11/19/ember_cli_and_google_maps.html
---

This evening I started working on a project that I realize Ember is the perfect
fit. The ability to create a custom data adapter to read from the Socrata Data Portal
solves some issues for me and ember data makes that easy. So I did a little search on
Ember Addons and found that there are several addons available.  I picked [ember-google-map](https://github.com/ember-admin/ember-cli-map)
since it seem to have the most features and appears very intuitve to use.  Once I ran the npm command
to install it, I ran ember serve and bam.  I was hit with the following error:

```
Refused to apply inline style because it violates the following Content Security Policy
directive: "style-src 'self'". Either the 'unsafe-inline' keyword, a hash ('sha256-...'),
or a nonce ('nonce-...') is required to enable inline execution.
```

After a little google-fu I discovered this github [issue](https://github.com/stefanpenner/ember-cli/issues/2174) which lead me to this ember addon, [ember-cli-content-security-policy](https://github.com/rwjblue/ember-cli-content-security-policy). After adding the
config section below, It resolved all 136 errors I was recieving in Chrome. It appears that this issue is only isolated to running the node express
server for development. I guess I will find out soon enough.

```
ENV.contentSecurityPolicy = {
  'default-src': "'none'",
  // Allow scripts
  'script-src': "'self' 'unsafe-eval' http://*.googleapis.com http://maps.gstatic.com",
  'font-src': "'self' http://fonts.gstatic.com", // Allow fonts
  'connect-src': "'self' http://maps.gstatic.com", // Allow data (ajax/websocket)
  'img-src': "'self' http://*.googleapis.com http://maps.gstatic.com",
  // Allow inline styles and loaded CSS
  'style-src': "'self' 'unsafe-inline' http://fonts.googleapis.com http://maps.gstatic.com"
};
```

I hope this post is found useful by others. I have a few other ideas I want to try and I am sure this is going to manifest itself again.