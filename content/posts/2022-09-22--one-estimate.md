---
title: "#OneEstimate"
slug: one-estimate
date: 2022-09-22T09:00:00+02:00
---

This started out as a [Twitter thread][].

---

#OneEstimate, or, why your estimates suck and why your stand-ups are boring.

Estimates have a pretty bad reputation at this point, at least in certain circles. (I am sure there is a much wider circle of Agile legionnaires or whatever they call themselves, shouting about how you must estimate every story using only powers of 7 or something, so that management can make plans stretching out to 2031. Fortunately, I don’t talk to those people.)

I agree with most of the arguments put forth by the [#NoEstimates][] crowd and friends. However, while I find estimates pretty much useless for planning and prediction, I _do_ find them useful for discussing a piece of work, with the goal of trying to understand a few things:

1. Do we all agree what we’re working on?
2. Do we vaguely agree on an approach?
3. Can anyone see a simpler way to solve this?
4. Is there anything we don’t know or understand very well?
5. Are there compromises we can make to do less work?

And so, I like _estimating_, I just don’t like estimates.

<!--more-->

There’s a caveat: for the above to work, your estimates have to be _tiny_, so that there's no room for unknowns or uncertainty to hide. A few hours, the amount of time between coffees, your hummingbird-like attention span, whatever. This means there can be only one estimate: the number, **1**.

**1** is the only reasonable estimate. That’s your limit. If it’s bigger than **1**, carve off a separate, tiny piece of work and estimate _that_. I highly recommend [GeePaw Hill’s heuristic, “Many More Much Smaller Steps”][many more much smaller steps], in which your change must (a) be very small, (b) be shippable, and (c) not make things worse. Repeat until you get something small enough.

**2**? [Far too big.][lunar logic estimation cards]

**0**? You’re kidding yourself.

**5**? You have no idea how long this will take. Just accept you don’t know and don’t plan that far ahead.

### I can't divide up this work smaller than (days|weeks|months)

Well, at least you're admitting it. This is very healthy. Well done you.

If you can't do something very small, think of something else you can do. For example, you might be able to refactor some code so that you _can_ do less work. Or you might be able to timebox a _spike_ in which you attempt the work, understand it better, and throw it away. Maybe you can write up an email and send it to the wider organisation, asking for feedback and ideas. Perhaps you can get into a room with a few people and throw some ideas around.

You could even decide to do something less grandiose, less ambitious, but much more achievable.

### Zero story points

I’ve worked in teams where some tasks were **0**. I’ve even worked on a team where three **0**s make **1**.

I like the heuristic from _Getting Things Done_, by David Allen: can you do the task in two minutes or less, right now?

If so, do it.

If not, it’s a task. Write it down.

### An aside: why people sleep in your stand-ups

Thanks to the Agile-Industrial Complex, teams in many organisations have adopted stand-ups, without really understanding the point. They often go like this:

1. Alice: Yesterday I made some progress on confabulating the whatsit. I’ll continue on that today.
2. Alice goes to sleep. Bob wakes up.
3. Bob: Yesterday I designed a foo. Today I’ll design a bar to go with the foo.
4. Bob goes to sleep. Carol wakes up…

I shall stop there. This happens because no one asks questions, which is the entire point of the standup. And no one asks questions because no one knows what any of these things are.

By reducing your task size to _very very small_, you achieve two things.

Firstly, because the whole team broke down the work, they all understand it.

Secondly, you can’t say “I’m continuing with X” in the standup. It doesn’t fly. If you started X yesterday morning, you should be done yesterday. Cue discussion.

1. Alice: Yesterday I made some progress on confabulating the whatsit. I’ll continue on that today.
2. Bob: Oh, that’s taking longer than expected. Is something wrong?
3. Alice: Yeah, turns out we didn’t understand a requirement. The whatsit needs to be perpendicular to the whaddyacallit.
4. Carol: That’s funny, I ran into David yesterday and apparently we’re getting rid of the whaddyacallit entirely soon. Maybe we can just do that first.
5. And so, a fruitful discussion emerges.

### Yes, tiny tasks. All well and good. But we must plan ahead!

I get it. Someone out there is demanding numbers so they can plan for the future, make promises to customers, figure out how much money they need to save now. These are important. Far too important to leave to a bunch of programmers sticking their fingers up in the air and shouting “**3**!”

So if a customer is demanding a feature, go ahead and just _make_ the smallest possible version of that feature. Make a small step. Ship something _today_ (or tomorrow; tomorrow is probably fine too). See how they like it. This will give you valuable information, including whether they really care about the feature at all, a better feeling for what a larger version might look like, and who else is interested in this functionality.

You can plan for the long term all you want, but if you’re in an industry with any kind of competition, the landscape will change under you far more often. A year-long plan is just going to get thrown away two months in anyway. If it’s really important, just do it now.

If you have 17 really important things, you probably have a different problem.

### The coastline paradox

[In a famous paper by Benoit Mandelbrot][how long is the coast of britain?], he demonstrates that the length of the British coastline depends on how closely you look and measure. If you use a 5km ruler, the coastline is far, far shorter than if your ruler is 1m. This is because coastlines, like all natural things, are (practically) infinitely rough when you look closely enough. Are the White Cliffs of Dover smooth, or should you count every bump on the rock? Your answer depends on your tool of measurement.

This isn’t just true for geography, the concept applies to planning the future as well. Perhaps you estimate a piece of work takes **3**. This is too big, so you carve off a piece which takes **1**. You then repeat the exercise and discover that the work has become _six_ pieces of work, each taking **1**. Not only that, there’s another fuzzy bit which you can’t break up, and so you admit you don’t understand it well enough and shelve it. By inspecting it more closely, this piece of work has more than doubled in size, and we are being more honest by saying “and there’s this bit we’ll figure out later; our tool of measurement (our collective understanding) isn’t granular enough to measure this yet”.

By discussing the work, it grew. Just like by looking at a piece of coastline in greater detail, it grew. It was always that length, but now we understand it better.

### My goodness, there are so many tasks now

Yes, you have now written down more things to do. They were there all along, but now they’re explicit.

Congratulations, you thought about your work before you got started. If nothing else, at least this might help you prioritise the work.

If there are too many tasks, perhaps consider throwing some away? You’ll never get to them anyway, and even if you did, the information you’ve captured will be totally out of date. Code doesn’t sit still, after all.

If it turns out they were important, they’ll re-emerge, and they’ll be better next time, because you’ll have more information.

### And so, fuck story points

There can be only **one**.

[twitter thread]: https://twitter.com/SamirTalwar/status/1548247699853414401
[#noestimates]: https://twitter.com/search?q=%23noestimates
[many more much smaller steps]: https://www.geepawhill.org/2021/09/29/many-more-much-smaller-steps-first-sketch/
[lunar logic estimation cards]: https://estimation.lunarlogic.io/
[how long is the coast of britain?]: https://en.wikipedia.org/wiki/How_Long_Is_the_Coast_of_Britain%3F_Statistical_Self-Similarity_and_Fractional_Dimension
