---
title: "What is an interface?"
date: 2013-09-04T23:06:00Z
---

Interfaces are my favourite part of programming. They're the part that
makes me stop for a second (or a minute, or an hour, or a day) and
actually think about my job. Because my job isn't really about writing
code.

Before we get into what is about though, I want to define "interface".

What is an interface, anyway?
-----------------------------

As you probably know, I'm a big fan of the mentality driving
specification by example. So let's think about examples.

<!--more-->

The humble `interface` keyword
------------------------------

Java or C\#'s `interface` is probably the one you had in mind when you
read the title of this post. We use it to define the exposed methods on
an implementing class. That's what it does. But what's it *for*?

We usually use interfaces (Nat Pryce and Steve Freeman aside) when we're
creating code that a consumer sees, whether it's ourselves in another
area of our code, another developer on our team or perhaps even a third
party. They're often used to provide documentation to the user, either
using documentation tools such as Javadoc or simply good naming, and
expose the parts of the code base which do the useful thing our module
or layer provides.

Often, interfaces are also used to help decouple code. This works
particularly well when rather than trying to refactor classes to the
point where an interface can be extracted, we start with the interface
and define the concrete implementation later when we need it (like Nat
and Steve told you). This doesn't have to be an `interface` construct,
necessarily, but it does require we attempt to use its members before we
implement them, either through TDD or the "write your code, then
implement it" approach loved by Rubists.

This is getting somewhere, but before we start forming any conclusions,
let's look at a related type of interface.

The Application Programming Interface
-------------------------------------

APIs are great. I wish all applications had one or more. Whether it's
RESTful, uses RPC, works over HTTP, sockets or is purely in memory, all
programs should be able to talk to each other *somehow*. Though it's not
often explained in these terms, this is also the Unix programming model:
small programs that can invoke each other and have a common data
interchange format—plain text.

We've all dealt with APIs, both good and bad. The bad ones are the ones
I remember: the APIs that expose half of the functionality and make you
either reimplement the other half or jump through various hacks to
achieve your goal (I've been spending a lot of time writing Java
reflection code recently). The good ones, on the other hand, are simple,
discoverable, expose all functionality without leaky abstractions and
give us access to data in a generally tidy fashion.

A world of difference, and it's often in the way they were developed.
Good APIs are thought about before the product even exists, whereas bad
APIs are often an afterthought, attached to the product to simplify a
particular task whilst neglecting anything that deviates from the
requirements.

We mentioned Unix tools, so this is probably a good time to talk about
their particular brand of interface:

The Command Line Interface
--------------------------

This one scares a lot of people, including many developers. The CLI is
an intimidating place when you start, but as any `vim` lover will tell
you, once you dive in, you'll have a hard time retreating to the
comforts of your shiny Apple GUI. So what is it that the command line is
for?

Often, I find myself using the terminal on my Unix of choice when I have
something vaguely complex to do with text. At this point, I often don't
need to see the intermediate steps, just the overall output, and each
step is probably intricate enough that making a graphical user interface
with enough settings would probably result in something resembling [a
computer built in 1944](http://en.wikipedia.org/wiki/Colossus_computer).
Functionality, speed and the ability to iterate are paramount; if I need
beauty, I'll add it myself. So the best tools are those that spit out
something standard; instead of producing output that looks good for the
particular words on screen, show me something that looks the same no
matter what the output. Pretty-printing a table using hyphens and pipes
is great when I'm doing simple things, but as soon as I want to build it
into something more interesting, I need the capability to switch the
tool to showing tab-separated values instead. If you won't give me that
ability, `sed` will.

But sometimes we do care about shiny things. For that, we have:

The Graphical User Interface
----------------------------

The reason I own a Mac, ladies and gentlemen. It has a terminal when I
need it, but mostly it's just a very, very pretty rectangle that shows
me the Internet. And the trackpad is pretty amazing, too.

When I imagine a good GUI, a few applications come to mind. Google
Chrome is one, and the built-in Calendar app is another; Eclipse,
decidedly not. Why do I care? Because a good UI enables me to do more
things, and to get them done faster.

A good graphical user interface gives me the minimum number of tools to
get exactly what I want done. For a web browser, this means almost no
"chrome" at all (which is why Chrome is an ironic name). The fewer
buttons, the better. Hiding the menus, only showing bookmarks on the New
Tab page and not showing the Forward button unless it's necessary are
all great examples. Context-sensitivity is very important, which means
the designer has to understand the user, and think about their flow
through the application.

Sensible defaults are also incredibly important. If I can't see how to
do the task I have in mind just by looking at the controls available to
me, I'm not going to be able to guess. If I have to look at the Help
pages, you've lost my interest. I'll probably find something else that
does what I want.

The behaviour of the application should reflect the needs of the user; a
good GUI is one that is instantly obvious. This doesn't happen by
accident.

So what does all this mean?
---------------------------

Interfaces crop up everywhere in software development, from the very low
level to the very high. The reason they interest and challenge me is
because they're not easy; you're always thinking about the user when
creating them, and the user probably isn't you. Building an interface
requires you to step out of your personal universe and into someone
else's, and attempt to understand how it is they want the computer to
operate. It requires creating for the benefit of someone else.

In short, interfaces are about *design*.
