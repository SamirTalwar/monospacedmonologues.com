# Backward Operators

I spent a summer a few years ago learning Clojure. Here's a thing that confused the hell out of me for a while. It probably won't affect anyone else who reads this, but I think it's amusing.

I was coming at Clojure from two different angles: I know Java very well, and I am a Haskell hobbyist, though I've never used it for anything too serious. So when I read Clojure, my brain translates the syntax into Haskell, and the execution into Java. Because I've never used Clojure for anything in anger either, I've never got past this and treated it like it's its own language.

I was teaching myself Clojure by going through [Structure and Interpretation of Computer Programs][], and on one problem, I had to bang my head against the implementation for a while. It just wasn't working.

Here's the exercise, from [Section 1.2.2: Tree Recursion][]:

> **Exercise 1.11.** A function $f$ is defined by the rule that $f(n) = n$ if $n < 3$ and $f(n) = f(n - 1) + 2f(n - 2) + 3f(n - 3)$ if $n ≥ 3$.
>
> Write a procedure that computes $f$ by means of a recursive process.
>
> Write a procedure that computes $f$ by means of an iterative process.

And here's my implementation of the recursive version:

    (defn f-recursive [n]
      (if (< 3 n)
          n
          (+ (f-recursive (- n 1)) (* 2 (f-recursive (- n 2))) (* 3 (f-recursive (- n 3))))))

See the problem? Take a few minutes if you need to.

...

You sure?

Really sure?

OK, good. Let's talk about it.

I think those of you familiar with Lisps will have spotted it immediately. It is, of course, the predicate to the `if`: `(< 3 n)`. This obviously checks whether $3 < n$, which is the wrong way around—the exercise states that we need to check $n < 3$. So why wasn't it obvious to me?

Haskell's operators look a bit more "normal" than Lisp's. They are infix, not prefix, so in Haskell, we'd write `n < 3`, just like you would in pretty much any other programming language. However, Haskell does have a prefix style:

    (<) n 3

All operators are infix by default, but by wrapping them in parentheses, we convert them to prefix functions which take two arguments—in this case `n` and `3`.

This is a specialisation of a more general case, however. `(<)` is really another way of writing the following:

    \a b -> a < b

That is, a function which takes two arguments, `a` and `b`, and invokes `a < b`. Many Haskellers prefer the former style, `(<)`, for its terseness.

We can also just supply one of the arguments using a form of [currying][Currying] for operators. `(5 <)` is the same as writing `\b -> 5 < b`, and `(< 3)` is the same as writing `\a -> a < 3`.

That last one is what was confusing me. In the Lisp code above, it says `(< 3 n)`, but I was reading it as `(< 3) n`. Expanded out:

    (\a -> a < 3) n

And substituted back in:

    n < 3

So in my head, it was absolutely correct. Even though it's obviously wrong.

*/me headdesks*

[Structure and Interpretation of Computer Programs]: http://mitpress.mit.edu/sicp/
[Section 1.2.2: Tree Recursion]: https://mitpress.mit.edu/sicp/full-text/book/book-Z-H-4.html#%_toc_%_sec_1.2.2
[Currying]: https://en.wikipedia.org/wiki/Currying

<script type="text/x-mathjax-config">
MathJax.Hub.Config({
    asciimath2jax: {delimiters: [['$','$']]}
});
</script>
