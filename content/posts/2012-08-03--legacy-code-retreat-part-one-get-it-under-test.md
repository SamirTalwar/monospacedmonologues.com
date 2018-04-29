---
title: "Legacy Code Retreat part one: get it under test"
slug: legacy-code-retreat-part-one-get-it-under-test
date: 2012-08-03T13:11:00Z
aliases:
  - /post/28626062275/legacy-code-retreat-part-one-get-it-under-test
---

It's been a while, but people have convinced me that I need to crank
this one out.

A little while ago, [Sandro](http://twitter.com/sandromancuso) and I ran
the UK's first Legacy Code Retreat. Essentially, it works like a regular
code retreat, where people come together to solve a problem again and
again in a multitude of different ways. The difference with this one is
simple: we don't start from scratch. You don't implement Conway's Game
of Life over and over again, but instead start with [a terrible piece of
code](https://github.com/jbrains/trivia). Your task is to understand it
and clean it up.

Cleaning, of course, starts with testing.

<!--more-->

**Session one**: understand the code. Just read it. Don't change it.
Don't start refactoring. *Please* don't start fixing it. Just find out
what it does.

Know what it does? Alright, prove it. Start writing tests. Write tests
until a method is completely covered. If any of them go red, your
assumptions were wrong. But that's OK, just correct them. When you're
covered and green, sit back and smile. Session one finished five minutes
ago. Everyone's staring at you.

What was hard? Did you feel the urge to start changing the code? Yes?
Good. You're normal. We all do. The trick is to not give in to instinct.

Right. Onto **session two**. Session two is a *bit* different. Testing's
too easy. Let's make something that makes the test. We're going to
create a *golden master*.

The [*trivia*](https://github.com/jbrains/trivia) project is a nice one
with which to do this, as all the output is dependent on a single random
number generator. And while the numbers are pseudorandom, we can control
which branch of the randomness comes out simply by providing a seed. By
a small change to the application, you can pass the random number seed
in through the command line rather than using the default seed (which is
usually the current time). Something like this:

    public static void main(String[] args) {
        Random random = args.length >= 1 ? new Random(Integer.parseInt(args[0])) : new Random();
        ...
    }

Now we can generate a ton of test cases simply by varying the input and
capturing the output. By storing the input and output in files, we can
write a simple test that iterates through all of them, runs the
application again and asserts that the output has not changed. We have a
massive suite of regression tests, which we can use to defend against
unwanted changes.

This one was a tricky one to grasp for a lot of people, including me the
first time I tried it. We had a bit of trouble explaining random number
seeds, and some people were scratching their heads over the large number
of tests. This just requires a bit of one-on-one chatting when people
get stuck.

It's important to note that the golden master is not a replacement for
unit tests. Rather, it gives you a safety net. The tests will tell you
that something changed, but not what. They also won't tell you whether
it *should* have changed—you need to decide that for yourself. What you
really have here are a lot of very slow, crap tests. This is better than
no tests at all, but not by much. The next thing to do is to go back to
what we were doing in session one: writing unit tests to cover code.
Only then can we refactor, safe in the knowledge that if we screw up,
our unit tests will probably catch the problem, and if not, we have the
golden master tests sitting there, ready.

Our **third session** brought in another technique that has been dubbed
"subclass to test". The idea is to identify what [Michael
Feathers](http://books.google.com/books/about/Working_effectively_with_legacy_code.html)
calls a *seam*: an area of code you can modify without changing the
actual code itself. In this case, we can modify a method for testing by
subclassing and overriding the specific method. Combined with extracting
methods, this is a very powerful tool for getting code under test. For
example, if I have some code that uses a static factory to get a
reference to the database:

    public User createUser() {
        User user = new User();
        Database.getDatabase().save(user);
        return user;
    }

We can yank that out into a method, using automated refactoring tools to
do so if we have them available.

    public class UserMaker {
        public User createUser() {
            User user = new User();
            database().save(user);
            return user;
        }

        protected Database database() {
            return Database.getDatabase();
        }
    }

Now we have a seam. We can override that in tests to return a mock so we
don't have to touch the database.

    public class UserMakerTest {
        private final Database database = mock(Database.class);

        ...

        private static class UserMakerForTesting extends UserMaker {
            @Override
            protected Database database() {
                return database;
            }
        }
    }

Look at that. Previously untestable code is now testable. Easy, right?

This was the first half of the day. I think it went pretty well, and the
feedback was great. In my next post, I'll be tackling the second half:
fixing the code base.

[*Part two of the Legacy Code Retreat double act is now available. I
hope you enjoy
it.*](http://monospacedmonologues.com/post/28752243811/legacy-code-retreat-part-two-knock-it-out-of-the-park)
