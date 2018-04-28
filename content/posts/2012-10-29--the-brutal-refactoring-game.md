---
title: "The Brutal Refactoring Game"
date: 2012-10-29T10:08:46Z
---

Let's play a game.

The rules are simple: write some code. Oh, and you have to do it right.
That means if you break one of the following rules, courtesy of the
brilliant [Adrian Bolboaca](https://twitter.com/adibolb), someone will
be there to slap your wrist.

1.  Lack of tests
2.  Name not from domain
3.  Name not expressing intent
4.  Unnecessary `if`
5.  Unnecessary `else`
6.  Duplication of constant
7.  Method does more than one thing
8.  Primitive obsession
9.  Feature envy
10. Method too long (\> 6 lines)
11. Too many parameters (\> 3)
12. Tests: not unitary
13. Tests: setup too complex
14. Tests: unclear action
15. Tests: more than one assert
16. Tests: no assert
17. Tests: too many paths

That's a lot of rules. The idea is to have a bunch of people hovering
around, looking out for these code smells. A smell being a hint of a
problem, not a problem in itself, which means that even something that
looks fine can still be flagged. Once something is highlighted, you have
to stop and fix it immediately. You can't wait.

There's a reason Adi calls this game "brutal".

I have to apologise for taking so long to write this post. We ran this
session at the
[LSCC](http://www.meetup.com/london-software-craftsmanship/) almost a
month ago, and I think it went really well. People worked in pairs on
implementing tic-tac-toe in whichever way they deemed the "right" way.
We weren't so fussed about the approach—while design is important, it
wasn't the focus of this exercise. What was interesting was the routes
people took to implement their solutions: they all ended up breaking one
of the rules, despite the fact that they were up on the big screen right
in front of them. And you have to wonder, why is that?

The rules people broke the most were \#2 (name not from domain) and \#4
(unnecessary `if`). I have to admit, I'm a bit harsh when it comes to
conditionals: I'd argue that no `if` is necessary when implementing the
rules for a game such as tic-tac-toe. They are when you're dealing with
user input, but that's about it, and no one got that far in an hour and
a half. I'd be incredibly impressed if they had. People hated it when I
flagged this, but they mostly found that the end result implementing it
without (using polymorphism, for example) was much cleaner. It usually
ended up moving behaviour from many places into one and giving it a
name, Which conveniently solved \#2: that new fellow almost certainly
got a domain-specific name.

The majority of these rules stem from two areas: duplication and a lack
of domain clarity. Some are obvious, such as \#6 (duplication of
constant), but some need a bit more thinking about. If you have a method
that does more than one thing (\#7), it's almost certainly going to be
named according to its behaviour and not its responsibility in the
domain, which means that the language used to describe it is unlikely to
be shared among the entire team. Focusing on extracting domain objects
that do one thing and do it well solves this one and most of the others.
If it's well-tested, that really does take care of the rest.

There are a few other personal favourites among this set of rules. \#8,
primitive obsession, is something that's extraordinarily hard to fix in
the LSCC's favourite languages, Java and C\#. Wrapping concepts such as
identifiers and HTML in objects just makes them harder to deal with, and
creating `Price` objects for your prices rather than passing around
`double`s makes the arithmetic so, so ugly in Java. (Gotta love operator
overloading.) Another one is \#13 (tests: setup too complex). I'm
surrounded by tests where the entire world is mocked (a side effect of
\#11—too many parameters), and I spend far too much time rewriting them
to construct what they need and mock only what's necessary. This makes
it so much easier to break the object apart later.

This game is a rebellion against the attitude of "I'll do it later"—the
mindset that causes us to leave code in a terrible state because we just
can't be bothered to fix it right now. Just because step three of the
TDD cycle is "refactor" doesn't mean the red and green steps can be
shoddy, because we don't always refactor. As Jeffrey Mayer says, if you
haven't got the time to do it right, when will you find the time to do
it over?
