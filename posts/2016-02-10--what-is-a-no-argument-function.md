The other day, I was reading Eric Lippert's blog—specifically [the second post in his series on implementing a Z-machine in OCaml][North of house]—and something he wrote reminded me of a conversation I had with [Tom Denley][@scarytom] many years ago:

> This declares a variable called word, though “variable” is a bit of a misnomer in OCaml. Variables do not (typically) vary. (There are ways to make variables that vary – they are somewhat akin to “ref” parameters in C# – but I’m not going to use them in this project.) Variables are actually a name associated with a value.

In that conversation, we were talking about Google's [Guava][] library, and some of its functional interfaces. Here's one, cut down to the bare essentials:

    package com.google.common.base;

    public interface Function<F, T> {
      T apply(F input);
    }

If you've written any Java since Java 8 came out, you'll notice that [it has an interface that's basically identical][java.util.function.Function]. The fact that interfaces like this existed before Java 8 was one of the main reasons for [a lambda design that works with any functional interface][Functions are Objects: the other point of view], not just the ones in the standard library.

There's another interface, also in both Guava and Java now:

    package com.google.common.base;

    public interface Supplier<T> {
      T get();
    }

There's two differences between `Function<F, T>` and `Supplier<T>`. The first is obvious: `Function::apply` takes a single parameter—an input—and returns a single value—an output, whereas `Supplier::get` takes no parameters but returns a value. The second is more insidious. To make it clear, let me give you an example of each.

`Function<F, T>` is normally used in code like the following:

    Iterable<Integer> numbers = ImmutableList.of(1, 2, 3, 4, 5);
    Iterable<Integer> doubled = FluentIterable.from(numbers)
            .map(new Function<Integer, Integer>() {
                @Override public Integer apply(Integer input) {
                    return input * 2;
                }
            });

Or, with lambda expressions:

    Iterable<Integer> numbers = ImmutableList.of(1, 2, 3, 4, 5);
    Iterable<Integer> doubled = FluentIterable.from(numbers)
            .map(n -> n * 2);

That's your average `Function<F, T>`. `Supplier<T>`, on the other hand, is normally used like this:

    public class RandomNumberGenerator implements Supplier<Double> {
        private final Random random = new Random();

        @Override
        public Double get() {
            return random.nextDouble();
        }
    }

    public class Game {
        public static void main(String[] args) {
            Language language = Language.fromArguments(args);
            Game game = new Game(
                    new RandomNumberGenerator(),
                    Assets.from("assets.zip"),
                    Translation.forLanguage(language));
            game.play();
        }
    }

The example's contrived, but you get the idea. Whereas `Function<F, T>` is typically used for a transformation of the input in a *deterministic* fashion, `Supplier<T>` is often a mechanism for supplying *non-deterministic* or computationally-expensive dependencies.

Back to Tom (and Eric). In this conversation, I remarked that `Supplier<T>`, while useful for functional-like programming in Java, wasn't really very functional, as it isn't [referentially transparent][Referential Transparency, And The True Meaning Of Functional Programming]. Tom's response to was to ask me what, in FP, a no-argument function would be called.

I thought for a while. It didn't come to me immediately. But when it did, it was obvious.

A function with no arguments is a *value*.

Think about it. If you have no side effects, and therefore all behaviour is deterministic, then a no-argument function will return the same value every time. It is therefore interchangeable with that value—the two can be seen to be one and the same. Our random number generator above wouldn't work, and indeed, in Haskell, the random number generator's `next` function is declared as follows:

    next :: RandomGen g => g -> (Int, g)

Note that `RandomGen g => ` states that `g` is an instance of the `RandomGen` type class, which is similar to saying that `g` implements the `RandomGen` interface. In Java, this could be written as follows:

    <G extends RandomGen> Tuple<Integer, G> next(G generator);

`next` accepts a generator, `g` and returns a tuple, `(Int, g)`, where the `Int` is the random number and the `g` returned is the *next* random number generator to be used. If you used the same generator twice as input, you'd get the same output twice. This means we have to store the output and plug it into the next incarnation of the function.

Now, *procedures* without arguments…

[@scarytom]: https://twitter.com/scarytom
[North of house]: http://ericlippert.com/2016/02/03/north-of-house/
[Guava]: https://github.com/google/guava
[java.util.function.Function]: https://docs.oracle.com/javase/8/docs/api/java/util/function/Function.html
[Functions are Objects: the other point of view]: http://monospacedmonologues.com/post/58923319303/functions-are-objects-the-other-point-of-view
[Referential Transparency, And The True Meaning Of Functional Programming]: http://monospacedmonologues.com/post/138204666541/referential-transparency-and-the-true-meaning-of
