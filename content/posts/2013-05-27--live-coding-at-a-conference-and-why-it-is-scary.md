---
title: "Live Coding at a Conference, and why it is Scary"
date: 2013-05-27T10:25:00Z
---

![I'm speaking at I.T.A.K.E.](http://i.imgur.com/X6MvZiU.png)

In less than a week, I'm giving my first ever professional talk at the
[I.T.A.K.E. Unconference](http://itakeunconf.com/) in Romania. The
topic: [the four elements of simple
design](http://www.jbrains.ca/permalink/the-four-elements-of-simple-design),
and how functional programming is *absolutely necessary* to achieve
them.

I'm quite excited.

I'm also quite terrified.

You see, I don't like giving talks. I like showing people code and
letting them experiment by themselves. Usually I learn way more this way
round, and what's the point of teaching if you can't learn from it?

Unfortunately, you can't do that at a conference where you've been asked
to speak. Doesn't sit well with the attendees, who have paid good monies
to learn from you. (By the way, that fact right there is why I'm
terrified.) So I'll be coding live, taking imperative and
object-oriented code and showing how a touch of functional really makes
your code much better.

There was just one problem.

It turns out, much to my surprise, that there isn't a decent way to find
code that is quite good but broken in just the way you'd like. This is
unfortunate, but I understand why: indexing GitHub by terms such as
"kind-of-imperative and a bit Java as it was written in 2008" is tricky.
Even Google would struggle with that one, I think.

So I wrote my own: [Quacker](https://github.com/SamirTalwar/Quacker).
It's a Twitter clone that's kind of crappy (mostly intentionally) and
very much a toy for me to mess around with BDD, dependency injection,
object-oriented style, functional programming and lots more. Right now,
there's no functional code on there (it's on a secret branch hidden from
your prying eyes) but after the conference, I'll merge it in and the
current, imperative state of the code will become a tag, confined to
history, immortal but forgotten. (I hope. It's not very good.)

The intention behind Quacker is that it's a sizeable enough codebase
that interesting things can be demonstrated by changing things around,
but it's simple enough that you can figure it out and start changing
things to fit your needs fairly easily. If you want to show, for
example, the difference between code with dependency injection and
without, you can probably re-wire part of it in under an hour to
demonstrate your point. It's a bit enterprisey, enough to feel
realistic, but not enough that you can't get anywhere.

It's been fun writing it, but unfortunately, it's not as clean as I'd
like, even though that was one of the goals. Why? Because of deadlines.
Now, I haven't compromised completely—pretty much everything is fully
tested—but I have had to actually start working on the presentation
rather than just hacking on a random toy project.

Now the presentation is finally coming together, and I feel pretty good
about the result. I hope it goes well on Friday (and if not, you'll be
able to laugh at the recording later). My fingers are well and truly
crossed.
