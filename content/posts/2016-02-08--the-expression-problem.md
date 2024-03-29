---
title: "The Expression Problem"
slug: the-expression-problem
date: 2016-02-08T08:00:32Z
aliases:
  - /post/138914396674/the-expression-problem
---

The week before last, I wrote about functional programming and how it relates to object-oriented programming. I asked [Ganesh Sittampalam][@eleganesh] to take a look and he told me that I was mostly right, and to Google "the expression problem".

So I did. Before I go on, you might want to read the previous posts. Or not. That's cool too.

1. [Getters, Setters and Properties][]
2. [Why Couple Data to Behaviour?][]
3. [The Other Trade-off: Separating Data and Behaviour][]
4. [Referential Transparency, And The True Meaning Of Functional Programming][]
5. [Moving Parts][]

I found a quote from [Philip Wadler][@philipwadler], who knows basically everything there is to know and everything that shall ever be known about functional programming, in an email-turned-essay named [The Expression Problem][]:

> The Expression Problem is a new name for an old problem.

<!--more-->

It continues,

> The goal is to define a datatype by cases, where one can add new cases to the datatype and new functions over the datatype, without recompiling existing code, and while retaining static type safety (e.g., no casts).

If you read the previous articles, you'll see that this is a much more accurate way of stating the problem I stated in [Referential Transparency, And The True Meaning Of Functional Programming][]. But more than that, Wadler's essay goes into detail on a potential solution. That solution goes way over my head, but I have confidence that if I read it, say, 20 more times, I'll start to get an idea.

So if you want to get a better handle on the differences between OO and FP, check out the literature on the expression problem. [C2wiki has a great handle on it too.][c2: expression problem] Get reading.

[getters, setters and properties]: /post/138009972532/getters-setters-and-properties
[why couple data to behaviour?]: /post/138076164433/why-couple-data-to-behaviour
[the other trade-off: separating data and behaviour]: /post/138140507048/the-other-trade-off-separating-data-and-behaviour
[referential transparency, and the true meaning of functional programming]: /post/138204666541/referential-transparency-and-the-true-meaning-of
[moving parts]: /post/138268503035/moving-parts
[@eleganesh]: https://twitter.com/eleganesh
[@philipwadler]: https://twitter.com/PhilipWadler
[the expression problem]: http://homepages.inf.ed.ac.uk/wadler/papers/expression/expression.txt
[c2: expression problem]: http://c2.com/cgi/wiki?ExpressionProblem
