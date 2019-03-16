---
title: "The Boy Scout Rule"
slug: the-boy-scout-rule
date: 2016-01-22T08:00:21Z
aliases:
  - /post/137802498751/the-boy-scout-rule
---

> The Boy Scouts have a rule: "Always leave the campground cleaner than you found it." If you find a mess on the ground, you clean it up regardless of who might have made the mess. You intentionally improve the environment for the next group of campers. Actually the original form of that rule, written by Robert Stephenson Smyth Baden-Powell, the father of scouting, was "Try and leave this world a little better than you found it."
>
> <cite>[by Robert C. Martin][the boy scout rule]</cite>

<!--more-->

Yesterday, I wrote about code comments. It's my opinion that most code comments suck. They're misleading, wrong, and most importantly a side effect of laziness. Comments like this:

    x += 7.5 // number of hours in a working day

Or this:

    // For some reason there is a race condition in `updateTotal`.
    // The odds of it happening twice are really low though.
    updateTotal();
    updateTotal();

Or, worst of all, this:

    // TODO fix for Sundays
    calculateEmployeeOvertime();

These comments make the code worse. Rather than fixing the root cause, the developer has chosen simply to document the problem.

Don't be that developer. Leave this world a little better than you found it.

Follow [the Boy Scout Rule][the boy scout rule].

[the boy scout rule]: http://programmer.97things.oreilly.com/wiki/index.php/The_Boy_Scout_Rule
