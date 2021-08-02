---
title: "What to refactor"
slug: what-to-refactor
date: 2021-08-02T16:00:00Z
---

_[I originally posted this on Twitter.](https://twitter.com/SamirTalwar/status/1417516214839037953) Thought I'd update it and turn it into an article._

I recently spent a couple of weeks refactoring a large chunk of an API we use at work to integrate our software with third-parties. [All in all, it was 17 changesets](https://github.com/digital-asset/daml/pulls?q=is%3Apr+%5BKVL-1002%5D+in%3Atitle+sort%3Aupdated-desc), most of which were refactoring the code to make it easier to switch.

I really enjoyed this work, and I wanted to share how I know _what to refactor_.

We're introducing a new (Scala) API ("v2") to replace an old one ("v1"). For a while, we’ll need both functioning in parallel.

So the plan is:

1. Add (unstable) interfaces for the v2 API.
2. Create adapters back to v1.
3. Port internal code to use v2. Use adapters.

We added the new API and introduce some adapters. So far so good. Next, I had to migrate internal code to the new API. So I start by changing the code. Something breaks. So I change that too, committing with each step. The next thing breaks. And so on.

Eventually, I get to something that isn’t a 1-to-1 mapping, so I can’t just switch it over. I need to make some larger changes.

At this point, I commit what I have so far, and go back to the `main` branch. (Or sometimes I stash.)

Next, I go to that "problem area", the thing I needed to change. And I start refactoring. The goal here is to make the switch easy. So typically, it’s either:

1. Identifying similar things and creating more adapters, or
2. Sharing code a little more.

Once I’ve cleaned that up, I commit it to a new branch, rebase my old one onto it, and verify it helped. Switch, improve, commit, rebase.

If it did, I open a PR with just that change. I get it merged, and then continue. And repeat. If not, I keep working on it. Sometimes I'll scrap the work and try again, if it feels like the change has become too big. Or I start to recurse; switching to a new branch and doing something smaller. (I highly recommend not going more than two levels deep, for your own sanity.)

This process also helps in making sure that code is fully covered with tests. Because I'm working in a small area, it's usually not a problem to add another test case. I'm not trying to improve coverage across the entire codebase, just the small area that I need to tweak.

Once those changes are merged in, I can make some more progress, until I hit another large change. So I repeat the process. Switch, improve, commit, rebase.

By doing this, I keep the changes small and focused. I also force myself to implement on the old code, which I know works.

Refactoring is tough for a few reasons. It touches a lot of code, you can break things easily, it’s hard to know how much to do, and it’s often not clear if you’ve actually improved anything. By refactoring blockers, you can keep it to just the changes you need. Switch, improve, commit, rebase.

Here's my rule. If it takes me more than a few minutes (let's say 15, but less is better) to make the change, I stop what I’m doing, and ask myself: "can I do a smaller thing"?

The answer is pretty much always yes.

Baby steps are often faster than a sprint, if they help you decide the direction.
