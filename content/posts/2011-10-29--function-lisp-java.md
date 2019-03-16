---
title: "Function<Lisp, Java>"
slug: function-lisp-java
date: 2011-10-29T00:02:00Z
aliases:
  - /post/12051343792/function-lisp-java
---

If you read the last blog post through the eyes of a Java developer, you
may wonder exactly how you toss functions around willy-nilly like we did
for our implementation of `map`. You can't pass functions around like
they're values in Java! This is ridiculous. Someone call a lawyer.

Well, hold on, give me a second to explain. First of all, here's `map`
again, for your viewing pleasure:

    List.map (f) = if this.isEmpty
                       then []
                       else f(this.head) : this.map(f, this.tail)

So we have a class called _List_ with a method called _map_. It takes
one parameter, `f`, and does some cool stuff. So first of all, let's
rephrase this in Java. We'll call it _FunctionalList_ so we don't clash
with the `java.util.List` interface.

    class FunctionalList<T> {
        ...

        public <U> FunctionalList<U> map(function f) {
            return isEmpty()
                       ? nil()
                       : cons(f(head()), map(f, tail()));
        }
    }

<!--more-->

`map` takes a function that transforms an object, and applies it to
every element of a list. So if that function takes an object of type `T`
and gives us an object of type `U`, the resulting list will be
`FunctionalList<U>`. The only thing we're really missing is a type for
`f`.

Consider `f`'s type for a moment. It takes an object of one type and
returns an object of another. Well, we can encapsulate that in an
interface.

    interface Function<I, O> { }

It needs something more though. A way to apply the function itself.

    interface Function<I, O> {
        O apply(I input);
    }

It's really as simple as that. That's the type of our function. Because
it's wrapped in an interface, we can toss it around just like any other
object. We just need to change `map` a little to accommodate it:

        public <U> FunctionalList<U> map(Function<T, U> f) {
            return isEmpty()
                       ? nil()
                       : cons(f.apply(head()), map(f, tail()));
        }

C\# developers should be nodding their heads at this point. This is
exactly how the `Func<A, B>` interface works. There's more syntactic
sugar around that one, but apart from that, it's essentially the same
idea.

So what does our `multiply_by_two` function look like under these
circumstances? A little something like this:

    multiplyByTwo(FunctionalList<Integer> list) {
        return list.map(new Function<Integer, Integer>() {
            Integer apply(Integer input) {
                return input * 2;
            }
        });
    }

A bit messy, but it does the job well. Java's anonymous implementations
are unfortunately pretty verbose. That said, Java 8 is looking to change
all of that with lambdas that will look something like the C\#
counterparts:

    multiplyByTwo(FunctionalList<Integer> list) {
        return list.map(x => x * 2);
    }

Until then, we're stuck with the ugly implementation. I like to pull the
implementation out into a method or constant and put it at the bottom of
the class. That way, the function gets a decent name and it doesn't
bloat the code.

    multiplyListItemsByTwo(FunctionalList<Integer> list) {
        return list.map(multiplyByTwo);
    }

    ...

    Function<Integer, Integer> multiplyByTwo = new Function<Integer, Integer>() {
            Integer apply(Integer input) {
                return input * 2;
            }
        });

Look at that. Functional programming for Java developers. Did you ever
think you'd see the day?
