---
title: "Mean Time To Recovery, as a lifestyle"
slug: mean-time-to-recovery-as-a-lifestyle
date: 2019-05-28T16:00:00Z
---

> I don't have a plan, but I have half a dozen outlines for plans.

---

I recently made an observation about myself that I thought was worth sharing. It's both an explanation of how I operate and a realisation of the trouble this causes for other people.

I've never really been able to collaborate with other people; either I do things on my own or not at all. I've managed to get over this to an extent with techniques like pair programming, which enforces a kind of working structure by breaking the work into small, manageable pieces together, but by and large I kind of suck at it.

Took me about 30 years to figure out one of the reasons why.

<!--more-->

## Most People™

_(Warning: massive, unwarranted generalisations ahead.)_

As far as I can tell strictly through observation, Most People™ (including me, to an extent) seem to think that things will go well most of the time. When something does go wrong (for example, trying to get to the airport and finding out the trains aren't running this Sunday), a fairly normal reaction is to add one to the Failure Counter, attempt to resolve it as best we can, and make a bunch of apologies if this affects others.

If the Failure Counter starts ticking up too fast, we might see behaviour such as:

- carrying an umbrella (or a phone charger) at all times
- catching the early train, in case it's delayed
- booking a hotel for a trip six months in advance
- spending a month preparing for a job interview
- backing up their laptop routinely

Nothing wrong with these behaviours—they're all quite sensible, and I do some of them, because failing can be expensive. I carry a power brick even as I insist that I don't need my phone to survive, honest.

The interesting thing about these behaviours, from my standpoint, is that we're trying to anticipate the ways in which the future might mess with them, so that we can work around any issues.

## MTTF vs. MTTR

There's a common thread in modern sysadmin thinking that I love: instead of increasing your Mean Time To Failure (MTTF), work on decreasing your Mean Time To Recovery (MTTR).

For example, instead of worrying about your site being down less often, worry about bringing it back up faster and faster. Because if it takes a second to bring the site back up when it goes down, it can go down every other week and you've still got five nines (99.999%) uptime (that's downtime of ~30s per year).

Unlike MTTF, MTTR has a beautiful side effect: it encourages automation.

- Detecting downtime and bringing the site back up within a day requires no automation.
- Within an hour, you at least need to page someone ASAP and tell them it's down so they can fix it.
- If you want to be back up within a minute, the site needs to bring itself back up.
- And within a second? You're probably going to need full redundancy and a smart load balancer.

This isn't a panacea, of course—nothing is in life. Focusing on recovery is _really_ expensive up-front, both in time and money. When dealing with software, an MTTR mindset requires very good observability, excellent failure-handling, and multiple layers of redundancy. Increasing the time between failures, on the other hand, often just requires better testing. While definitely not trivial, full test coverage is way simpler (in that it has fewer moving parts) than full monitoring coverage.

In my experience, it's not a binary choice. There's a spectrum from focusing on MTTF to focusing on MTTR, and most operations pros are somewhere in the middle. The way Netflix talk about their work, I have to imagine they're pretty heavily focused on MTTR, but I imagine even they have some things where they just try to engineer them well and cross their fingers a little. Meanwhile, most organisations without Netflix's traffic will focus on not failing, because it's much simpler. (They just don't blog about it so much, because it's way more established.)

## MTTR 4 lyfe

Like operations teams, each of us have areas in our life where we work hard not to fail, and areas where we aim to recover quickly. I seem to operate a little differently from Most People™, in that MTTR is more prevalent in my life.

I don't plan things in detail by nature. I have a really hard time thinking past a week or two, and if I have to plan, I'm much happier when everything is a little flexible and I can change things in response to new information.

But when something goes wrong? I already know what to do.

**I don't have a plan, but I have half a dozen outlines for plans.**

- I always know an alternative route to my destination, and I try to allow time for it. I massively prefer living somewhere that has two unrelated modes of travel.
- I check whether hotels are available a month beforehand, but I tend not to book until a few days before I arrive.
- If I'm going for a job interview, I'm going for 20 job interviews, and my goal is to find a good match, not to work for any particular BigCorp.
- Everything on my laptop goes to SpiderOak, Dropbox, GitHub or whatever as soon as it can, and I have [a script that sets up large chunks of a new Mac][fygm] with minimal interaction.

In other words, failing is fine, as long as I recover quickly.

(There are also lots of occasions where I expect not to fail. It's a spectrum, remember.)

```
    MTTF ------------|------------ MTTR
           ^         |     ^    ^
           |        MP™    |    |
          TDD              |    |
                           | Netflix
                           |
                       me, often
```

The downside of all this, of course, is that it's costly. Making three plans is more time-consuming than one, and booking things last-minute means I often miss out on good deals. But it works for me… or at least, it used to work for me.

We can probably boil this down to different ways of feeling _secure_. Someone in an MTTF mindset might feel secure when they're _assured_—in the example of booking a hotel, when they know where they're going to be staying for the next two weeks. On the other hand, someone in an MTTR mindset might be looking for _control_—a quick exit where they can easily change what they're doing tomorrow.

[fygm]: https://github.com/SamirTalwar/fygm

## Being a grown-up

When I'm operating as an individual, this works really well. When I'm collaborating with someone else and they aim not to fail, rather than recovering quickly, this is a problem, because it appears as if I'm just not pulling my weight. If I'm ignorant of this, it's likely to stress the other person out and generally cause way more work for both of us.

It gets worse if I assume that the other person operates in the same mode as me. I've deleted large chunks of work, because who leaves important data on an EC2 server, right? (Turns out lots of people do this for good reasons and I will no longer delete disks without being really sure they're unused. Lesson learnt.)

I'm slowly learning to mitigate this, primarily by attempting to communicate way more clearly, but also by trying to recognise the modes and figure out if there's a mismatch. Can't say I'm making too much progress yet, but I hope that by recognising what's going on and talking through it, it'll allow everyone to play to their strengths and get things done well.

So, if you live/play/work with me, and you're sometimes exasperated at my inability to get things done "on time", now you know why. Hopefully this helps us have a better relationship.
