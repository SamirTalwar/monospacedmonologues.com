---
title: "Don't Call Us. We'll Call You."
date: 2013-03-27T16:18:39Z
---

I've been thinking about why I dislike Ruby on Rails for over a year
now. It's not the much-touted "convention over configuration"—that's
actually quite lovely. It's not the ever-increasing rate of zero-day
security vulnerabilities: while that's worrying, it's not going to stop
me from using it to knock out a web site over a weekend. Security is
only necessary when you have a product and some customers. It's not even
because [DHH](https://twitter.com/dhh) is a bit of a tool. I don't think
I'd get along with him at a conference, but that's no reason to shun his
company and product.

It's because it dictates the terms of agreement. You don't.

<!--more-->

When you create a new Rails application (and you have to use their
command-line tool to do so), it comes with a folder structure, from
which you really shouldn't be deviating. You must use ActiveSupport,
which monkey-patches *everything.* ActiveRecord is pervasive, and comes
with some pain: once you use it, nothing is testable in isolation. I'm
told that that's OK—integration tests will take care of everything—but
that's not the way I operate and not the way I think. It also forces me
to write a test suite that is designed to make me avoid running it,
because [slow feedback is almost as bad as no
feedback](http://www.jbrains.ca/permalink/integrated-tests-are-a-scam-part-1).

All this, because it's a **framework**.

The difference between a library and a framework is this: you use a
library. Frameworks? Frameworks use you. They have complete control of
your environment, not you. Any restrictions that are placed upon you
become serious pain points later on, and they're not easy to work
around. Quite often, the solution is to wrap the framework to provide
yourself an avenue to break out later, and at that point, you tend to
start taking control of more and more until your framework really just
gets in your way.

This all happens over time, of course. When you start, it's helpful. It
handles your form validation, it takes care of routing and redirection,
and gives you a structure to start coding right away. It's only as you
start replacing functionality with other libraries (sometimes your own)
and working around "features" that are really just obstructions that you
start to realise that your tools are not providing the benefits they
should.

So what's the solution? Use libraries. Initialising your environment
yourself and calling libraries as needed means that you are in complete
control of your product. When you don't like a particular feature of a
library, wrap it and make sure it doesn't happen. Or swap it out for a
different one. Pick your libraries well: they should do one thing well.
This means if you find that in the future, a particular one doesn't do
the job as well as you'd like, you can just replace it.

In my last Ruby project, I decided not to use Rails. Instead, I used
Sinatra for the web layer and MongoMapper to access the database. This
worked really well: the code was testable and pleasant, and when I
decided I didn't want to use the MongoMapper paradigm any more, it was
pretty easy to replace it. In addition, my files were laid out in the
manner I liked—a way that actually represented the different facets of
my application, rather than the purely structural layout you get with
almost any MVC framework.

When it comes to building something, build it to last. Whatever your
restrictions are, eventually you're going to want to smash through them.
Our hardware and operating systems already put too many constraints on
our software. Why add more?

*Thanks to the people at [Devoxx
UK](http://devoxx.com/display/UK13/Home) for giving me the cannon fodder
I needed to finally write this blog post, after months of thinking about
it.*
