---
title: "// what the fuck?"
slug: slash-slash-what-the-fuck
date: 2016-02-11T08:00:19Z
---

A few days ago, [Peter Hilton][@peterhilton] was talking about the [fast inverse square root][] method on the [Software Craftsmanship Slack][], which he uses in his presentation, [Layout & typography for beautiful code][]. I love that this function exists, and I decided to blog about it.

First, let me explain what it means. The *inverse square root* of a number, $y$, is simply $1 / sqrt(y)$, or $y^(-1/2)$. [Last week, I explained how to use the Newton-Raphson method for finding the square root of a number.][Solving Problems By Trying Over And Over Again: the Newton-Raphson Method] We can use the same method for finding the inverse square root. If you haven't read that article, follow the previous link and read that first.

<!--more-->

The inverse square root of a number is defined as $x : x^(-2) = y$. Just like last time, we can subtract $y$ from both sides to get the function $x : x^(-2) - y = 0$, and so our function, $f$, can be defined as $f(x) = x^(-2) - y$.

We then need to differentiate this function. Again, just like last time, $y$ is considered a constant, so the derivative of $f(x)$, $f^\\prime(x) = -2 x^(-3)$.

Simplifying these expressions and rephrasing $x^(-i)$ as $1 / x^i$:

$ f(x) = 1 / x^2 - y $

$ f^\\prime(x) = -2 / x^3 $

Which means that the Newton-Raphson method for the inverse square root function is:

$ x\_(n + 1) = x\_n - (f(x\_n)) / (f^\prime(x\_n)) = x\_n - (1 / x\_n^2 - y) / (-2 / x\_n^3) = x\_n(3 / 2 - y / 2 x\_n^2) $

I experimented a bit with starting values and found that $1$ is always pretty good, just like when calculating the square root, so I went with that.

Let's take our `NewtonRaphson` class from last time and create an `inverseSquareRoot` function.

    def inverseSquareRoot(n: Double): Double = {
      if (n < 0)
        return Double.NaN

      new NewtonRaphson(x => 1 / (x * x) - n, x => -2 / (x * x * x)).apply(1)
    }

And it works. The inverse square root of $9$ is $1 / 3$, and for $0.25$, it's $2$. Try it for yourself and see—just copy and paste it into the REPL [with the code from the last article][NewtonRaphson.scala].

Now, this particular calculation is very useful in video game graphics. [Wikipedia says][fast inverse square root]:

> Inverse square roots are used to compute angles of incidence and reflection for lighting and shading in computer graphics.

As useful as the Newton-Raphson method is, it's *slow*. Iteration is not a good way to eke the last bit of performance out of your desktop, especially in the 90s when we were just starting to get to grips with 3D lighting. So someone, and we don't know who, figured out a way to do it without iteration. The [Wikipedia article][fast inverse square root] contains a stripped-down version of the implementation of the *fast inverse square root*, taken from the now-open-source Quake III Arena source code, including the original comments:

    float Q_rsqrt( float number )
    {
        long i;
        float x2, y;
        const float threehalfs = 1.5F;

        x2 = number * 0.5F;
        y  = number;
        i  = * ( long * ) &y;                       // evil floating point bit level hacking
        i  = 0x5f3759df - ( i >> 1 );               // what the fuck?
        y  = * ( float * ) &i;
        y  = y * ( threehalfs - ( x2 * y * y ) );   // 1st iteration
    //	y  = y * ( threehalfs - ( x2 * y * y ) );   // 2nd iteration, this can be removed

        return y;
    }

… Yup. That makes sense. One of the lines really does make use of the magic number, `0x5f3759df`. No, I don't know where it came from, and clearly, from the comment, no one else does either. But it works. Looking at it, we can see that it does some bit-wise magic, then performs one iteration of *something*. This iteration is actually the same mathematical expression we came up with earlier, but with different variable names; `x2` is $y / 2$ and `y` is $x\_n$, except on the left-hand side, where it's $x\_(n + 1)$. When we substitute those values in, this is what we get:

$ x\_(n + 1) = x\_n(3 / 2 - y / 2 x\_n^2) $

This is, believe it or not, the Newton-Raphson method, disguised very well.

The beauty in this function comes before the Newton-Raphson iteration though. That "evil floating point bit level hacking" gets us to a starting value which is so close to the final result that one iteration of the Newton-Raphson method is enough. It's not very precise, but it's good enough for visual effects, and it means we can calculate more angles of incidence per frame, which is far more valuable than getting one exactly right.

I wasn't sure if I believed it, so I [rewrote the function in Scala][FastInverseSquareRoot.scala] and [benchmarked both functions][numeric-experiments] using [JMH][] in throughput mode, with both a small number, $0.25$, and a large one, $1000000000$. Take a look at my results.

    Benchmark                                    Mode  Cnt       Score      Error   Units
    FastInverseSquareRootBenchmark.largeNumber  thrpt   20  129367.045 ± 2370.629  ops/ms
    FastInverseSquareRootBenchmark.smallNumber  thrpt   20  130160.521 ± 2762.351  ops/ms
    InverseSquareRootBenchmark.largeNumber      thrpt   20     322.564 ±    6.168  ops/ms
    InverseSquareRootBenchmark.smallNumber      thrpt   20     204.608 ±    2.396  ops/ms

(Thanks so much to [Aleksey Shipilev][@shipilev], who I believe is the main author of JMH, for correcting these benchmarks in the comments.)

it turns out that the fast inverse square root function is **over 400 times faster** than the original function, with approximately 120,000 operations *per millisecond* on my computer. Granted, it's less precise, but for certain domains, that's a great trade-off. Of course, C implementation would be even faster, because reinterpretation casting is tricky on the JVM.

Sometimes, great software requires great design. But sometimes, it's great engineering that matters.

[@peterhilton]: https://twitter.com/peterhilton
[Software Craftsmanship Slack]: http://slack.softwarecraftsmanship.org/
[fast inverse square root]: https://en.wikipedia.org/wiki/Fast_inverse_square_root
[Layout & typography for beautiful code]: http://hilton.org.uk/presentations/beautiful-code

[@shipilev]: https://twitter.com/shipilev
[JMH]: http://openjdk.java.net/projects/code-tools/jmh/

[Solving Problems By Trying Over And Over Again: the Newton-Raphson Method]: http://monospacedmonologues.com/post/138595611508/solving-problems-by-trying-over-and-over-again
[numeric-experiments]: https://github.com/SamirTalwar/numeric-experiments
[NewtonRaphson.scala]: https://github.com/SamirTalwar/numeric-experiments/blob/master/implementation/src/main/scala/com/noodlesandwich/numeric/NewtonRaphson.scala
[FastInverseSquareRoot.scala]: https://github.com/SamirTalwar/numeric-experiments/blob/master/implementation/src/main/scala/com/noodlesandwich/numeric/FastInverseSquareRoot.scala
