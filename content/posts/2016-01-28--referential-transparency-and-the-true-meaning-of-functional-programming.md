---
title: "Referential Transparency, And The True Meaning Of Functional Programming"
date: 2016-01-28T08:00:12Z
---

Programming is compromise. No matter how you design your system, you will be compromising something, whether it's flexibility in one axis for flexibility in another, or simplicity for the ability to create new features. All designs are "wrong", for some definition of wrong. The important thing is whether they're right enough for your purposes.

Before you carry on, I suggest you read the last three articles:

  1. [Getters, Setters and Properties][]
  2. [Why Couple Data to Behaviour?][]
  3. [The Other Trade-off: Separating Data and Behaviour][]

The previous three articles in this series focus on different trade-offs we can make, comparing object-oriented and functional code. I'd like to tie these two together. But first, I'd like to talk about referential transparency.

<!--more-->

## Referential Transparency

From [the Haskell wiki][Referential transparency]:

> Referential transparency is an oft-touted property of (pure) functional languages, which makes it easier to reason about the behavior of programs. I don't think there is any formal definition, but it usually means that an expression always evaluates to the same result in any context. Side effects like (uncontrolled) imperative update break this desirable property. C and ML are languages with constructs that are not referentially transparent.

So, for example, in Scala, the expression `2 + 2` always evaluates to `4`, and the expression `(1 to 10).filter(even)` always evaluates to `IndexedSeq(2, 4, 6, 8, 10)`. This property, of course, doesn't hold for things like database or file system operations, or I/O in general. Reading from the command line could result in a different value every time.

In a system where everything is referentially transparent, everything must of course also be immutable. For example, taking the function `even` below:

    def even(numbers: Seq[Int]) = numbers.filter(_ % 2 == 0)

(The `_` symbol is a placeholder for the input to the lambda expression. `_ % 2 == 0` could also be written as `n => n % 2 == 0.`)

If sequences in Scala were mutable, `numbers.filter(even)` could not be guaranteed to return the same value each time in the same context, or scope. Once `numbers` is set, it cannot be modified, but we *can* call our `even` function again with a different sequence, which results in a different context and therefore a different result.

This style of design is antithetical to typical object-oriented design, in which messages are passed to objects and return values are optional. In this style of programming, mutation is normal, and objects can manipulate their state at will—just take our `Account` class from the first article as an example.

However, while we lose the object-oriented message-passing style, there are a number of advantages to immutability. I want to focus on one: as we saw in yesterday's article, because the state of an object does not change, there's far less harm in inspecting the data inside that object. We can be aware of the primitive make-up of the object, and even deconstruct it. Taking the `Deposit` class as an example:

    case class Deposit(amount: Int, date: LocalDate) extends Transaction

We can construct a deposit:

    val deposit = Deposit(50, LocalDate.of(2015, 1, 28))

But we can also deconstruct it:

    val Deposit(amount, date) = deposit
    assert(amount == 50)
    assert(date == LocalDate.of(2015, 1, 28))

Deconstruction opens up a few doors to us, the most obvious one of which is pattern matching:

    def applyTransactionToBalance(transaction: Transaction, balance: Money): Money =
      transaction match {
        case Deposit(amount, _) =>
          balance + amount
        case Withdrawal(amount, _) =>
          balance - amount
      }

Using pattern matching, we can perform different behaviour based on the exact value (and type) we're dealing with.

## Flexibility

In Java, we have the `java.util.List<T>` interface, with lots of methods including `add`, `remove`, `get` and `forEach`. We can see from the interface that lists are mutable, in that we can invoke a method on the list to change its underlying data. `List<T>` has lots of implementations, including `ArrayList<T>`, `LinkedList<T>` and `CopyOnWriteArrayList<T>` in the standard library, and lots more in third-party libraries.

Consider the ease of adding a new `List<T>` implementation. You need to add a new class, implement the interface (or more likely extend `AbstractList<T>`)… and that's it. One file, and you're done.

Now consider adding a new method to the `List<T>` interface—one that can't be implemented on the interface itself as a default method. You can't do it. Any change you make will break every implementation of `List<T>` on the planet. When dealing with object-oriented code in which data and behaviour are coupled, extending the number of implementations of an interface is trivial, but extending the behaviours on the interface is tricky without a lot of extra work.

---

Let's step to the side for a moment and look at the `List[A]` abstract class in Scala, which aligns pretty well with other functional languages.

    sealed abstract class List[+A] extends Seq[A] { // simplified
      def isEmpty: Boolean
      def head: A
      def tail: List[A]
    }

    case object Nil extends List[Nothing] {
      override val isEmpty = true
      override def head = throw new NoSuchElementException("head of empty list")
      override def tail = throw new NoSuchElementException("tail of empty list")
    }

    case class ::[+A](head: A, tail: List[A]) extends List[A] {
      override val isEmpty = false
    }

Here, we have a linked list implemented as a union of `Nil` and `::` (pronounced "cons", because it *constructs* lists, and treated as an operator with the `head` on the left and the `tail` on the right), which we can use to construct a list. For example, `List(1, 2, 3, 4, 5)` is really:

    1 :: 2 :: 3 :: 4 :: 5 :: Nil

Notice that we don't have any methods on `List` except for three very basic ones, `isEmpty`, `head` and `tail`. We don't need them. `map`, `filter`, etc. are on the `List` class for convenience, not because they need access to the internals. Everything is public. For example, here's an implementation of `map` that works on a list that's passed in:

    def map[A, B](f: A => B, list: List[A]): List[B] =
      list match {
        case Nil => Nil
        case head :: tail => f(head) :: map(f, tail)
      }

We can add any behaviour we like to `List[A]` without much hassle with simple deconstruction and pattern-matching.

But… what if we want to switch to handling array-backed lists instead of linked lists? Arrays don't have `head` and `tail`, they're just contiguous blocks of memory, and reimplementing them in terms of a *head* and *tail* is a great way to lose any performance benefits you might achieve from them. Any functions we implement on top of `List[A]` will have to be completely rewritten. It's a much more complicated and time-consuming operation.

## And So, The Crux Of The Matter

Object-oriented programming and functional programming are both wonderful tools, and to a certain extent you can get the values of both in your code. However, in some cases, you will need to make a decision on the direction in which you want to be flexible. Sometimes you can achieve both, but often at the cost of simplicity.

Object-oriented code is made up of *open sets* of implementations, but the behaviour being implemented is generally a *closed set*.[^1] Functional programming, conversely, has a *closed set* of implementations, but the behaviour is completely *open*—anyone can add a new piece of behaviour that operates on a data structure. This is not to say that you can only write object-oriented code in Java or only functional code in Haskell, but the languages do lend themselves toward that style of design.

Regardless of your choice of language, your choice of paradigm will have far-reaching consequences to the kinds of changes you can easily make to your software, which will have a direct impact on cost and therefore the kinds of changes that *are* made after evaluating costs and benefits. This decision is often the sort you make early on and rarely change, so give it some real consideration. You might never get to change it.

[^1]: Thanks to [Ganesh Sittampalam][@eleganesh] for the terminology used here; I've never heard anyone else refer to *open* vs. *closed* sets.

[Getters, Setters and Properties]: http://monospacedmonologues.com/post/138009972532/getters-setters-and-properties
[Why Couple Data to Behaviour?]: http://monospacedmonologues.com/post/138076164433/why-couple-data-to-behaviour
[The Other Trade-off: Separating Data and Behaviour]: http://monospacedmonologues.com/post/138140507048/the-other-trade-off-separating-data-and-behaviour

[Referential transparency]: https://wiki.haskell.org/Referential_transparency
[@eleganesh]: https://twitter.com/eleganesh
