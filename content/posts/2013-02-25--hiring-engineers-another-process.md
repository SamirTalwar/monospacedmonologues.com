---
title: "Hiring Engineers, another Process"
date: 2013-02-25T16:21:00Z
---

This post was prompted by [Eran Hammer’s excellent article on
hiring](http://hueniverse.com/2013/02/hiring-engineers-a-process/) what
he describes as “non-conforming great talent”. It’s part rebuttal, part
agreement. It’s not about how [Palantir](http://palantir.com/) or [TIM
Group](http://timgroup.com/) hire—they both diverge from this on a
number of things, but simply my thoughts on the interview process.

"If you don’t have time to read this, we are not a good fit."
-------------------------------------------------------------

I think this is fair, but I also think it’s pretty specific to Eran. You
could interpret it one of two ways: he could be talking about reading
articles on hiring, or this article specifically. The former, I think,
is valid: people in a position to interview and hire should be open to
new ideas, and shouldn’t be ignoring posts simply because they’re not
cited in a textbook or written by someone more traditional. The latter
reflects Eran’s reality, but not the realities of most of us: he’s a
notable individual in a position to dictate the means of negotiation,
whether he’s the one in the hot seat or the one grilling.

"I got up and said, "I’m going home now"."
------------------------------------------

Eran goes into quite a bit of detail on “What Not to Do”, but it can be
summed up fairly simply: know what you’re looking for and don’t
compromise. We in the tech industry are in the enviable position of
having more jobs than people able to fill them by an order of magnitude,
and you should exploit this: if you don’t like the way a job is
explained to you, feel the questions you’re asked demonstrate a mismatch
between you and the role, or even get a bad feeling about the
organisation or your interviewers, walk out. There are plenty of other
jobs. You’ll have learned something about yourself, and you should use
this information to find something that’s a better fit to your expertise
and goals.

[Jason Wright](https://twitter.com/ukjasonwright) pointed out that this
should go two ways: the interviewer should remind the interview
candidate that the candidate is free to leave if he or she feels this is
going to be a waste of time.

In short, have some standards. Your interviewers do.

"I don’t phone screen. I don’t read resumes."
---------------------------------------------

Instead of resumes (or CVs), Eran favours your GitHub account. I love
this attitude: I do too. I often tell people that the first four things
I want to see on a CV are links to their GitHub account, Stack Overflow
profile, blog and Twitter account. (And it’s OK if some of those are
missing.) The problem is that there are plenty of excellent software
developers who do other things in their spare time. They don’t talk
about code outside of working hours. They arrive at the office at 9am,
and leave at 5pm sharp. And in the thirty-five hours they spend working
every week, they produce a ton of value. I think that passing on people
because they don’t have a public record or “an attitude” shows as much
of a bias toward a certain type of person as the traditional methods of
deciding whether someone is a viable hire. I’d never cold call someone
to attempt to get a job, and would have a hard time taking anyone
seriously if they called me out of the blue.

I’ve seen excellent engineers appear from all corners, with extremely
diverse personalities and backgrounds. To be honest, I don’t think I’d
ever say no to a first interview. Of course, with that comes volume. And
that leads me to my next point.

"I suck at writing code on demand."
-----------------------------------

That’s OK, because the first round is simply a technical test: write
some code for me to solve a very simple problem, then send it back. If
it’s good, I’ll ask you to come in, and we will talk about your code in
the interview. Eran explains this way better than I can (if you haven’t
read his article yet, I don’t know why you’re reading this).

After we’ve talked about that, we will write more code.

Sure, no one is great at walking into a room and coding on a whiteboard,
but I’m not asking you to build a system to operate a space shuttle. I’m
asking you to solve a simple problem. I don’t really care if you finish
it, and I definitely don’t expect you to produce code worthy of
shipping. If no code gets written but we have a great conversation,
that’s brilliant. In fact, the code is simply a driver for conversation.
I’m going to be interrogating you about everything you do, and you
should be confident enough in your decisions to defend them.

More than that, though, you should be good enough to solve this simple
problem in no time at all. You should be better: you should be
challenging my original proposal, explaining how tweaking the parameters
would make the problem go away altogether. You should be discussing
every area of the problem space with me before delivering a one-liner
that does exactly what’s needed (and probably not what I originally
wanted). The coding should be a tiny part of the interview compared to
the discussion before and after writing it. You’re writing all the code,
but the interview is far more reminiscent of a pair programming
exercise.

One thing that’s really important to me is your ability to react to
changes. It’s something that’s probably needed much more in
client-facing jobs such as mine than in Eran’s. If I change the
requirements afterwards, you should be able to cope gracefully. This
isn’t something that can be tested well in any situation aside from a
real-world scenario, but I can simulate it pretty well in the interview
room. What’s more, it *requires* a product to be produced there and
then, after the discussion. I’m a fan of agile software development: you
should be delivering quickly, showing me the end result, and reacting to
any and all feedback. And being able to take a step back, realise that a
previous decision doesn’t make sense given new information, and *fix
it*, rather than letting the problem fester.

"I’m not going to make shit up."
--------------------------------

Eran has definitely convinced me about a few things. The first:
whiteboards suck. From now on, I will ask someone to write their code on
a real computer, preinstalled with editors, IDEs and support for every
language imaginable. I’ll even set up some VMs specifically for this, so
they can use their favourite operating system. It’s not as good as
asking them to write it on their own computer with their own `.vimrc`,
but hopefully it’s close enough.

Secondly: real problems are the best kind of problems. Most of our
development work is not about writing new code: it’s about changing old
code. Usually badly written, poorly maintained, untested code. So I’m
factoring in with an idea some of the members of the [London Java
Community](http://www.meetup.com/Londonjavacommunity/) have been
discussing: interviews focused on critiquing and refactoring are far
more informative than those focusing on solving a specific problem. I’m
going to grab some real code, anonymise it, translate it into five or
six different languages, and get the candidate to work on cleaning it
up, adding new features and changing old ones. I would prefer to give
them the original problem as the offline test and have them continue
working on it in the interview, but that’s a much bigger change to our
interview process.

Thirdly: longer interviews are better. I’ve heard this one from a few
people, including [Sandro Mancuso](http://craftedsw.blogspot.com/) and a
report of [Reevoo’s](http://www.reevoo.com/) interviewing practices.
Eran asks the candidate to write code beforehand, which is a great way
of extending the interview time without a huge cost, but I’ve seen some
information from [Barry
Cranford](http://uk.linkedin.com/in/barrycranford) of
[RecWorks](http://recworks.co.uk/) that this rapidly degrades when
everyone is doing it—no one puts much effort into solving the problem.
Sandro just takes a whole afternoon to interview someone. Reevoo
actually spend a few hours pair-programming with them on a real feature
or bug fix. I can’t pull this off at my current job right now, but I
think I’ll be pushing for something like this in the future.

Do’s and don’ts.
----------------

Just go read these. They’re so important. My favourite, which I’m going
to adopt immediately:

> Begin the interview describing your role in the team and allow the
> candidate to ask questions.

This is so obvious in retrospect I feel like an idiot for **not** doing
it.

"You references and past work is what we should really rely on for verifying your claims."
------------------------------------------------------------------------------------------

I agree with this statement completely, but I don’t think we’re there
yet. Most programmers don’t build portfolios like designers or artists
do. That should change, because more and more organisations are starting
to think like Eran, and if you don’t have some work on display, you’re
going to be left behind.

"Inspire others to break away"
------------------------------

Eran’s definitely inspired me to think more about recruiting. I wrote
this post partially as a way to try and get some concrete thoughts out.
I’d like everyone else to do the same. The status quo is awful, and the
only way it’s going to improve at all is if people tell others how
they’re making it better.
