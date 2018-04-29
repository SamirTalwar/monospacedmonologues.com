---
title: "Stringly Typed"
date: 2011-10-16T18:53:00Z
---

At the first [FP Day](http://www.fpday.net/) on Friday, I attended a
talk by Don Syme on [F\#
3.0](http://research.microsoft.com/en-us/um/cambridge/projects/fsharp/).
There were a number of useful features, but to the functional
programmer, the most revolutionary one was type providers. They're a way
to use strong, static typing for data structures beyond those coded into
libraries. The most prominent use of these are for data sets so large
that the entire set of types necessary to understand all of it is too
much to include in your application. However, they're also useful as an
alternative to code generation. Take for example, accessing a page on
Wikipedia. If I have a type provider that accesses Wikipedia as I'm
writing the code and generates types for each type of article, I can do
something like this.

> FYI (because most of us don't know F\#), backticks (`` ` ``) let you
> put spaces in names, angle brackets (`<` and `>`) are used to
> initialise type providers, and the `|>` operator pipes the result of
> one operation into the next.

    #r "Wikipedia.dll"

    type Wikipedia = Wikipedia<>
    Wikipedia().Computing
               .``History of computing``
               .``Computer pioneers``
               .``Dennis Ritchie``
               .Infobox
               .``Known For``
      |> String.concat ", "
      |> (+) "Dennis Ritchie was known for "

    // returns "Dennis Ritchie was known for ALGOL, B, BCPL, C, Multics, Unix"

<!--more-->

Each of those objects I'm accessing is statically typed. If I misspell
the article name, I don't get an error at runtime. My application fails
to compile. How cool is that?

Now, this is excellent, and I hope to see it in Java around 2026 or so.
But what's really interesting is something else Don said (and I'm
paraphrasing): if you would hard-code a string, you should instead use
type providers. This got me wondering a little. I've always thought of
strings in my application as simply hard-coded text. But it turns out
there's different kinds of text. There's the stuff we represent to the
user: API documentation, button text—anything you *see*—and there's the
the stuff we use internally but never show anyone. These latter strings
all fall into a category I'm going to call, for lack of a better term,
data accessors. They're things like API URLs, file paths, Windows
registry keys… you catch my drift.

We shouldn't be encoding these accessors as strings. How often have you
hunted for a bug for hours before realising you made a typo? Strong
typing takes out a whole class of errors for us, and we should be
exploiting the concept as much as we possibly can. This means type
providers can be used to access file systems and REST calls. And as a
bonus, it makes the code so much more readable.

Using the REST API, here's (roughly) what updating your status on
Twitter looks like:

    let twitterUrl = "http://twitter.com/"
    let newTweet = "status/update"
    Http.Request(twitterUrl).Post newTweet, credentials, tweetText

But here's how it *should* look:

    let twitter = Twitter(credentials)
    twitter.Status.Update tweetText

We commonly place user interface strings outside the source code using
[gettext](http://www.gnu.org/s/gettext/), [Java resource
bundles](http://download.oracle.com/javase/tutorial/i18n/resbundle/index.html)
and other such libraries. We've come to realise that our applications
are more maintainable when we separate out code and data. We should
externalise our data accessors in the same way. Type providers are an
excellent way of doing this, but they're not necessary. If an API is
sufficiently explorable (like Wikipedia's), we can generate the code to
create these types using all sorts of methods, and simply create a build
step that pulls down the latest information for just the types we need.
This will give us similar behaviour to type providers in F\#, but
without IDE support. If it's an API, we can just create a wrapper around
it and use that, as I demonstrated with Twitter above.

I learnt a lot at FP Day, but this was the thing that stuck out the
most. Not because it's shiny and new, but it's reinforcing something we
all know but too often forget on purpose. Strings in your source code
are a sign of intermingling data and logic, and make it harder to read
and maintain. Some are necessary, but they should be the exception, not
the rule. If I put the code `let x = 1089` into my code base, the next
person to read it would hunt me down and slap me in the face. We
shouldn't tolerate strings in the code either. Pull 'em out and give
them names, the same as we do with numbers. And then go one further.
Wrap them in a well-tested library that takes care of the details, or
even put them in their own resource file.

Data's not code. Stop treating it like it should be.
