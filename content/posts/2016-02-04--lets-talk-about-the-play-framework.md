---
title: "Let's Talk About The Play Framework"
slug: lets-talk-about-the-play-framework
date: 2016-02-04T08:00:15Z
aliases:
  - /post/138657707970/lets-talk-about-the-play-framework
---

A couple of weeks ago, I was experimenting with writing a simple web app in Scala. I'd heard that the [Play Framework][] had got a lot better since v1 a number of years ago, and there's lots of benefits to sticking to first-party libraries (of which Play is one), so I thought I'd give it a try.

<!--more-->

Step one was to wander over to the web page and figure out how to use it. It recommended that I use the [Typesafe Activator][], which is a wrapper around [SBT][] to help you spin up a sample application. Sounds reasonable, so I installed it (`brew install typesafe-activator`) and typed the magic words.

    activator ui

I've never used a build tool that has its own web front-end before. It was kind of nice, kind of scary. It worried me that my fans immediately started spinning before I'd even pointed my web browser to the page, but I was dealing with Scala, after all, so that wasn't much of a surprise.

So I found a bare-bones Play Framework template and told it to set up a project. It opened up a console window in my web browser (seriously?), and started running SBT.

Half an hour later, I was still there. The fans were still spinning, and the entire planet was being downloaded onto my laptop. Highlights include SBT itself, [NPM][] (the Node Package Manager, which seems over the top), Jetty and Maven (because Jetty depends on Maven… no, I don't know why either). At the time of writing, having used SBT (and therefore Ivy) for this example Play application and that only, my `~/.ivy2` directory contains 813 megabytes of dependencies.

I hadn't yet implemented "Hello, World".

An hour after hitting the button, things were still downloading. My connection wasn't lightning-fast, but it wasn't too slow. The problem was Ivy, which downloads dependencies serially. Because SBT backs onto Ivy, anything network-related takes forever. (Gradle fans, you have exactly the same problem. Maven is the only sane one. It's just a shame about the XML.)

An hour and a half has gone by, and I finally have a Play application. It says hello to me. It's got a unit test that ensures it says hello, a functional test that ensures that the HTML is fine, and that check that the browser (using [Selenium][] and [HtmlUnit][]) can see that we're saying hello. This is an excellent starting point, and I remembered the advantages of using a web framework. Until I realised it was using [_specs²_][specs2], my least favourite test framework. And so I looked into using [ScalaTest][] instead. This was a mistake.

[The thing that upsets me about frameworks][don't call us. we'll call you.] is that everything that interacts with the framework is special. I wanted to use a test framework, but I couldn't just use ScalaTest, I had to use [ScalaTest + Play][], a library that specifically integrates the two. After I got that working, porting the tests was a doddle, but it took ages (including several more minutes of downloading dependencies) before I could get it working.

Great. Now I had a web framework that did what I wanted. I was still using the Activator UI, so I could click a button on a web page to run my application, and another button to run all the tests.

This was mistake number two.

The Activator UI is nice in theory. It provides some of the benefits of an IDE, but integrated into SBT. The downside is that it's completely broken. When I set it to re-build and re-launch my application on code changes, it ground my computer to a halt and SBT crashed a lot. When I asked it to run my tests, half the time it would fail to start them. I ended up using IntelliJ IDEA to run the tests, but there's no obvious way to launch a Play application—there's no easily-identifiable `main` function—and so I was stuck with Activator for that. As long as I told it to only run when I told it to, it was totally fine.

OK, computer's stopped crashing. I'm three hours in. I want this application to be fairly responsive, so I need to make sure I can make an AJAX call. Writing the JavaScript: easy. Including [jQuery][] and [React][], not so easy. Play uses something called [WebJars][] to turn JavaScript dependencies into JAR dependencies so you can include them with SBT (and this is why NPM was required). Wonderful theory. In practice, it's another layer of indirection, and the documentation does not make it clear how to include the libraries. It takes me some Googling around before I realise it's created a virtual directory called `lib` which I can reference in URLs, as in `/lib/jquery/jquery.js` to include it.

Final step before I've got everything wired up: let's integrate it with a database. I decided to use [Slick][], a database mapping library that's _not_ an ORM. I've used it before and it's excellent. Now, usually you just create some table representations in code and hook them up with your JDBC driver at application startup, but with Play, hooking into application startup is difficult. So we have to use [PlaySlick][], an integration library that understands how to wire the two together. Imagine my surprise.

One hour later, I've finished banging on the application, trying to make "evolutions" (database migrations) work. It's done. I can serve "Hello World" from the database.

At this point, I deleted the project.

---

Rant over. Now for some balance. After whining on Twitter for a while, [Tom Westmacott][@twestmacott] got in touch to sympathise, but also tell me that he doesn't see the same problems. So I went and had a chat with him to find out how Play is used in practice. Tom works for [TIM Group][], where Play was introduced to replace an aging home-grown framework-like-thing that, and I paraphrase Tom, "combines all the flexibility and power of a framework with the ease of doing everything yourself."[^1] In other words, the worst of both. Using something standard, Googleable and (mostly) sane was a breath of relief to the developers.

What I found interesting is that adding functionality to a web-app _is_ helped massively by the framework. When setting up a new application, you deal with integration a lot—with the framework, with your browser tests, with your authentication library, with routing… you get the idea. However, tweaking behaviour, adding pages, clarifying text and images, and others of that ilk are all simple changes that the framework facilitates. I didn't get far enough with Play to experience the benefits because the integration costs were so high, but if I had, I bet I would have appreciated the framework handling the heavy lifting for me when it comes to handling a web request and returning a response.

I talked last week about programming being a set of trade-offs. In this, using a framework as opposed to composing several libraries myself is no different. Implementing form validation yourself is not an easy job, but neither is writing integration code to hook your framework into your custom database failover logic. It really just depends where you want to pay the price.

[^1]: I used to work for TIM Group, but left in late 2012, at around the same time Play was introduced. I missed the revolution.

[don't call us. we'll call you.]: http://monospacedmonologues.com/post/46427054295/dont-call-us-well-call-you
[htmlunit]: http://htmlunit.sourceforge.net/
[npm]: https://www.npmjs.com/
[play framework]: https://playframework.com/
[playslick]: https://www.playframework.com/documentation/2.4.x/PlaySlick
[react]: https://facebook.github.io/react/
[sbt]: http://www.scala-sbt.org/
[scalatest + play]: http://www.scalatest.org/plus/play
[scalatest]: http://scalatest.org/
[selenium]: http://www.seleniumhq.org/
[slick]: http://slick.typesafe.com/
[specs2]: https://etorreborre.github.io/specs2/
[typesafe activator]: https://www.typesafe.com/community/core-tools/activator-and-sbt
[webjars]: http://www.webjars.org/
[jquery]: https://jquery.com/
[@twestmacott]: https://twitter.com/twestmacott
[tim group]: http://www.timgroup.com/
