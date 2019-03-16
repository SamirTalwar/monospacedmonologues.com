---
title: "Facilitating Better Code Reviews"
slug: facilitating-better-code-reviews
date: 2017-11-03T08:00:12Z
aliases:
  - /post/167078677169/facilitating-better-code-reviews
---

Over the weekend, I asked a lot of people a few questions about code reviews.

I have an agenda. [We're working on a product that intends to take the pain out of code review.][prodo.ai] We want to make the best product possible, and that starts with understanding where the pain is.

The data in my survey is biased towards the sort of people that read this blog. So take it with a grain of salt, and if it doesn't resonate with you, comment! I'd love to hear from you.

<!--more-->

## Why code review?

Code reviews are a pretty charged topic for many developers. Some argue they don't work. Many prefer to pair-program instead. Of those that use them frequently, there are umpteen different styles—over-the-shoulder, pull/merge requests, meetings, etc. There are teams that pick out every spelling mistake and teams that just look for massive security flaws or bugs that will cause downtime.

What this tells us is that they're pretty popular. If they weren't, no one would have an opinion in the first place.

<figure>
  <p><img src="https://imgs.xkcd.com/comics/duty_calls.png" alt="xkcd #386: Duty Calls"/></p>
  <figcaption><a href="https://xkcd.com/386/">Obligatory xkcd.</a></figcaption>
</figure>

So, given that many teams use code reviews as a technique to improve code quality, how can we make them more efficient, more effective, and most of all, more fun?

## Setting the scene

[SmartBear][] have been publishing [The State of Code Review][] for a number of years now, and wrote the book, [The Best-Kept Secrets of Peer Code Review][]. A lot of our work is based on their research.

The latest edition of The State of Code Review claims:

> Workload, time constraints, and manpower are the biggest obstacles to code review.

We wanted to understand what it is that's stopping people from jumping into code review. There are so many questions we wanted to ask, but with the aim of keeping the poll brief, we settled on one:

<blockquote class="twitter-tweet" data-conversation="none" data-lang="en-gb"><p lang="en" dir="ltr">1/3. How long does it usually take you to do a code review?</p>&mdash; Samir Talwar (@SamirTalwar) <a href="https://twitter.com/SamirTalwar/status/921680972608933889?ref_src=twsrc%5Etfw">21 October 2017</a></blockquote>

(If you can't see the poll, click the date to view it on Twitter.)

10–20 minutes is common for a review. This is a healthy amount to spend; much more and focus drifts. We know from SmartBear's research that this is usually enough to thoroughly review about 50 lines of code changes (in a large code base), but my gut tells me the review submissions are, on average, much bigger than this. The size will vary from team to team (or perhaps even between individuals in the same team), but 50 lines… I think I spat out 4 pull requests bigger than that between meetings on Tuesday.

So if people are making large sets of changes, what can we do to make this manageable for reviewers? A number of ideas come to mind for a code review assistant:

- breaking apart the changeset into cohesive parts, and getting a review for each one;
- allowing the reviewer to look at high-level changes before low-level ones;
- drawing the reviewer's attention to code that diverges from the norm;
- making the code interactive, letting the reviewer mess with it to see how it behaves;
- admonishing the programmer for doing too much at once;
- and so on.

It turns out that past the common tooling in code review software (i.e. reading a diff and commenting on it), there's a lot that's missing on the social side. Our tools and processes encourage certain practices inherent in the way they're designed, and often these practices are emergent—that is, we never intended them, but they came about as a result of establishing the process. If the tool is slow to load, people will review less often, which will make programmers more likely to submit large changesets so they can spend less time blocked. More subtly, if changesets are large, people are more likely to skim the changeset or skip parts entirely, resulting in poorer code quality.

We believe in making machines work for humans. It's time to start thinking about the behaviours our tools encourage, and whether they're right for us.

## Delivering value

> Code review remains the number one method for improving code quality.

There's a reason people review code (and sometimes enforce it). We wanted to find out a little more about why.

<blockquote class="twitter-tweet" data-conversation="none" data-lang="en-gb"><p lang="en" dir="ltr">2/3. What&#39;s the most important benefit of code review?</p>&mdash; Samir Talwar (@SamirTalwar) <a href="https://twitter.com/SamirTalwar/status/921681193078272000?ref_src=twsrc%5Etfw">21 October 2017</a></blockquote>

This really helped us clarify what people (or, at least, my bubble of people) are looking for when they review code. There's a lot of different areas in which we can derive value, but for many, they're looking to make sure that everyone understands and agrees with the changes made. Personally, I'm a big fan of this, because it changes the conversation from "no, do this" to "yes, and also this!" Providing a gateway to ask and answer questions really helps with healthy team dynamics. After all, software is a human endeavour: we work with pure thought-stuff, collaboratively creating something out of nothing. Communication is key.

After understanding the changes made, we can ensure that they check both boxes:

- design a solution that targets the problem at hand
- implement the solution to a sufficient standard of quality

Paraphrasing [Steve Freeman][@sf105], you need to solve the problem right, but you also need to solve the right problem.

For many of us, code review is the last reasonable port of call for verifying these. While we can always fix them later, the cost goes up by orders of magnitude, especially if we realise the solution is wrong only after customer feedback. It's incredibly important that the whole team agrees with the solution (or [disagrees and commits][disagree and commit]), and understands it to the degree that they can maintain it if and when something goes horribly wrong.

Code is hard, but people are harder.

## Minimising cost

> 1 in 5 respondents on development teams of 50+ said they either disagreed or strongly disagreed that they were satisfied with the quality of code they help build.

We all have problems with sub-par code. Often the question is not "How do we fix it?", but one step earlier: "Is there a problem?"

<blockquote class="twitter-tweet" data-conversation="none" data-lang="en-gb"><p lang="en" dir="ltr">3/3. What&#39;s the hardest part of code review?</p>&mdash; Samir Talwar (@SamirTalwar) <a href="https://twitter.com/SamirTalwar/status/921681356400349185?ref_src=twsrc%5Etfw">21 October 2017</a></blockquote>

Despite its relatively low (but still substantial) value, many find it very difficult to identify defects in code submitted for review. There's many reasons for this, but we at Prodo.AI believe that it's partially down to a lack of tooling and the inability to explore quickly. While we're interacting with a text diff on our source code, spotting problems is very much trying to find needles in a haystack.

There's a bigger problem here though: there's a dependency. To find bugs, you first need to understand the code, because you can't determine whether something's really a bug or not until you really get it. Understand the problem, then understand the solution, and only then can you determine whether the solution works, and whether the solution matches the problem at all.

So even fixing minor bugs requires a deep understanding of code. In today's development environment, the code is always changing, and keeping on top of it is a full-time job, even without contributing. Understanding every moving part of a large application is practically impossible. Without the right tools to understand the source code underpinning our applications, we can't do a good enough job, either writing or reviewing.

## So what?

So it's time to do better. The tooling is getting better, but not fast enough. It's not enough to have better formatters and linters: we need products that allow us to explore the code, and help us do so.

Of course, I have an agenda.

[Prodo.AI][] is creating the world's first ML-powered code review engine. With us, you won't have to go spelunking to understand what's going on. We bring the information to you.

And we'd love to work with you. [Get in touch.][samir@prodo.ai]

[prodo.ai]: https://prodo.ai/
[smartbear]: https://smartbear.com/
[the best-kept secrets of peer code review]: https://smartbear.com/SmartBear/media/pdfs/best-kept-secrets-of-peer-code-review.pdf
[the state of code review]: https://smartbear.com/resources/ebooks/the-state-of-code-review-2017/
[@sf105]: https://twitter.com/sf105
[disagree and commit]: https://en.wikipedia.org/wiki/Disagree_and_commit
[samir@prodo.ai]: mailto:samir@prodo.ai

<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
