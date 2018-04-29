---
title: "Start Simple"
slug: start-simple
date: 2016-01-08T08:30:16Z
aliases:
  - /post/136869919805/start-simple
---

Continuing in the theme of fresh beginnings, I wanted to talk about a famous quote:

> A complex system that works is invariably found to have evolved from a simple system that worked. A complex system designed from scratch never works and cannot be patched up to make it work. You have to start over with a working simple system.
>
> <cite>— John Gall ([Systemantics: How Systems Work & Especially How They Fail][], 1975)</cite>

<!--more-->

This is [Gall's law][], written by John Gall, a paediatrician and systems theorist. It's not specific to software, but it's pretty pertinent in our field. In his text, *Systemantics*, he encourages system designers to start simple and validate that the system really works before evolving it. In my mind, validation doesn't just mean, "does it do the thing right?", but also, "does it do the right thing?", which means talking to the consumer of your product constantly to ensure you're on the right track. As such, Agile software development and related practices have a very similar thinking to Gall's work behind them.

So why is it that technology companies often wait months before releasing their product?

If you're going to do anything right, you need validation, and people on the inside track are often the worst-placed to decide what consumers really want. Instead, ship it. If you're worried about leaking information, control who can see it, but don't work in a vacuum. Validate, figure out what you're doing right and keep doing it, and figure out what you're doing wrong and stop doing it. The alternative is to design a complex system from scratch. And, as Gall said, that never works.

And if you need something a little more software-related before you're convinced, just look at Linux and the work of the Free Software Foundation. [As ESR said:][The Cathedral and the Bazaar: Release Early, Release Often]

> Release early. Release often. And listen to your customers.
>
> <cite>— Eric S. Raymond, ([The Cathedral and the Bazaar][], 1999)</cite>

[Gall's law]: https://en.wikipedia.org/wiki/John_Gall_%28author%29#Gall.27s_law
[Systemantics: How Systems Work & Especially How They Fail]: http://www.amazon.co.uk/gp/product/0812906748/ref=as_li_tl?ie=UTF8&camp=1634&creative=19450&creativeASIN=0812906748&linkCode=as2&tag=monospamonolo-21
[The Cathedral and the Bazaar]: http://www.amazon.co.uk/gp/product/0596001088/ref=as_li_tl?ie=UTF8&camp=1634&creative=19450&creativeASIN=0596001088&linkCode=as2&tag=monospamonolo-21
[The Cathedral and the Bazaar: Release Early, Release Often]: http://www.catb.org/esr/writings/homesteading/cathedral-bazaar/ar01s04.html
