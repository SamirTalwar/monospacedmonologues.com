---
title: "Anti-Pattern: Bending The Framework"
slug: anti-pattern--bending-the-framework
date: 2016-01-13T08:00:15Z
aliases:
  - /post/137209155001/anti-pattern-bending-the-framework
---

[Wolfram Kriesing][@wolframkriesing] and [Jim Suchy][@jsuchy] were talking about frameworks on Twitter. I thought I'd get involved.

[@wolframkriesing]: https://twitter.com/wolframkriesing
[@jsuchy]: https://twitter.com/jsuchy

{{< tweet wolframkriesing 685582663118385152 >}}
{{< tweet wolframkriesing 685582805036830720 >}}

Specifically, they were talking about what happens when you come up against the walls of the framework. Because of the nature of frameworks, implementing certain pieces of behaviour is often unreasonably difficult, usually because the framework itself was not designed with capabilities for that particular functionality.

<!--more-->

They discussed the relative merits of working around the framework, bending it to their will or just abandoning it for that functionality, but pretty quickly, Jim decided that the latter made much more sense.

{{< tweet jsuchy 685585160931258368 >}}

I completely agree. By its nature, a workaround will necessarily be a headache for every developer who comes across that piece of code in the future. It won't look like anything else in the project, which means people will have to learn something new just for that one bit of functionality. It won't fit the framework's mould, which will make it much harder for people new to the project to understand it. It will probably be quite arcane, as most frameworks don't make it easy to work around them—often, dark magic such as reflection is required to access parts of objects and modules that aren't usually available, and invoking them in undocumented ways makes upgrading a nightmare as the interfaces change, functions disappear and the underlying behaviour does something completely unexpected. And because of all this, hacks around the framework are a major source of bugs, not just initially but throughout the lifetime of the project.

So what's the alternative? Well, in a web application, you could write a separate service using a different set of libraries or frameworks and call out to it over the network, even if it's on the same machine. You could rewrite that part of the application [using libraries instead of a framework, which I've written about before][don't call us. we'll call you.], allowing yourself much more flexibility where you need it. If your framework uses a meta-framework, like Rails uses [Rack][], you can investigate whether the meta-framework allows the functionality you're looking for. In this example, if Rails doesn't support something, we can run two web apps on different ports in the same process using Rack and use a different, more flexible web library such as Sinatra for the new stuff.

Of course, if all of that sounds too expensive, you could always decide not to implement the new functionality at all for now. This might sound crazy, but often in software development we treat the priority order of the backlog (or whatever you use) as if it's set in stone, whereas something like this, which drastically impacts the cost of delivering the feature, might mean that something else should take priority. Whether you can make the decision on your own or not, the decision should be made as soon as you find out the new cost, as it may outweigh the benefit.

Whatever you decide, make sure you're considering the whole cost. Bending the framework is very, very expensive. Make sure you've got the budget.

[don't call us. we'll call you.]: /post/46427054295/dont-call-us-well-call-you
[rack]: https://rack.github.io/
