---
series:
  - "Lessons from a failed startup"
title: "Code is a liability; ship without coding, if possible"
slug: lessons-from-a-failed-startup--code-is-a-liability
date: 2022-06-23T18:00:00+02:00
---

In failing to build a company, I have learned many things. Core to all of them is that a company is not a product. Ideas change, products change, people change. We “pivot”, rapidly, relentlessly, sometimes ruthlessly.

Managed well, change is a catalyst. Managed badly, it can be catastrophic.

In this series, I try to explain the various ways in which I failed to understand this, and how I would endeavour to do better next time. You may notice that the style of these posts is more instructive than usual. Remember that these are mostly addressed to my future self, and as such, I am telling _myself_ what to do; you, my dear braniac, can do whatever you want.

---

So you’ve found your customer. You know what they ~~want~~ need. And now you’re going to write a custom piece of software for them.

Except… don’t do that. You haven’t really understood them yet.

First, solve their problem. Then, do it better, with code.

We were working on improving code review with an automated, intelligent bot. And in this instance, I think we did the right thing: we started reviewing a lot of code for our customers, manually. We identified common patterns across a few unrelated organisations, and _then_ we started to automate it.

We could have coded less. We still built a UI for ourselves, and the pipeline to funnel data to and from GitHub was pretty complex. Totally unnecessary, as it turns out; we scrapped that product in the end. The research that came out of it was very interesting, but we probably didn’t need to write a single line of JavaScript to enable that.

Our second product was totally wrong. A beautiful UI, very sophisticated tech… and not a single customer.

Code is horrendously expensive to write (in both money and time), a burden to maintain, and a [huge sunk cost that encourages you to sink more into it](https://thedecisionlab.com/biases/the-sunk-cost-fallacy).

Write as little as you can. Do it on paper for a while, with a pen. Use a spreadsheet—they’re ridiculously powerful, and while I’d argue that making a [spreadsheet _is_ coding](https://fenia266781730.files.wordpress.com/2019/01/07476773.pdf), it’s definitely _less_ coding than writing a UI from scratch.

If you can’t do that, use [Pipedream](https://pipedream.com/) (I love it), or Zapier, or whatever you like to connect the dots. Make a bookmarklet to augment a web page that does 80% of what you need already. Make a browser extension. Write a Twitter bot.

There’s a hundred different ways to outsource part of your application somewhere else entirely. You don’t have to keep it that way forever, but you may want to think hard about where you start.

### More in the series

{{< series-list series="Lessons from a failed startup" >}}
