---
title: "The Social Networking Kata"
slug: the-social-networking-kata
date: 2013-04-30T10:36:40Z
aliases:
  - /post/49250842364/the-social-networking-kata
---

Last week, [Sandro](https://twitter.com/sandromancuso) and I had a lot
of fun running [our monthly hands-on
session](http://www.meetup.com/london-software-craftsmanship/events/115289022/)
for the [London Software Craftsmanship
Community](http://www.meetup.com/london-software-craftsmanship/). We
decided to make things more difficult for ourselves (and the attendees)
by combining two of our favourite sessions: testing with
[_BDD_](http://en.wikipedia.org/wiki/Behavior-driven_development), and
[_object
calisthenics_](http://www.bennadel.com/resources/uploads/2012/ObjectCalisthenics.pdf).
The ~~victims~~ lucky people had a choice of solving the problem using
BDD/ATDD, object calisthenics, or both. Of course, if they opted for
just the latter, TDD was still mandatory.

<!--more-->

Our original plan was to use the Bank Account kata: Sandro used it in a
previous session with object calisthenics and it worked well. On the
day, though, I decided I was bored of it and that we should write a new
one. Sandro had the bright idea of thinking in the realm of social
networks (paraphrasing his words, "Social networks are cool, bank
accounts are not."), and we went from there. A few minutes later, we had
something, and it went down really well on the night.

So, I present to you, our Social Networking kata.

Posting
: **A**lice can publish messages to a personal timeline

Reading
: **B**ob can view **A**lice's timeline

Following
: **C**harlie can subscribe to **A**lice's and **B**ob's timelines,
and view an aggregated list of all subscriptions

Mentions
: **B**ob can link to **C**harlie in a message using "@"

Links
: **A**lice can link to a clickable web resource in a message

Direct Messages
: **M**allory can send a private message to **A**lice

I hope you like it.

Now, in practice, no one is going to get past the **posting** and
**reading** requirements in a one-hour dojo. That's OK. Quite a few
people expressed an interest in taking it home and continuing the
exercise. And when you're done, you can always add more: pictures,
hashtags, whatever. It doesn't even require brainpower—just open up
Twitter and pick a feature.
