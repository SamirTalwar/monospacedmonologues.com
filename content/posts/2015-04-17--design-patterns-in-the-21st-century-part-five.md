---
title: "Design Patterns in the 21st Century: Conclusion"
slug: design-patterns-in-the-21st-century-part-five
date: 2015-04-17T16:39:27Z
aliases:
  - /post/116651319855/design-patterns-in-the-21st-century-conclusion
---

This is part five of my talk, [Design Patterns in the 21st Century][].

[design patterns in the 21st century]: http://talks.samirtalwar.com/design-patterns-in-the-21st-century.html

---

Over the past week, we've seen three examples of design patterns that can be drastically improved by approaching them with a functional mindset. Together, these three span the spectrum.

<!--more-->

- The Abstract Factory pattern is an example of a **creational** pattern, which increases flexibility during the application wiring process
- The Adapter pattern, a **structural** pattern, is a huge aid in object composition
- The Chain of Responsibility pattern is a good demonstration of a **behavioural** _anti-pattern_ that actually makes the communication between objects _more_ rigid

We took these three patterns, made them a lot smaller, removed a lot of boilerplate, and knocked out a bunch of extra classes we didn't need in the process.

In all cases, we split things apart, only defining the coupling between them in the way objects were constructed. But more than that: we made them functional. The difference between domain objects and infrastructural code became much more explicit. This allowed us to generalise, using the built-in interfaces to do most of the heavy lifting for us, allowing us to eradicate lots of infrastructural types and concentrate on our domain.

It's funny, all this talk about our business domain. It's almost as if the resulting code became a lot more object-oriented too.
