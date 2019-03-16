---
title: "Solving Problems By Trying Over And Over Again: the Newton-Raphson Method"
slug: solving-problems-by-trying-over-and-over-again--the-newton-raphson-method
date: 2016-02-03T08:00:14Z
aliases:
  - /post/138595611508/solving-problems-by-trying-over-and-over-again
---

I was re-reading [Slash Slash Massive Hack][] as I wrote yesterday's blog post, and was reminded of the awesomeness of the Newton-Raphson method. [Wikipedia explains it better than I][newton's method]:

> In numerical analysis, Newton's method (also known as the Newton–Raphson method), named after Isaac Newton and Joseph Raphson, is a method for finding successively better approximations to the roots (or zeroes) of a real-valued function.

<!--more-->

Well, at least, it explains it using more complicated words than I. Let's break it down a little. I will be pulling information liberally from Wikipedia, so you might find it easier to follow along there.

The _root_ of a function has a description as a mathematical formula:

$ x : f(x) = 0. $

What this means is that the Newton-Raphson method is a method for finding some input, $x$, such that the output of the function $f$ is $0$. This allows us to solve some problems of the form "easy to do, hard to undo".

The classic example of a use of the method is the _square root_ function. The method doesn't allow us to solve this directly, but it does allow us to solve a related problem.

The square root function, `sqrt`, is defined as $x : x^2 = y$. Unfortunately, if we want to find the square root of $9$, the method can't find $x : x^2 = 9$. However, if we subtract $9$ from both sides, we _can_ solve for this function:

$ f(x) = x^2 - 9 $

The first thing we do is find the derivative of this function. I'm not going to go into calculus, so if you're not sure why, just trust me when I say that the derivative, $f^\\prime(x) = 2x$.

We then pick a starting value, $x\_0$. This should be a value that's a good guess for the number we're going for. The actual number, $y$, can be used in this case as something that's obviously not the right answer (unless $y = 1$, of course), but isn't well out.

Then we iterate using the method to find $x\_1$, then $x\_2$, then $x\_3$, and so on. In general, we can calculate $x\_(n + 1)$ as:

$ x\_(n + 1) = x\_n - (f(x\_n)) / (f^\prime(x\_n)) $

In the case of the square root function, this is:

$ x\_(n + 1) = x\_n - ({:x\_n:}^2 - y) / (2 x\_n) $

We keep iterating until the change is 0, or so close to it as to be negligible.

So let's try it with $y = 9$, starting from $x\_0 = 1$, which is probably not the right answer, but is probably not too far off in the grand scheme of things:

$ x\_0 = 1 $

$ x\_1 = x\_0 - ({:x\_0:}^2 - 9) / (2 x\_0) = 5 $

$ x\_2 = x\_1 - ({:x\_1:}^2 - 9) / (2 x\_1) = 3.4 $

$ x\_3 = x\_2 - ({:x\_2:}^2 - 9) / (2 x\_2) = 3.02352941176471... $

$ x\_4 = x\_3 - ({:x\_3:}^2 - 9) / (2 x\_3) = 3.00009155413138... $

$ x\_5 = x\_4 - ({:x\_4:}^2 - 9) / (2 x\_4) = 3.00000000139698... $

$ x\_6 = x\_5 - ({:x\_5:}^2 - 9) / (2 x\_5) = 3.0 $

$ x\_7 = x\_6 - ({:x\_6:}^2 - 9) / (2 x\_6) = 3.0 $

And we're done. The square root of 9 is 3.0 exactly.

You can use this for any (positive) number, not just square numbers. I've got a working Scala version below which works in very much the same way ([and it's on GitHub too][numeric-experiments]).

    class NewtonRaphson(
        f: Double => Double,
        fDerivative: Double => Double,
        epsilon: Double = 0.000000000000001
    ) {
      def iterate(x: Double): Double =
        x - f(x) / fDerivative(x)

      def apply(start: Double): Double =
        Stream.iterate(start)(iterate)
          .sliding(2)
          .map { case Stream(a, b) => (a, b) }
          .dropWhile { case (a, b) => scala.math.abs(a - b) >= epsilon }
          .next
          ._2
    }

    def squareRoot(n: Double): Double = {
      if (n < 0)
        return Double.NaN

      new NewtonRaphson(x => x * x - n, x => 2 * x).apply(n)
    }

The `squareRoot` function primes the method with $f$ and $f^\\prime$, then immediately invokes the `apply` method with $1$ in order to calculate $sqrt(n)$. The `iterate` method performs a single iteration, and so is fairly simple and boring. The `apply` method, however, is interesting, and so I'd like to explain how it works.

First of all, it constructs a lazy stream of subsequent iterations of $x\_0$:

$ x\_0, x\_1, x\_2, ... $

It then creates a sliding iterator of two items on top of that, and converts it from a `Stream[Stream[Double]]`, where the inner stream always has two items, to a `Stream[(Double, Double)]`.

$ (x\_0, x\_1), (x\_1, x\_2), (x\_2, x\_3), ... $

We want the first pair where the two values are the same (or close enough), so it drops elements from this stream while the difference is greater than `epsilon`. It then grabs the first element from the resulting stream, and then the second part of the tuple. It gets the second, rather than the first, because it's one more iteration and will therefore be the more accurate answer if they are still different.

And that, folks, is how you calculate the square root of a number.

[slash slash massive hack]: http://monospacedmonologues.com/post/137738860257/slash-slash-massive-hack
[newton's method]: https://en.wikipedia.org/wiki/Newton's_method
[numeric-experiments]: https://github.com/SamirTalwar/numeric-experiments
