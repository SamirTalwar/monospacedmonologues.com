---
title: "Functional Reactive Serverless Architecture"
slug: functional-reactive-serverless-architecture
date: 2018-07-17T19:00:00Z
---

[*Originally posted as a Twitter thread.*](https://twitter.com/SamirTalwar/status/1019260400108531712)

I've been thinking a lot about serverless architecture and I've realised what bugs me about it.

This is gonna be a long one. Not gonna lie, I wrote a draft first. If I hadn't, this thread would end right before it got interesting because I'd get distracted by a butterfly.

At its heart, serverless/FaaS/lambda/whatever-you-call-it works for me because it ties action to cost. The more I do (or the more inefficiently I do it), the more I pay. More users, more money. [Gojko Adzic wrote about this years ago. It's not new.](https://gojko.net/2016/08/27/serverless.html)

The problem, I find, is that in doing so, it breaks your application apart. Now we have many applications. They all work with HTTP, or message queues, or some other data interchange layer I don't care about when I'm designing functionality for a user.

<!--more-->

I've been preaching the joy and value of functional programming since I was but a child. I firmly believe that a functional core to an application lends it reliability, debuggability, testability and all that stuff you need but never prioritise.

(Seriously, I learnt Haskell when I was 17 and never looked back.)

Serverless architectures fuck this up. They reward “do one thing” programming, but at the expense of that functional core. There are no cores any more, just the imperative shell. (Thanks, Gary Bernhardt, for that awesome wording in [Functional Core, Imperative Shell](https://www.destroyallsoftware.com/screencasts/catalog/functional-core-imperative-shell).)

Suddenly, our high-level infrastructure is decoupled and neatly structured, but our low-level code is error-prone and full of duplication. It's all HTTP, no logic. JSON, not objects. Validation, not behaviour.

So we've gained a way to structure our application, but lost our code structure. We might be able to regain some of it by factoring out infrastructure libraries, but then we're tied to one language again. We've lost value.

Jumping sideways a bit: Elm is a beautiful language. (I hope it survives.) One thing it showed us is that with a *very* minimal framework, our code could be completely pure. No side effects, just input and output. Message comes in, messages go out.

Call it Functional Reactive Programming or whatever you like, Elm demonstrates a programming style that is flexible, decoupled, extensible, type-safe and robust. My Elm projects don't break. Ever.

Messages go in. Messages come out. Purely functional. Why aren't we writing serverless functions like this?

I believe the next step after serverless architecture is a simple translation layer. Instead of dealing with HTTP, your function accepts a message and returns zero or more messages. Functional all the way through. No side effects.

Other functions do the same. They're just like you. You deal with user-level HTTP (or other endpoint infrastructure) with system messages. How they're sent is an implementation detail. Probably intra-app HTTP.

What does this buy us? Stability. Even if the code's wrong and you mishandle a message, you *know* you did. Why? Because you have an event log. An immutable record of everything that happened.

So what do we get for free, aside from the benefits of FP? A log of all events. Replayability. Reproducibility. A time-travelling debugger. Full information on everything of importance that's happened in your system. Event sourcing for free.

So why aren't we doing this yet? I wish I knew. I don't know why people aren't writing Elm or Rust or Haskell either.

If we're going to make software, let's make it the best ways we know how. Life's too short to make problems for ourselves later.
