---
title: "Refactoring to Feature"
date: 2013-07-03T13:26:55Z
---

*A note, while I've got you:* I've decided I will be posting a new
article every Wednesday for the forseeable future. Hopefully I can hold
this up. Writing one per week is going to be hard, but I think I can
handle it.

Now, onto the meat.

* * * * *

I've observed four main ways that people refactor.

The first, and most common, is not at all. This is usually because
there's a new feature that they just have to get done *now*, or is so
complicated that refactoring "wouldn't help". It's also often scheduled
to be done "later", where later is always some way off in the future.
Because procrastination is always healthy.

I'm going to assume you don't often go down that route, because you're
reading this and therefore care somewhat about the quality of your work.

The second, and also the second most common, is the "ad hoc" method.
This is when you refactor whenever something really bothers you *and*
when you have time. This is a manifestation of the boy scout rule
("leave the camp site, or code, in a better state than when you found
it"), and usually works pretty well. The code that angers you is
probably pretty bad, so focusing on that is a wise move, assuming it
doesn't demoralise you permanently or drive you insane.

This sounds reasonable, but the issue is that you only do it when you
have time. If you don't, you revert to option \#1. Got a deadline? Put
it on the technical debt list. (If you have such a list. Personally, I
feel they harm more than they help. But that's another discussion.) This
sort of unstructured approach to cleaning up your code generally gets
thrown away at crunch time, along with testing, documentation and any
other indication that you have any idea what you're doing.

The next is more proactive, and also the method recommended by TDD
aficionados. (Recommended, but not always practiced. Even among TDDers,
the previous technique is far more common.) The steps in test-driven
development are Red, Green, Refactor. The last one is the one that
concerns us. After making a test pass, you should look to see if you've
introduced any code that is less than stellar. If so, refactor. And have
a cookie. You did good.

So here's the fourth, and the one that really interests me. I don't know
if many others are doing this, and I'd love to hear from you if you do
something in any way similar. I know some people over at [TIM
Group](http://www.timgroup.com/) practice this, and if any of them are
reading this, I'd love to get their comments on how their approach
differs from mine.

The steps are as follows: you write a failing test. When the time comes
to make it pass, evaluate the difficulty of doing so. If it's not
trivial, stash your test using whatever version control system you have
in place, and refactor to make it easier. Then retrieve the test case
from the stash and fix it to work with your refactored code. If it's
still not simple, repeat.

I've heard variants of this called "refactoring to feature", because you
implement a new feature by refactoring until actually writing the
feature is basically no work at all.

The interesting thing about this is that it requires version control and
[baby steps](http://talboomerik.be/2012/01/16/taking-baby-steps/). You
can't run off into the distance without a safety net. Apart from being
able to store your test case somewhere sane, it allows you to throw away
all your refactoring if you decide you're going down the wrong path, or
if the feature request changes. Git is well-suited for this, but any
DVCS would work very well.

This method of implementing new features and changing existing ones has
served me very well over the last few months. It allows me to introduce
new code without creating any technical debt, making procrastination
impossible. It also helps me reason about the system architecture while
keeping me on track to implement new functionality, rather than cleaning
up for the sake of it. After all, if code doesn't need to change, who
cares how bad it is? Effort should be focused on the code that needs to
change often.

I'd love to hear if this works for you. Please give it a try next time
you start implementing a change to your product. And then let me know
how it goes.
