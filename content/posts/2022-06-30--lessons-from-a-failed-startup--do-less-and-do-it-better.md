---
series:
  - "Lessons from a failed startup"
title: "Do less, and do it better"
slug: lessons-from-a-failed-startup--do-less-and-do-it-better
date: 2022-06-30T18:00:00+02:00
---

In failing to build a company, I have learned many things. Core to all of them is that a company is not a product. Ideas change, products change, people change. We “pivot”, rapidly, relentlessly, sometimes ruthlessly.

Managed well, change is a catalyst. Managed badly, it can be catastrophic.

In this series, I try to explain the various ways in which I failed to understand this, and how I would endeavour to do better next time. You may notice that the style of these posts is more instructive than usual. Remember that these are mostly addressed to my future self, and as such, I am telling _myself_ what to do; you, my dear prose compiler, can do whatever you want.

---

This is my mantra.

Think about your product. The thing you’re proudly creating to serve the needs of your customers.

It’s doing too much. What’s it doing that it doesn’t need to?

We often hear people talk about the Minimum Viable Product: the juxtaposition of:

1. the smallest, lightest,
2. yet purposeful and useful
3. thing you made.

Unfortunately, most approaches that I’ve seen to “minimise” the product have been by simply cutting features. Often, to minimise, you need to re-think.

At Prodo we first started out by automating some of the more menial parts of code review—typo detection, formatting issues, common JavaScript anti-patterns, automatically type-checking untyped JavaScript to catch edge cases, etc. While I think the idea was cool, we were quite unstructured in the kind of problems we were looking for, and as such, we ended up doing a little bit of everything, but not nearly enough to make our product _viable_: no one really wanted an automated tool that could catch `null` dereferences, but only 20% of the time.

What if we had focused on a niche? We could have made something that caught bugs related to the [OWASP Top 10](https://owasp.org/Top10/) security flaw categories, and nothing else. It would have seriously limited our scope, but we’d be able to quickly and accurately articulate the benefits, and security was a hot topic even in 2017. It might not have required _any_ machine learning, which we would have been a little sad about, but it’d be far cheaper to verify, make, maintain, and iterate upon.

(I’m not saying this would have worked, but I think it’d have had a better chance.)

Don’t just cut functionality. Ask yourself, is there a smaller, more focused niche you can target? As Seth Godin says, who’s your [minimum viable audience](https://seths.blog/2019/03/the-minimum-viable-audience-2/)?

Do less, and do it better.

### More in the series

{{< series-list series="Lessons from a failed startup" >}}
