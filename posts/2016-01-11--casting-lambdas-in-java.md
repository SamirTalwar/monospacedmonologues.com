---
title: "Casting Lambdas in Java"
date: 2016-01-11T08:00:21Z
---

I love Java 8. It's so much better than Java 7. Not as nice as a properly functional language, of course, but beggars can't be choosers, am I right?

It's a bit odd for a language that's trying to be functional, though. [Functions are objects][Functions are Objects: the other point of view], and often a lambda can be one of many types. This is usually fine:

    Stream.of(1, 2, 3)
        .map(x -> x * 2)
        .forEach(System.out::println);
    // prints:
    // 2
    // 4
    // 6

However, sometimes it's not. For example, if I want to create a list (or another generic type) of functions and immediately iterate over them:

    Stream.of(x -> x + 2, x -> x - 2, x -> x * 2, x -> x / 2)
            .forEach(f -> f.apply(5));
    // compile error:
    // java: incompatible types: cannot infer type-variable(s) T

Or, perhaps, you might want to invoke a method that is overloaded to take one of several functional types:

    <T> T run(Callable<T> c) throws Exception {
        return c.call();
    }

    <T> T run(Supplier<T> s) {
        return s.get();
    }

    void doSomething() throws Exception {
        run(() -> 7);
        // compile error:
        // java: reference to run is ambiguous
        // both method <T>run(java.util.concurrent.Callable<T>) in MyClass
        // and method <T>run(java.util.function.Supplier<T>) in MyClass match
    }

In both of these cases, you'll need to cast the lambda to the type you're looking for:

        run((Supplier<Integer>) () -> 7);

… Wow, that's ugly. Imagine if the return type was a little more complicated:

        run((Supplier<ConcurrentMap<String, List<AtomicReference<Spanner>>>>)
                () -> {
                    …
                });

The lambda is pushed to the next line because I don't even have space. Brilliant.

Fortunately, there's a trick we can use. In the [Guava][] library, there are lots of static methods similar to the following:


    public static <E> ArrayList<E> newArrayList() {
        return new ArrayList<E>();
    }

This seems pointless, but prior to Java 7, there was a definite advantage to using this method over the constructor directly: the compiler would infer the generic type for you. So instead of typing:

    List<AtomicReference<Spanner>> spanners =
            new ArrayList<AtomicReference<Spanner>>();

You could just type this:

    List<AtomicReference<Spanner>> spanners = newArrayList();

Now, of course, the diamond operator has superseded this, so you can just type `new ArrayList<>()`, but the technique is still useful. Method calls are a very useful way of specifying type information.

So, if I create a static method called `supplier` that does absolutely nothing except return the input:

    public static <T> Supplier<T> supplier(Supplier<T> value) {
        return value;
    }

I can use it to force the lambda to the type of `Supplier` with far less noise than a cast.

        run(supplier(() -> 7));

I can be fairly confident here that the JVM will take care of any performance impact in the long run, and the compiler is happy. Not only that, my eyes can stop hurting now.

[Functions are Objects: the other point of view]: http://monospacedmonologues.com/post/58923319303/functions-are-objects-the-other-point-of-view
[Guava]: https://github.com/google/guava
