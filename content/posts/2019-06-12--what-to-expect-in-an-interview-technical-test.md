---
title: "What to expect in an Interview Technical Test"
slug: what-to-expect-in-an-interview-technical-test
date: 2019-06-12T16:00:00Z
---

Chipo, on the [Codebar Slack][], asked what they could expect in a technical test. I wrote a pretty long answer, which I thought might be useful to others as a blog post (after a bit of cleanup).

---

I'd typically expect a "tech test" to involve implementing a small program, typically on the command line, as well as you can. Often they’ll expect you to write unit tests and practice good design principles (low coupling, good names, etc.)

Sometimes they send you an exercise to do and you send the results back, and sometimes you do it in their office with someone looking over their shoulder. They’ll usually ask you to bring a computer if it’s the latter, but don’t be afraid to ask to borrow one (and specify the kind of coding environment you’re used to) if you don’t have one available.

<!--more-->

If the interviewer expects you to use a specific programming language, framework or set of libraries, they should specify them up-front. If you're not clear on the technical requirements (for example, if they expect you to use a language or framework you've not used before), be up-front and honest. They might change the conditions for you, and if they don't, at least you'll have a good idea of whether you can get the job before you put much effort into it.

I recommend doing a few of the exercises from [Kata-Log][] to start. Perhaps one from [the software design section][kata-log: software design]. (Choose one that doesn’t have a “Constraint” and isn’t “Refactoring”-oriented.)

If you want a recommendation or three, I suggest:

- [Game of Life Kata][]
- [Lift Kata][]
- [Social Network Kata][]

(I wrote that last one.)

I also recommend the [“Shopping Cart”/“Checkout” kata][checkout kata].

Practice your best coding. Write tests (ideally first), design well, and don’t be afraid to refactor. Commit often so you can easily revert if things aren’t going well. And take your time! In my experience, I do much better in interviews when I go slowly and talk through the problem. If there is a time limit, be conscious of it, but don't fret about it too much. You're better off turning in good, working code that solves 50% of the problem than a "finished" solution that breaks if you poke it the wrong way.

On that note, I also recommend practicing explaining what you’re doing as you do it. You’ll need to do that in most in-person interviews. If you have an assumption, practice stating it out loud.

On the other hand, if you’re doing this at home, make sure to write a README. Include:

- a brief description of what the program does (e.g. "this is a simple implementation of an online shopping cart")
- the major languages/frameworks/libraries you used (e.g. “this project is written using Ruby on Rails”, or "I used Express for the server, and React + Redux on the client".)
- how you approached it, including programming techniques such as TDD, object-oriented programming, etc.
- how to run it from scratch (assuming they have the latest version of the programming language installed, but no extra libraries)
- how to run the tests from scratch
- any assumptions you made
- anything you’d improve if you had more time

Good luck on your next technical test!

[codebar slack]: https://slack.codebar.io/
[kata-log]: http://kata-log.rocks/
[kata-log: software design]: http://kata-log.rocks/software-design
[checkout kata]: http://codekata.com/kata/kata09-back-to-the-checkout/
[game of life kata]: http://kata-log.rocks/game-of-life-kata
[lift kata]: http://kata-log.rocks/lift-kata
[social network kata]: http://kata-log.rocks/social-network-kata
