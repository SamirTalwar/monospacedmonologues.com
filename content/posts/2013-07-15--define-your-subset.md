---
title: "Define your Subset"
date: 2013-07-15T17:18:01Z
---

Every tool you use will be inadequate. Every design you create will be
inaccurate. Everything you do will be imperfect.

I’ve spent a lot of time experimenting with a lot of languages, and none
of them meet 100% of my needs. Java is too clunky, Ruby has too many
edge cases, Python is not well-supported enough, C\# is too commercial,
and Haskell is too academic.

But I’m becoming increasingly happy with Scala, which perhaps
encompasses all of those downfalls at once, in some form or another. And
I’m fairly convinced that this is because I’m currently working on a
project on my own. I’ve written all the code for it, documented it, and
I’m now writing an installer. The project is made up of several modules
written in either Java or Scala, and I’ve enjoyed writing the Scala
projects much more.

This is new to me. I disliked Scala when I first used it, and dealing
with legacy code in the language helped me develop those feelings until
I didn’t even want to see it. I found myself gravitating back when I
needed to do some XML generation and parsing, and realised the Scala
features around this would make it much, much easier than in any other
language. This project was the first Scala project I’ve ever started
from scratch, rather than joined after work had already started.

I think the reason I enjoyed building this small module is because I got
to **define my own subset of the language**. I came to the conclusion
fairly early on that I was going to avoid most “advanced” (read:
“overcomplicated”) features, including implicit conversions, mutable
state and operator overloading. I used them, of course, when they
cropped up in the Scala library or other third-party dependencies, but
avoided them otherwise. The result of this was that I decided that Scala
is actually a pretty neat language, as long as you only use a subset of
its features.

We’ve mocked C++ developers for decades about how the language is
completely impenetrable unless you actively avoid using certain pieces
of functionality. Templates are banned at some C++ development shops,
which seems mad to a modern Java or C\# developer who is fond of
generics, but has very good reasons behind it. I think we need to apply
these principles to all our languages. I know I’ve got a mental list of
things I try not to do in Ruby about as long as this article, and even
in Haskell, which is a very simple language, I find myself avoiding some
practices in favour of code that’s more readable by people who don’t
know the language.

When you’re faced with a new project in any language or using any tool
chain (Rails springs to mind), I think it’s worth taking the time to
decide which features should best be avoided. By making these decisions
as a team at the offset, you avoid a lot of pain caused by differing
opinions on what “clean code” actually means. If you like implicits in
Scala or operator overloading in C++, that’s great, but if you’re the
only one in the team who understands them, maybe you’re better off
treading cautiously around them, even though you have no personal issue
with the concepts.

There’s been a trend recently for companies to publish their coding
style guides—[GitHub’s guides](https://github.com/styleguide) on Ruby,
JavaScript, markup and more are a good example. I think this is great,
but don’t use someone else’s without thinking. Create your own, either
from scratch or (more pragmatically) by augmenting one you like. Publish
it somewhere internally and make sure that it’s easy to edit as you grow
as an organisation and as developers. Use it to define your subset, so
that everyone in the team is able to understand and maintain your work.
