---
title: "More like Hask-Hell LOL"
date: 2017-05-31T07:30:13Z
---

I'm not sure how, but a little while ago I got talking to [John Cinnamond][@jcinnamond] about an experience of mine with Haskell that didn't exactly end well.

As some of you may know, I made a terribly-promoted, mostly-unused (except by me) application called [Over The Finish Line][]. It displays open pull requests on your favourite repositories in a dashboard format. I think it's pretty neat. It doesn't get much love nowadays… but I'm getting ahead of myself.

![Screenshot of Over The Finish Line](http://assets.monospacedmonologues.com/2017-05-31+-+Over+The+Finish+Line.png)

<!--more-->

Being a statically-typed functional programming purist, and this being the middle of 2016, I went for the new shiny client-side compile-to-JavaScript programming language: [Elm][]. Elm checked all the boxes: it's type-safe, uses spaces to provide function arguments, is pure FP and generally shits rainbows. Basically, it looked like Haskell.

And, of course, I picked Haskell as the server-side language, because of course. I'd never used it for a web application before, but I figured I could handle it. I grok monads. I eat higher-kinded types for breakfast. (They're great with yoghurt and blueberries.)

<figure>
  <p><img src="http://assets.monospacedmonologues.com/2017-05-31+-+blueberries.jpg" alt="Blueberries"/></p>
  <figcaption>People of 2039, this is what fruit looks like.</figcaption>
</figure>

And so, I booked a week off and dove in.

Initially, the two languages felt quite similar, but they quickly started to diverge. Elm was annoyingly simple; no higher-kinded `fmap` or `>>=`; I had to think about what kind of data structure I was working with. Which was easy, because the error messages told me. Eventually, I realised that these two things were one and the same. The lack of fancy Haskell-like types and `fmap` and whatnot meant that Elm could reason about my program exceptionally well, and I learnt to just follow the compiler.

No such luck with Haskell.

At first, the server side was a breeze. I loved it. It was all the monads, all the time, and isn't that what Haskell folk live for? And it lasted all of two days before I hit a wall. It was monads upon monads, and it went from the type system really helping to hurting. Sure, I didn't have to manually remember types of values, but I did have to manually remember what the stack of monad transformers looks like.

What's a monad transformer? I already told you. Literally monads upon monads. Turns out one is easy, two is fine, and three is impossible. I'm sure smarter people than me can handle them fine. I wept.

<figure>
  <p><img src="http://assets.monospacedmonologues.com/2017-05-31+-+sqhell.png" alt="SQHell"/></p>
  <figcaption><em>John:</em> I guess that some applications just want to be imperative!</figcaption>
</figure>

I wouldn't use Haskell for this project. But I would absolutely use it again, just not for anything where there's more than one layer of I/O. And I'd only use it if there was serious computation going on. Most of this project is side effects: talking to GitHub, talking to the database, loading the configuration from environment variables, serving over HTTP.

I don't think I've ever said this before, but I wish I'd just used node.js.

Now I'm exploring an idea which I think will help: what if we could compose processes like we do services? So I started working on [Eleven][] with [Mateu Adsuara][@mateuadsuara] and others. Tell me what you think.

I really miss working with Haskell. But not like this.

[Over The Finish Line]: https://overthefinishline.com/
[Elm]: http://elm-lang.org/
[Eleven]: https://github.com/SamirTalwar/eleven
[@jcinnamond]: https://twitter.com/jcinnamond
[@mateuadsuara]: https://twitter.com/mateuadsuara
