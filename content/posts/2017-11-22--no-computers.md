---
title: "No Computers"
slug: no-computers
date: 2017-11-22T08:00:28Z
aliases:
  - /post/167762050339/no-computers
---

On Saturday, I helped run the Cambridge instance of [Coderetreat][], 2017 edition as part of the [Cambridge Software Crafters][].

It was a really fun day, and I enjoyed it thoroughly. Today, though, I'm not going to talk about the whole day. (If you want to read about what it's like, [I wrote a post about it five years ago][post: global day of coderetreat].) This time, I want to concentrate on just the first session.

This one was new to me, but [Amelie][@ameliecornelis] and [Alastair][@alastairs] been doing it in Cambridge for a long time. The task is the same as always: implement [Conway's Game of Life][]. The constraint, however, made a lot of people uncomfortable.

Pen and paper. No computers.

<!--more-->

This initially stumped a lot of people. It was really interesting to see people struggle with the idea of writing a test using paper, not a computer. After all, it's just a manual test at that point, right? It's not like you can automate it.

So how do you get around this? Well, you make your tests very easy to implement and run.

{{< asset-figure "Conway's Game of Life tests on paper" "2017-11-22--conways-game-of-life-tests-on-paper.jpg" >}}
Reproduced because I forgot to take photos.
{{< /asset-figure >}}

Paper opens up avenues that are typically very difficult in code; in this case, it lets us draw inputs and outputs that we can parse really easily without having to engage the analytical portion of our brain. In my experience, allowing myself to use the intuitive part of my brain means I can do things like run a bunch of scenarios in parallel instead of having to evaluate each one separately. It also uses way less energy. (Way more on this topic in [Thinking, Fast and Slow][].)

By avoiding the computer, we can skip the translation step and go straight to the heart of the problem.

As developers, engineers, coders, programmers, or whatever you want to call yourself, we're often _really_ bad at going to the whiteboard or the sticky notes and drawing things out. We don't just need this for high-level design, but low-level exploration too.

I'm gonna be doing a lot more of this.

{{< asset-figure "Conway's Game of Life on paper" "2017-11-22--conways-game-of-life-on-paper.jpg" >}}
And eventually, they figured out how to have fun.
{{< /asset-figure >}}

[@ameliecornelis]: https://twitter.com/AmelieCornelis
[@alastairs]: https://twitter.com/alastairs
[cambridge software crafters]: https://www.meetup.com/Cambridge-Software-Crafters/
[coderetreat]: http://coderetreat.org/
[conway's game of life]: http://monospacedmonologues.com/post/13794728271/global-day-of-coderetreat
[post: global day of coderetreat]: http://monospacedmonologues.com/post/13794728271/global-day-of-coderetreat
[thinking, fast and slow]: http://amzn.to/2AZD9M7
