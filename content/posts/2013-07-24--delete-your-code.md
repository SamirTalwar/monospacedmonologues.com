---
title: "Delete Your Code"
slug: delete-your-code
date: 2013-07-24T16:53:00Z
aliases:
  - /post/56342912170/delete-your-code
---

That was my battle cry at Palantir's first ever code retreat.

Last weekend, we spent two and a half days out in the beautiful English
countryside on some of the hottest days of the year so far. The agenda
was as follows: Friday afternoon was to be dedicated to TDD, a code
retreat was held on Saturday, and on Sunday, we held our least hacky
"hackday" ever.

Thanks so much to [Adrian Bolboaca](https://twitter.com/adibolb) for
helping plan the first two days of this event, and to my colleagues Huw,
Joe and Michael for organising the event and the venue.

<!--more-->

## Level 1: TDD

We started with an introduction to test-driven development, partially
historical, but mostly practical. I wrote the simplest test I've ever
written:

    @Test public void
    says_hello_to_the_entire_world() {
        Hello hello = new Hello();
        assertThat(hello.world(), is("Hello, world!"));
    }

And proceeded to make it pass. (This is left as an exercise for the
reader.) After a few more iterations on this, implementing
`hello.to("Bob")`, the group of ten was ready to try to write tests,
some for the first time. I kicked them off with the [Anagram
kata](http://codingdojo.org/cgi-bin/wiki.pl?KataAnagram) and watched
them work, occasionally dipping in to offer advice. Because people were
arriving throughout the day, most of my time was spent redoing my
"Hello, world!" demonstration.

Obviously, as newbies to the genre, there were a lot of misconceptions,
and people had a really hard time writing the simplest possible code to
make their tests pass. On the other hand, we had some real wins, most
notably in people discovering the need for other kinds of testing
disciplines. Some found the desire to write outside-in tests (even
acceptance tests, in one case) before going too low-level, and a couple
more essentially reinvented property-based testing.

And then we went and had some drinks and a good night's sleep. Tiredness
kills, and I was planning on tiring everyone out tomorrow.

## Level 2: The Code Retreat

I've blogged extensively about [code retreats](/post/13794728271/global-day-of-coderetreat)
and [legacy code retreats](/post/28626062275/legacy-code-retreat-part-one-get-it-under-test)
before, but there were some notable differences between this one and the
others in which I've participated or facilitated. They were mostly due
to the inexperience of the attendees, resulting in a retreat that was
much more of a teaching exercise than is usual. I'm glad to say that
most of the teaching was still done between pairs, though, which is
always the result I'm looking for in an event like this. As with other
code retreats I've run, the kata used was Conway's Game of Life, and
sessions were 45 minutes long.

The morning gave way to a large amount of frustration as people had to
un-learn the habit of churning out code without too much thinking about
design and scope. Palantir is full of developers who can crank out a
million lines of code a day, so getting them to slow down and not worry
about being too productive was pretty difficult. After a few sessions,
people were starting to get into the habit of writing The Simplest Thing
That Could Possibly Work™, and so over lunch, I started scheming on how
to mess with their brains a little more.

A delicious meal gave way to session four, in which I gave a
demonstration of test doubles and [the differences between stubs and
mocks](http://martinfowler.com/articles/mocksArentStubs.html), as well
as explaining [the difference between Classic TDD and the "London
School"](http://codemanship.co.uk/parlezuml/blog/?postid=987). I then
told everyone to go and develop a solution to the kata from the
outside-in, using mocks to drive the design of their application. There
was a lot of head-scratching, and no one came away with much code, but
the seed of top-down development was planted.

The last two sessions were designed to completely blow people's minds
and really show them why TDD is useful, as well as teaching them some
new tricks. I used Adi and Erik's [baby
steps](http://talboomerik.be/2012/01/16/taking-baby-steps/) idea to get
people hyperactive, and then dropped Jeff Bay's [object
calisthenics](http://www.mabishu.com/blog/2012/12/14/object-calisthenics-write-better-object-oriented-code/)
on them to round off the day with something really thought-provoking.
Both of these sessions went down really well—I think that for the first
time, things really became challenging for everyone. Object calisthenics
really emphasises the need for outside-in design, as it firmly forbids
breaking state encapsulation, which I think helped people understand the
need for that approach to software design and TDD.

Finally, just to show off, I demonstrated how a decent implementation
that follows the rules of object calisthenics can be actually quite
beautiful.

The feedback was overwhelmingly positive. Except for the limit on the
drinks, because ~~people are alcoholics~~ ~~alcohol is a human right~~
we're pretty spoilt.

![Code Retreat
Feedback](https://lh5.googleusercontent.com/-1dT75aTHFMY/UeuXs-PydUI/AAAAAAAAAcE/aGQAxEpW_Rs/w718-h957-no/IMG_20130721_091015.jpg)

## Level 3: (Not a) Hackday

Because everyone loves hackdays, we had one. Except this was a hackday
with a twist: no hacking allowed. Pair programming was mandatory and not
testing was punishable by being locked in a dark box and having your
drinks taken away.

With one exception, people worked on new projects or standalone
features—we hadn't covered testing legacy code, and I don't think anyone
was really in the mood to spend a Sunday banging their heads against
walls. We worked on a bunch of cool things, but by far my favourite was
the beginnings of a testing framework for an in-house proprietary
language, spearheaded by the guy who was initially very much against
writing tests. I think it's safe to say he's thoroughly converted.

All in all, great success. I'm really glad that everyone discovered the
main lessons of the whole weekend: that tests really don't slow you
down, and you learn faster by pairing than by any other method I've
found.

Oh, and the drinks and the weather were sublime.

![Pimms and
Sunshine](https://lh5.googleusercontent.com/-t6szwtrq-i8/UerI38_ZghI/AAAAAAAAAa8/uz0yhDn8UIU/w718-h957-no/1374341313103.jpg)
