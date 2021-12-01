---
title: "Dysfunctional Programming"
slug: dysfunctional-programming
date: 2013-08-07T14:05:00Z
aliases:
  - /post/57611810234/dysfunctional-programming
---

There's a problem with learning a new programming paradigm: you often
have to learn a new language simultaneously. So at [SoCraTes
2013](http://socrates-conference.de/) in Germany, I decided I'd run a
couple of sessions designed to teach functional programming without
having to learn Haskell (when I wasn't sitting out on the terrace
explaining monads with a beer in one hand and a folding whiteboard on my
lap). The first time, it was a simple two-hour workshop, and the second
time, it was part of the code retreat, in which people applied the
concepts to implementing the Game of Life.

<!--more-->

In the past, I ran a workshop on functional programming in
object-oriented languages. This time, I reworded it a little bit, and
entitled the session "functional programming in your favourite
language". In this workshop, I gave people [an implementation of an
immutable list](https://github.com/SamirTalwar/Lists) and [an
explanation of how they work](/post/11969111291/comprehending-lists)
and set them to work determining whether a given poker hand contains a
pair. Easy, right?

Well, no. There's one rule: no mutation. What does this mean?

1.  No reassignment. Every named variable may only be assigned once. In
    Java and C\#, you can enforce this by declaring all variables and
    fields as `final` or `readonly`.
2.  No side effects. All behaviour, as well as all behaviour you invoke,
    must be completely pure. "Side effects" include I/O, random number
    generation and all other behaviour that depends on the software not
    running under a closed system. For the purposes of this exercise,
    assertions in your tests are OK, as we need some way to determine
    that the code does anything at all.
3.  All expressions must result in a value. This means that you cannot
    call void methods or side-effecting control flow such as `if`, `for`
    or `while` in C-based languages. This is because they encourage
    reassignment. Expression-based branching constructs such as
    `a ? b : c` or `b if a else c` in Python are perfectly valid.
4.  All functions must return a value.

All these rules apply not just to code you write, but also any code you
invoke. The methods you call must be implemented according to all of the
above rules.

Oh, and one more rule: you must not use a functional programming
language (Haskell, Lisps or other more esoteric languages) or functional
features (list transformations in Scala, Ruby or C\#, for example).
That's too easy.

Give it a try and let me know how it goes. This lot had fun.

![Dysfunctional programming at SoCraTes
2013](https://lh3.googleusercontent.com/--Oj-xgmIRCw/Ufz8Lws_xCI/AAAAAAAAAfc/Rqcg3d2nhDk/w1276-h957-no/1375534092829.jpg)

Next time on Monospaced Monologues: everything I learnt at SoCraTes 2013.
