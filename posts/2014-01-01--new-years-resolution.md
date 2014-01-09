<!--
id: 71841647264
link: http://monospacedmonologues.com/post/71841647264/new-years-resolution
slug: new-years-resolution
date: Wed Jan 01 2014 12:41:01 GMT+0000 (GMT)
publish: 2014-01-01
tags: 
title: New Year's Resolution
-->


At work, we run monthly coding workshops to give people an opportunity
to hone their development skills. The idea is to provide an environment
in which the results don’t matter, letting people take their time and
try different approaches to the same problem without worrying about
deadlines. This was an initiative started by [Joe
Lea](https://twitter.com/JoeLea) and massively encouraged by me. Every
month, a different person facilitates the workshop, letting people learn
from each other as well as giving the facilitator a chance to practice
their teaching and training skills.

Rewind to the last week of November. A week beforehand, we found out we
didn’t have a facilitator, as work had got in the way and he was on the
wrong continent, so Joe asked me to put something together. The topic
he’d chosen was composition vs. inheritance, mostly out of spite towards
a particular piece of code he’d been refactoring all day. I agreed. It
sounded like lots of fun.

The next week, I thought about the workshop a lot, but I didn’t have
time to actually put anything together. Work kept getting in the way.
Finally, the day before the workshop, I managed to find a few hours to
get something tangible going. I originally wanted to write some code for
the exercise, but I didn’t have time to do that any more, so instead I
opted to use JUnit, inspired by Ivan Moore and Mike Hill’s workshop
presentation on [Replacing Inheritance with
Composition](https://github.com/hillmlogica/inheritance-to-composition),
in which they demonstrated the process using Fitnesse.

I already knew JUnit had unnecessary inheritance, but I didn’t know the
details. I proceeded to spend that evening hacking on it, working late
into the night. At about 3am, I gave up. I’d found some good examples of
where inheritance could bite you but hadn’t done much in the way of
example refactoring.

The next morning, I woke up, poked at it for a few minutes, decided I
should probably do my actual work to appease the customer I work with,
and settled into that. I forgot all about the workshop until after
lunch, at which point I panicked a bit, then shrugged my shoulders and
decided to play it by ear.

We had three hours to play with, so I decided to split up the workshop
into three chunks: understand the code, implement a new feature, then
refactor the code and implement it. What could go wrong?

Everything, it turns out.

I won’t say the exercise was a complete failure. I would say, though,
that I didn’t do nearly as good a job as I thought I could. I was tired,
so I didn’t pay much attention to people, and even disappeared for
twenty minutes in the middle. The code base I’d chosen was far too
complicated. People didn’t even know how annotations work, and here I
was asking them to change a library of dozens of classes and thousands
of lines which makes extensive use of them. It was just too complicated.
I was supposed to give people a toy to play with, and I’d given them the
real deal. When someone throws you in at the deep end, you’ll figure out
how to get to the shallows, but you won’t learn to swim.

All in all, I should never have agreed to run it. I didn’t have the time
or the energy to do a good job. I’d forgotten my limits, and my
colleagues wasted their time because of it.

So here’s my new year’s resolution: do better at fewer things.

