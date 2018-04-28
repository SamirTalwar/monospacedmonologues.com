---
title: "Check your I/O"
date: 2014-02-05T17:30:00Z
---

In Haskell, there's something known as the *IO monad*. The way it works is this: if you have it, you can do I/O. If you don't have it, you can't. You can pass it around, but you can never produce it from nothing. (Haskell aficionados, the comments are open for flaming in 3, 2, 1…)

Before we continue, I should elaborate a bit on what I/O *is*. It's basically anything that reaches out of the safe confines of your executable and touches the system in which it lives. For example:

* reading and writing files
* printing to the command prompt
* drawing something on the screen
* receiving information over a network interface

In short, if you're reading or writing, it's probably I/O.

Now, back to the IO monad. Here's how it looks:

    sayHello :: String -> IO ()
    sayHello name = putStrLn ("Hello, " ++ name ++ "!")

That first line is the *type signature*. It says that `sayHello` has one parameter, a `String`, and returns nothing (depicted by the empty tuple, `()`, sometimes called "unit") wrapped in the IO monad.

`putStrLn` is a function that prints to the console, and its type signature looks like this:

    putStrLn :: String -> IO ()

It also has `IO` in there. That's why `sayHello` requires the IO monad; without it, it couldn't call `putStrLn`.

<!-- more -->

## Doesn't that make my code look messy?

You might think it a bit prohibitive to only allow reading and writing where the code has explicitly received permission to do so, and sometimes it is. When it comes to software design, however, it's a blessing in disguise. Because you have to "pass around" I/O explicitly, application designers tend to keep it to the edges of their system, only allowing it at the entry points, and drop it as fast as possible in order to move into the pure world of functions that transform values, with no side effects. You end up with a [ports and adapters architecture][Hexagonal architecture] (which you can read about in [GOOS][Growing Object-Oriented Software]) for free.

## But I'm a Java programmer!

I was hoping you'd say that.

Java has something similar to the IO monad. It's not quite as powerful but from the point of view of software design, it does a similar job. It's called `IOException`.

Most methods in the Java standard library that deal with reading and writing declare that they throw `IOException`. It's a checked exception, so it must be declared or handled. And this is a *good* thing. It stops us from talking to the system all over the place. This allows us to decouple the application logic from the interface to the outside world, which makes our code cleaner *and* more fault-tolerant, as we can deal with all I/O failures in one place. If you find yourself catching `IOException` a lot, perhaps you should start to rethink your design to move the I/O to the edge of the system, keeping your core focused on the logic, rather than the interaction with users, signals (e.g. timers) and other computers.

So next time you see this:

    try {
        // query the database
    } catch (IOException e) {
        throw new RuntimeException(e);
    }

or even worse, something that swallows the exception and carries on, think about whether there's a better way. A way that allows you to get rid of that ugly `try`/`catch` block *and* make your code more robust at the same time.

[Hexagonal architecture]: http://alistair.cockburn.us/Hexagonal+architecture
[Growing Object-Oriented Software]: http://www.amazon.com/Growing-Object-Oriented-Software-Guided-Tests/dp/0321503627/
