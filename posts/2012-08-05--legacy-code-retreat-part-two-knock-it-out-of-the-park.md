---
title: "Legacy Code Retreat part two: knock it out of the park"
date: 2012-08-05T06:41:00Z
---

[Part
one](http://monospacedmonologues.com/post/28626062275/legacy-code-retreat-part-one-get-it-under-test)
was about understanding the code. Part two is all about changing it.

So after a tasty lunch, we cracked on. Throughout the first half, I was
constantly asking people if they had written enough test cases. After
lunch, I encouraged them to crack on with the refactoring. We started by
extracting classes in **session four**. It’s something we do all the
time, but I think it’s very important to formalise the method so we
understand when we’re doing something slightly different.

I asked people to try it in a very specific way in this session:

1.  Identify an area which breaks the [single responsibility
    principle](http://en.wikipedia.org/wiki/Single_responsibility_principle).
2.  Extract the offending behaviour into its own method or function. If
    it’s a function, pass the object in and let the method see its
    parameters to minimise the effort required.
3.  Remove all references to the object itself. This might mean making
    it static, or pulling it out of the class, or if you’re passing the
    object in, removing the parameter. Instead, pass in the things it
    needs.
4.  Move that method to a new class and make it publicly accessible.
5.  Write tests for it.
6.  Refactor it until you like the interface.

These six steps allow us to operate in very small chunks, commiting to
our version control as we go, which dramatically decreases the odds of
making a mistake.

**Session five** was a small extension to this: [inversion of
control](http://en.wikipedia.org/wiki/Inversion_of_control). This really
is just a specific form of refactoring your new interface. If you have a
dependency, it should be explicit, and not hidden away. This means it
should be passed in to your class constructor. If you don’t have or
aren’t using classes, that’s fine, but your object builders should
understand and expose the dependencies. It’s a small change in your way
of thinking, but it makes your code so much more maintainable as you can
easily identify which concepts are used in any given piece of code.

Let’s look at this tiny class:

    public class Kamikaze {
        public void explode() {
            System.out.println("Banzai!");
            throw new Exception("BOOM.");
        }
    }

It has a hidden dependency you may not have even noticed: `System.out`.
It’s just a `PrintStream`, but it’s important to the program and we
should know that it uses it. Otherwise, the side effects could cause
problems later on (for example, if we connected our program to a printer
or a public-facing console).

Let’s pull it out:

    public class Kamikaze {
        private final PrintStream out;

        public Kamikaze(PrintStream out) {
            this.out = out;
        }

        public void explode() {
            out.println("Banzai!");
            throw new Exception("BOOM.");
        }
    }

By passing the `PrintStream` into the constructor, we know as soon as we
create the object that at some point, it will print. In a simple class
like this, we can know roughly when just by looking at the interface. It
also makes testing easier: we can pass in a fake or mocked stream and
perform assertions on it without hitting the real console.

Beautiful, isn’t it?

Finally, we came to the **last session**, which was a free-for-all.
People switched pairs, as they did every round, but they didn’t delete
their code, and they carried on as they liked. Some implemented a new
feature, some tried [baby
steps](http://talboomerik.be/2012/01/16/taking-baby-steps/), and some
decided to go cowboy-style and threw away testing. We really enjoyed it
and everyone learned something, in the area they were most interested
in. Because they chose.

The majority of people were very interested in the golden master
technique, but I got the general feeling they’d taught themselves a lot
as they went through all the steps and really thought hard about exactly
how they approached problems. And the beer afterwards was great.

I forgot to mention it on the first post, but I’d like to thank [J. B.
Rainsberger](http://twitter.com/jbrains) for coming up with this whole
concept, and [Adi Bolboaca](http://twitter.com/adibolb) and [Erik
Talboom][@talkboomerik] for driving it home. I’d also like to thank J.
B. for creating the code base we all hate. I loved the day, and I hope
to run another Legacy Code Retreat soon.
