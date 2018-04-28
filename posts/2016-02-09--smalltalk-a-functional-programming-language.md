I was watching [Sandi Metz][@sandimetz]'s talk, [Nothing is Something][], recommended to me by [Pawel Duda][@pawelduda] in the comments of my post, [Why Couple Data to Behaviour?][]. In the talk, she said something that I've always found fascinating.

In the talk, Sandi compares booleans in Ruby (and other "object-oriented" programming languages) to booleans in Smalltalk. She points out that Smalltalk has six keywords, and `if` isn't one of them. So how do you branch, without an `if` keyword?

It's very simple, truth be told. In Smalltalk, just like Ruby, `true` and `false` are objects—in Ruby, instances of `TrueClass` and `FalseClass` respectively. You could, if you prefer static languages, pretend these classes implement a fictional `Boolean` interface. However, unlike Ruby, Smalltalk provides two extra messages (methods) that solve our riddle.

Here's the first. Apologies if I'm off with the syntax; I'm not actually a Smalltalk developer, just a fan.

    (magnitude > 9000) ifTrue: [ ^self display: 'Over 9000!!!1111oneoneoneeleven' ]

And now in Ruby syntax, in case you're not familiar with the above:

    (magnitude > 9000).if_true { display 'Over 9000!!!1111oneoneoneeleven' }

And, of course, you have the `ifFalse:` message too:

    (magnitude >= 0) ifFalse: [ ^self error: 'A negative magnitude is ridiculous.' ].

These are standard library functions, not language-level primitives. One implementation might be to have an abstract superclass, `Boolean`, that wraps some native branching behaviour, but that would defeat the point of not having such functionality in the first place. Instead, Smalltalk uses polymorphism as its sole native branching mechanism.

In Smalltalk, `true` and `false` are singleton instances of the `True` and `False` classes. Here's what the implementation of `ifTrue:` and `ifFalse:` look like [in GNU Smalltalk's `True` class][True.st]:

    Boolean subclass: True [
        ...

        ifTrue: trueBlock [
        "We are true -- evaluate trueBlock"

        <category: 'basic'>
        ^trueBlock value
        ]

        ifFalse: falseBlock [
        "We are true -- answer nil"

        <category: 'basic'>
        ^nil
        ]

        ...
    ]

And, as you might imagine, `False` has exactly the opposite behaviour.

---

And now for something completely different. Let's take a look at some Lisp, courtesy of [Racket][]:

    (if (> magnitude 9000) "Over 9000!!!1111oneoneoneeleven" (format "~a" magnitude))

(`format "~a"` is Racket's `toString`/`to_s`.)

Notice that `if` in Racket (and every other Lisp I've seen) is most definitely something separate from booleans in general. In fact, it's not even a function, it's a *macro*—it modifies the code at compilation/interpretation-time to make the *then* and *else* expressions lazy, so they're not evaluated unless we go down that branch. Smalltalk, on the other hand, simply allows you to pass *blocks*, or functions, as part of the `ifTrue:` and `ifFalse:` messages.

This behaviour highlights [the difference between functional and object-oriented programming style][Referential Transparency, And The True Meaning Of Functional Programming], but I found it interesting that of the two, Smalltalk is the one making use of higher-order functions, which is, some would say, the hallmark of a functional programming language. I don't necessarily agree (and see the previous link for an explanation), but I still think it's fascinating that Smalltalk, the original OOP language, recognises that functions as method/message arguments is a perfectly reasonable thing do do.

So, if a Java programmer tells you that lambdas and higher-order functions weren't encouraged in the language for so long because they're not object-oriented, point them towards Smalltalk.

[Nothing is Something]: https://www.youtube.com/watch?v=OMPfEXIlTVE
[Why Couple Data to Behaviour?]: http://monospacedmonologues.com/post/138076164433/why-couple-data-to-behaviour
[Referential Transparency, And The True Meaning Of Functional Programming]: http://monospacedmonologues.com/post/138204666541/referential-transparency-and-the-true-meaning-of

[True.st]: http://git.savannah.gnu.org/gitweb/?p=smalltalk.git;a=blob;f=kernel/True.st;hb=HEAD
[Racket]: https://racket-lang.org/

[@pawelduda]: https://twitter.com/pawelduda
[@sandimetz]: https://twitter.com/sandimetz
