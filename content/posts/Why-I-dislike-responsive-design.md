---
Title: Why I dislike responsive design
date: 2014-05-15T20:00:00
Tags:
- Responsive
- Design
- Mobile
RedirectFrom: blog/html/2014/05/15/why_i_dislike_responsive_design
---

Lately I have been working on a project that uses responsive design. Initial it sounded like a great opportunity as I have not had the privilege to work on a responsive website that is GIS based. While it has in fact been a great chance to learn, it has enlightened me to the pitfalls of responsive design. Issues such as, when I am on a desktop and minimize the browser it switches to the mobile friendly version, however I am still on a desktop. If you use feature detection along with screen size then you have a fairly decent combination that will help with the issue preventing desktop and laptop screen issues when the browser is minimized. But, this lead to the an even more complicated issue, we now have touch on desktop and laptops. Now the combo of feature detection and screen size collapses. And this issue is the failure of responsive design in my opinion. Why should users on desktop and laptops have to compromise and why do mobile users have to wait for downloading a whole website or put up with sub-optimal design. I am starting to think that you really need to build two apps, one optimized for desktops/laptops and one that is optimized for mobile. The big kicker is both should be touch friendly. I am glad that I realized this today and I am looking forward to applying this approach to any new sites I create.
