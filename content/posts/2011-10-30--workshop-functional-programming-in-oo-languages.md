---
title: "Workshop: Functional programming in OO languages"
slug: workshop-functional-programming-in-oo-languages
date: 2011-10-30T15:56:00Z
aliases:
  - /post/12118361399/workshop-functional-programming-in-oo-languages
---

As I mentioned on Wednesday, I recently ran a session on functional
programming in object-oriented languages. By that, I really mean
"languages that weren't designed with functional code in mind". This
ranges from Java, which doesn't let you treat functions as first-class
objects at all, to Ruby and Python, which have all sorts of cool
functional features but puts them in the corner so you don't have to
play with them if you don't want to. The idea of the workshop was to get
people thinking in terms of functions without having to learn an
entirely new toolset at the same time. Lots of people have told me they
want to try this at home, so here it is in text form for your coding
pleasure.

Key to the idea of functional programming is immutability—never mutating
existing information, only creating more. This embodies the idea of a
_function_: a black box that takes in data, processes it in some way and
then outputs something else. At no point does this function communicate
with the outside world except to deliver the result. It's side-effect
free, which brings us a whole host of benefits, such as parallelisation,
memoisation, laziness and reasonability. That last one is probably the
most important: it simply means that because there are no side effects,
the function is easier to understand and reason about. Understandable
code leads to happy coders.

<!--more-->

So here's the challenge. I have a poker hand—seven cards that look like
this:

    "4d 7h 8c 8d Td Js Kh"

Not the prettiest cards on the planet, but they're a lot easier to parse
than real ones. You'll notice they're sorted by rank. This will make
life easier for you.

Here's your task: tell me if I have a **pair** in my hand. For the hand
above, the pair consists of the eight of clubs and eight of diamonds. I
don't need to know which cards are in the pair though, just whether I
have one or not.

When you're done with determining whether the hand contains a pair, work
your way up through each of the poker categories. [Wikipedia has an
explanation of each
one.](http://en.wikipedia.org/wiki/List_of_poker_hands) For example, the
hand "2s 5s 7c 7s 8h Js As" contains a flush, which trumps a pair, so
the category is **flush**.

Right. Now to make it interesting. Immutability is key. To this end,
I've come up with a few rules you should follow.

1.  **No mutable types.** That means no arrays, or even mutable lists
    such as the lists bundled with every mainstream programming
    language. Java's `ArrayList`, Ruby's `Array`, Python's `list`… these
    are all out of bounds.
2.  **Don't write your own mutable types.** Really important. The state
    of your objects should not change during the lifetime of the object.
    If you're developing in Java, this means that all fields should be
    `final`. `readonly` in C\#. Everyone else, just don't do it.
3.  **Methods must end by returning.** Functions. One thing in, one
    thing out. Emphasis on the _out_.
4.  **Every single statement** (apart from the aforementioned return)
    **must be assignment to new variables only**. Again, mark them as
    `final` if you can.
5.  **No conditions or loops.** Essentially, no `if`, `for` or `while`
    blocks. These encourage mutation. The one exception is the ternary
    condition: `condition ? true_case : false_case` in Java, C\#, Ruby
    and JavaScript (and I'm sure many more). Python's equivalent is
    `true_case if condition else false_case`, which I always thought was
    backwards, but that shouldn't stop you from using it.

That should cover it. There are two more rules which are just as
important, but nothing to do with functional programming. The first is
to write object-oriented code. Use your language. It has all these cool
features. Don't forget about them. If you know them, try your best to
apply the rules of object calisthenics. You'll find yourself breaking
them a lot, because they don't always mesh well with functional
programming, but you should be aware you're doing so. (If you don't know
about object calisthenics, don't worry about it.)

The second: write tests first. Practice TDD as well as you can. How else
will you know you're done?

I'm not going to leave you completely in the lurch. You'll find
[implementations of the functional linked
list](https://github.com/SamirTalwar/Lists) for Java, C\#, Python, Ruby
and JavaScript on GitHub. I've also written [an explanation of said
list](http://monospacedmonologues.com/post/11969111291/comprehending-lists),
and [how to implement them in
Java](http://monospacedmonologues.com/post/12051343792/function). Each
one has `map` implemented on it already, and you're encouraged to add
methods to it as you need them. You'll also find they follow all the
rules set out above. That should get you started. If there isn't one in
your chosen language, it shouldn't be hard to reimplement.

I asked people in the workshop to pair, as it leads to discussion and
helps people get through the tricky bits. A couple of colleagues of mine
and I were also floating around to help. Unfortunately I can't do that
here, but I can definitely respond to the comments at the bottom of this
post, so if you have any questions, please ask.

When you're done, throw up your solution on the web somewhere and post a
link in the comments here. Even if you only do a little bit, I'd love to
see the results. I'll be posting up my own in a couple of weeks, after
people have had a chance to write their own.
