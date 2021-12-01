---
title: "Amdahl's Corollary, For Teams"
slug: amdahls-corollary-for-teams
date: 2018-01-24T08:00:27Z
aliases:
  - /post/170069322435/amdahls-corollary-for-teams
---

The most efficient way to implement a piece of software is to do it all yourself. No time is wasted communicating (or arguing); everything that needs to be done is done by the same person, which increases their ability to maintain the software; and the code is by default way more consistent.

Of course, we don't make large pieces of software this way. We work in teams.

Turns out "more efficient" doesn't mean "faster". When there are more people working on the same problem, we can _parallelise_—do more at once.

When we break work up across a team, in order to optimise for the team, we often have to put _more_ work in, individually, to ensure that the work can be efficiently parallelised. This includes explaining concepts, team meetings, code review, pair programming, etc. But by putting that work in, we make the work more parallelisable, speeding up and allowing us to make greater gains in the future.

<!--more-->

## An Aside: Amdahl's Law

Amdahl's law can be formulated as follows:

$ S\_(latency) = 1 / ((1 - p) + p / s) $

In words, it predicts the maximum potential speedup ($S_(latency)$), given a proportion of the task, $p$, that will benefit from improved (either more or better) resources, and a parallel speedup factor, $s$.

To demonstrate, if we can speed up 10% of the task ($p = 0.1$) by a factor of 5 ($s = 5$), we get the following:

$ S\_(latency) = 1 / ((1 - 0.1) + 0.1 / 5) ~~ 1.09 $

That's about an 9% speedup. Eh, fair enough. If we can swing it, sounds good.

However, if we can speed up 90% of the task ($p = 0.9$) by a factor of 5 ($s = 5$), we get the following:

$ S\_(latency) = 1 / ((1 - 0.9) + 0.9 / 5) ~~ 3.58 $

That's roughly a 250% increase! Big enough that it's actually worth creating twice as much work; it still pays off, assuming the value of the work dwarfs the cost of the resources.

$s -> oo$, which means $p / s -> 0$, so we can also drop the $p / s$ term if we can afford potentially infinite resources at no additional cost.

$ S\_(latency) = 1 / (1 - 0.9) = 10 $

In other words, if 90% of the work can be parallelised, we can achieve a theoretical maximum speedup of 10x, or a 900% increase. This is highly unlikely, but gives us a useful upper bound to help us identify where the bottleneck lies.

## Generalising To The Amount Of Work

Typically, we start off with a completely serial process. In order to parallelise, we need to do _more_ work. It doesn't come for free.

This means that when computing $s$, the parallel speedup, we should divide it by the cost of parallelisation. For example, if the cost is $2$, that means that making the work _parallelisable_ (without actually increasing the number of resources) makes the parallel portion take twice as long as it used to. (The serial portion is unchanged.)

So, if we take the example from earlier, where 90% of the work is parallelisable _but_ it costs twice as much to parellelise, we'll get the following result:

$ S\_(latency) = 1 / ((1 - 0.9) + 0.9 / (5 / 2)) ~~ 2.18 $

It's still about a 117% increase in output!

However, if $p = 0.1$, then there's really very little point in adding more resources.

$ S\_(latency) = 1 / ((1 - 0.1) + 0.1 / (5 / 2)) ~~ 1.06 $

And if the cost of parallelisation is greater than the potential speedup, bad things happen:

$ S\_(latency) = 1 / ((1 - 0.1) + 0.1 / (5 / 20)) ~~ 0.769 $

Adding 4 more resources slows us down by 23%. Many of us have seen this happen in practice with poor parallelisation techniques—poor usage of locks, resource contention (especially with regards to I/O), or even redundant work due to mismanaged job distribution.

## So, What Does It All Mean?

<!-- prettier-ignore -->
Amdahl's law tells us something very insightful: when the value of your work is much greater than the cost, you should optimise for parallelism, not efficiency. The cost of a weekly two-hour team meeting is high (typically in the <span class="asciimath2jax_ignore">$1000s</span> each time), but if it means that you can have 7 people on the team, not 3, it's often worth it. [Delivering faster means you can deliver more.][gustafson's law]

Don't stop at optimising meetings. Pairing costs money, but it usually means way better team cohesion, which improves your ability to parallelise. Better to have 10 people working on 5 problems and doing a better job than it is to have 10 people working on 10 problems. The former will lead to fewer conflicts, fewer defects and a much more motivated team. In other words (and by words I mean algebra), $p$ and $s$ both go up way faster than the amount of work.

Yes, meetings and other collaboration enhancers are boring. But they're necessary. Just make sure you never lose sight of their purpose: to build a shared vision and style of work so that the team (or the organisation) works as one unit. This allows us to grow the team and benefit from the increased number of people on the job.

Conversely, if all the knowledge of how the product works is in one person's head, $p ~~ 0$. While there's no impact to efficiency this way, it limits our ability to produce, because one person can only do so much. Adding more people just makes things slower.

Legacy code, bottlenecks in the development pipeline, and re-work caused by misunderstandings all contribute to decreasing the potential parallelisation of our jobs. Turns out that Agile software development practices really do add value.

## Bonus Material

Now watch [J. B. Rainsberger][] explain the same thing in 7 minutes and 26 seconds.

{{< youtube WSes_PexXcA >}}

[gustafson's law]: https://en.wikipedia.org/wiki/Gustafson's_law
[j. b. rainsberger]: http://www.jbrains.ca/
