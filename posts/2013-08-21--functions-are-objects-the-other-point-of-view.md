<!--
id: 58923319303
link: http://monospacedmonologues.com/post/58923319303/functions-are-objects-the-other-point-of-view
slug: functions-are-objects-the-other-point-of-view
date: Wed Aug 21 2013 17:15:00 GMT+0100 (BST)
publish: 2013-08-021
tags: 
title: Functions are Objects: the other point of view
-->


There’s a feature in Java 8 which nicely embodies one of the differences
between the class-oriented structure of Java and functional languages.
It lies in the way you implement lambdas.

You might have seen the syntax already. It looks something like this:

    List<Integer> numbers = ImmutableList.of(2, 9, 8, 3);
    List<Integer> squares = numbers.stream()
                                .map(x -> x * x)
                                .collect(toList());
    assertThat(squares, contains(4, 81, 64, 9));

It’s quite pretty, and means there’s a separation between the lazy
functional stuff and the normal collections interfaces. But have you
wondered at all what the signature of `Stream::map` is?

Turns out it takes an object, like every other method in Java.

    <R> Stream<R> map(Function<? super T, ? extends R> mapper);

That `Function` is `java.util.function.Function`, an interface with one
abstract method, `R apply(T t)`. In this case, `x -> x * x` is an
implementation of that `Function` interface. But it doesn’t have to be.

Let’s look at another example:

    List<Integer> numbers = ImmutableList.of(2, 9, 8, 3);
    List<Integer> odds = numbers.stream()
                              .filter(x -> x % 2 == 1)
                              .collect(toList());
    assertThat(odds, contains(9, 3));

The signature of `filter` is as follows:

    Stream<T> filter(Predicate<? super T> predicate);

This time, my lambda was converted into an implementation of
`Predicate`. Same syntax, same number of parameters, but it has a
different type. How did the compiler know how to do that? C\# uses one
type for both. Functions are of type `Func<T, U>`, and predicates are
simply `Func<T, bool>`.

It turns out the Java 8 lambda folk decided that their implementation of
a function object shouldn’t be special. After all, plenty have existed
before in libraries such as
[Guava](http://code.google.com/p/guava-libraries/) and [Functional
Java](http://functionaljava.org/). So they came up with a heuristic
instead: any interface or abstract class with a **single abstract
method** is considered a **functional interface** and can be implictly
implemented by a lambda expression. This means that lambdas really are
objects like (almost) everything else in Java. Functions aren’t special;
classes and objects are the building blocks of the programming language,
and the functional aspects of it are designed with that in mind.

Naming
------

Naming is important. There’s a new interface in Java 8 called
`java.util.function.Supplier`, which has one method:

    T get();

That’s it. You implement it like this:

    final String words = "lots of words";
    Supplier<String> lastWord = () -> words.substring(words.lastIndexOf(' ') + 1);

You can make it more complicated, returning something else if the string
is empty or only has one word, for example. This serves my point well
though. It’s obvious that I can use this to pass around any function
that takes no arguments but returns something. By that logic, a `Future`
is a `Supplier`—it takes nothing and returns a value when you call the
`get` method. Why do I need a `Future` interface? (Let’s ignore its
other methods for now.)

It’s because they’re conceptually different. Futures are not necessarily
suppliers, and you might want to treat them differently. Even if you
don’t, giving different names to separate concepts generally helps you
keep your code base sane.

Here’s another one:

    interface Builder<T> {
        T build();
    }

Not a supplier. I’m going to have lots of methods on my builder, of
which `build` is just one, and I want it to be called exactly that. Not
`get`, `build`, because it explains nicely what’s happening.

And if I want to convert, well, that’s easy:

    gimmeASupplier(() -> builder.build());

And thanks to method references, we can even short-circuit that:

    gimmeASupplier(builder::build);

(Ask me about method references some time.)

And as a bonus
--------------

Funnily enough, Guava’s `Function` type is a functional interface too.

    public interface Function<F, T> {
        @Nullable T apply(@Nullable F input);
    }

So if I’m already using Guava and want to keep at it, there’s no
problem. This works just fine:

    Iterables.transform(numbers, x -> x * x);

Backwards-compatibility is a lovely thing when it’s done right. Lambdas
in Java have been a long time coming, but now they’re just around the
corner and I’m really looking forward to them.

*If you want to experiment with lambdas, download the [early access
release](http://jdk8.java.net/lambda/). The latest versions of [IntelliJ
IDEA](http://www.jetbrains.com/idea/) have great support for Java 8 with
lambdas.*

