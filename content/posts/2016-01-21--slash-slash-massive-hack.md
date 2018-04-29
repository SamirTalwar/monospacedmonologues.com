---
title: "Slash Slash Massive Hack"
slug: slash-slash-massive-hack
date: 2016-01-21T08:00:39Z
aliases:
  - /post/137738860257/slash-slash-massive-hack
---

I generally dislike code comments. I've heard good arguments for and against, and many, many bad arguments for them. Let me sum them up, and I'll present a slightly different take on them at the end.

<!--more-->

## The Bad Arguments For Code Comments

Comments suck at keeping track of things:

    // somedev1 -  6/7/02 Fix bug in the login screen

This is what version control is for. Use it. Don't ever not use it. Even if you think the code will never leave your machine. `git init` costs practically nothing.

Comments also suck at telling me what the code does:

    x += 2 // increment x by 2

This is true even for more complex code:

    x = x - (x * x - n) / (2 * x) // iteration of the Newton-Raphson method for sqrt

Extract it out:

    class NewtonRaphson(f: Double => Double, fDerivative: Double => Double) {
        def step(x: Double): Double =
            x - f(x) / fDerivative(x)
    }

    val squareRoot = new NewtonRaphson((x => x * x - n), (x => 2 * x))

    ...

    x = squareRoot.step(x)

Sure, I'll still have to Google ["Newton-Raphson"][Newton's method], but at least when I do, it'll be obvious what's going on as soon as I understand the principle at work.

And this hasn't been funny since 1996:

    stop() // Hammertime!

[Newton's method]: https://en.wikipedia.org/wiki/Newton's_method

## The Good Argument Against Code Comments

This generally goes along these lines: if you need comments, your code isn't expressive enough.

I think that's generally true. If you need to explain some code, you can do one of two things to avoid comments: either you can clean up the code to the point where it's very obvious what it's doing, or you can extract it into a function, give it a good name and pretend the implementation doesn't exist.

The thing I really like about this approach is that even the second approach, which sounds pretty dodgy, is quite good. If you can name a function really well, it probably does one thing and one thing only. This means you've figured out a decent way to separate your concerns, which means that often, the name is really all you need to know. (Expect more on naming in a future post.)

## The Good Argument For Code Comments

I think [Peter Hilton][@peterhilton] sums this one up best in his articles, [7 ways to write bad comments][], [3 kinds of good comments][], and [How to comment code][].

In those posts, he argues that:

> The truth about code comments is that if you don't write any, because they would make your code worse, then there's a powerful language feature that you don't know how to use, and questions that your code doesn't answer:
>
>   * Why is this code here?
>   * What is it for?
>   * Why is the functionality implemented this way?
>   * Why is that the functionality?
>   * When shouldn't you use this code?

Comments can answer lots of questions about your code aside from *what* it does, and we shouldn't throw away a tool just because it *can* be misused. If we took that attitude to everything, there wouldn't be a single programming language we could actually use.

[@peterhilton]: https://twitter.com/peterhilton
[7 ways to write bad comments]: http://hilton.org.uk/blog/7-ways-to-write-bad-comments
[3 kinds of good comments]: http://hilton.org.uk/blog/3-kinds-of-good-comments
[How to comment code]: http://hilton.org.uk/blog/how-to-comment-code

## The Better Argument Against Code Comments

While we can answer questions about code with comments that can't be answered by the code itself, we can often answer these questions with automated tests.

Taking an example from Hilton's articles, instead of:

    // Returns half of the given amount, so we can split the bill.
    def half(amount: Money) = amount.dividedBy(2, RoundingMode.UP)

We could instead use a test case:

    describe("half") {
        it("returns half of the given amount, so we can split the bill") {
            half(Money(25.0, GBP)) should be(Money(12.5, GBP))
        }
    }

Current code editors, including modern IDEs, don't make it easy to see the test cases associated with a class, function, module, etc., but you can organise them to make that easier, for example by opening the associated test file in a split window and collapsing the blocks so you can just read the test names.

We can also use our type system to document our code. Taking another one of Hilton's examples:

    // Returns a cuteness estimate for non-dead kittens less than one year old.
    def estimateCuteness(kitten: Kitten): Int = { … }

We could embed most of that information into the types:

    def estimateCuteness(kitten: Alive[Kitten]):
            Either[NotAKittenException, CutenessEstimate] = { … }

This code is clearly a function that takes an alive kitten and returns either a `NotAKittenException` on failure, or a `CutenessEstimate` on success. The only information missing from this line are the circumstances in which we might return a `NotAKittenException`. And we can write a test for that.

## The Best Argument For Code Comments

And now, the reason I find myself writing comments once in a while.

Every so often, I start what should be a simple task. Four hours later, I'm swearing at my computer. After a long break, I come back and realise that my code is correct, but (at least) one of the following is true:

  * something else is modifying my state out from under me
  * the framework is "helping"
  * I've written JavaScript and Microsoft hates me, so IE/Edge has decided not to bother
  * it turns out the definition of `class` is different for this framework
  * these two libraries really don't mesh well with each other
  * I seem to have two different versions of the same library
  * my `PATH` or JVM classpath is completely different from what I expected
  * the programming language VM works differently on this operating system
  * I work for the devil, and so I write Linux software on Windows XP, with no admin rights

These things all have one thing in common: I'm relying on third-party software, usually a framework, virtual machine or operating system, which does not behave as expected in some subtle way that is not obvious even to someone who understands the system in question fairly well. If it were in my own code, I would fix *that*. That is what refactoring is for.

Assuming this is the case, at this point, I can probably solve the problem with a hack around the offending integration point. However, my solution to the problem will *look* non-optimal, and so another developer working on the same project would be quite right to change it back to something that looks simpler but is broken. Sometimes you can write a test case for this—for example, if my code only fails in IE 9, I could use [WebDriver][] to verify that the functionality works in all browsers. However, this can be problematic—maybe I can't run test cases on the environment causing the problem, or maybe the particular scenario is really difficult to automate. This is an artifact of a bigger problem, but it might not be one I can solve right now.

In these cases, I write a comment right above the travesty I've had to conjure to beat the environment or framework.

    // MASSIVE HACK
    //
    // I realise this looks bad. Unfortunately, due to a quirk in the interaction
    // between jQuery and Internet Explorer 9, which we still support, we cannot
    // use the built-in `map` function, but must instead roll our own.
    //
    // If any of the following become true, this hack can be removed:
    //   * we start using jQuery 2
    //   * we stop supporting IE 9
    //   * we no longer need to render tables with cells spanning multiple columns
    //
    // Apologies, and Godspeed.
    // — @samirtalwar, 2016-01-21.

[WebDriver]: http://www.seleniumhq.org/projects/webdriver/
