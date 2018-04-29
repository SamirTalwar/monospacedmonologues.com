---
title: "Dependency Inversion, and how to get it wrong"
date: 2013-07-31T16:04:01Z
---

I've been building a new application in Clojure over the last week or
so, and it seems to be going quite well. I like the syntax, using a
functional language has been great, and it's got enough gold in it that
I can ignore the small pockets of
["wat"](https://www.destroyallsoftware.com/talks/wat).

<!--more-->

I started with `clojure.test`, the test framework packaged with Clojure
itself, but quickly decided I didn't like the style, or the lack of more
advanced testing functionality such as matchers and test doubles (i.e.
stubs, mocks, etc.). So I turned to
[Midje](https://github.com/marick/Midje), which comes highly recommended
by my friend [Alex Baranosky](https://twitter.com/Baranosky) (who's
committed more code to the project than anyone aside from the original
author, Brian Marick). Midje, aside from having a lovely syntax for
writing tests (or "facts", as it calls them), has equivalents to
matchers ("checkers") and test doubles ("prerequisites") which make
top-down development manageable.

There's only one issue I have with the way that prerequisites work in
Midje: they re-wire the function you're testing so that when it calls
the stub, it gets rerouted to another function. This means you can also
stub a real function in order to replace behaviour for testing purposes.

People are divided on whether you should do this. In the Java world, you
have PowerMock, which can replace bytecode in order to mock out static
methods and all sorts of other fixed behaviour. On the opposing side,
jMock doesn't even let you stub or mock methods declared on classes by
default, limiting you to mocking interfaces unless you give it a special
override.

My opinion is that the authors of jMock ([Nat
Pryce](https://twitter.com/natpryce) and [Steve
Freeman](https://twitter.com/sf105)) knew what they were doing. They
hint at it with their JAR names—the override for mocking classes is in a
JAR named *jmock-legacy-[version].jar*, implying that you should only
use this when testing legacy code.

That's not because they don't want you to test legacy code. It's because
mocking classes **produces** legacy code.

So here's a test, using Midje:

    (fact "you can send a direct message to people who can follow you"
      (autocomplete "D b") => ["Bob", "b3t4t3st3r"]
      (provided (twitter/followers) =>
        ["Alice", "Bob", "b3t4t3st3r", "Carol", "chuck"]))

What's wrong with this test? I've coupled the behaviour of
`autocomplete` to the `twitter/followers` function, and then overridden
the behaviour in the test. This has produced coupling between my
function and Twitter itself, which means my code will be inflexible and
hard to change later. The reason Nat and Steve made it difficult to mock
out classes is because they didn't want you to couple the implementation
of collaborators—instead, you should be mocking at the interface level.
Testing collaboration between concrete classes *should* be hard—as Steve
has so often said, **your tests are telling you something**. Listen to
them. Fix your code.

In this case, we can fix it by constructing our `autocomplete` function
with a reference to `twitter/followers`, and then passing in a stub in
the test. By doing this, we decouple `autocomplete` from the Twitter API
and allow it to do just one thing.

    (unfinished followers)
    (def autocomplete (new-autocomplete followers))

    (fact "you can send a direct message to people who can follow you"
      (autocomplete "D b") => ["Bob", "b3t4t3st3r"]
      (provided (followers) =>
        ["Alice", "Bob", "b3t4t3st3r", "Carol", "chuck"]))

Note: `unfinished` is a Midje function that creates a mock function.

Same behaviour, roughly the same test, and the only thing to change in
the implementation is an extra parameter. This was even easier to do
than it is in Java or C\#! So what does it give us?

By replacing some code that overrides behaviour with code that *injects*
the dependency, we reduce our system's reliance on one specific source
of information and make it far more flexible. Now, if I decide I want to
work with Facebook, I can add that functionality without touching the
`autocomplete` function itself. How cool is that?

Stubbing is a powerful tool, and with great power comes great
responsibility. Use it wisely. When it becomes difficult to change a
test or write a new one, or when you have to change a hundred tests to
make a one-line change to some behaviour, ask yourself: what are my
tests telling me about the quality of my code?
