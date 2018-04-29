---
title: "Functional Poker Hands in Java"
slug: functional-poker-hands-in-java
date: 2011-12-02T13:20:00Z
---

A few weeks ago, I wrote about [a workshop I ran at Skills
Matter](http://monospacedmonologues.com/post/12118361399/workshop-functional-programming-in-oo-languages)
and posed the question to you guys. If you haven't seen it, I encourage
you to go check it out—everybody had a lot of fun. What better way to
spend a weekend than writing interesting code, right?

So. I figured it was my turn. And, being a bit of a masochist, I decided
to do it in Java. So I fired up Eclipse and started writing some tests.
I started by testing the FunctionalList class as I'd neglected to
provide any straight off, and then wrote my first acceptance test: "this
hand contains a pair". Before long I was neck-deep in anonymous
functions and regretting my decision to use such a backwards language
(come on Java 8!), but it was really interesting and taught me a lot
about the intricacies of generics. Having to implement a functional map
as well as add a bunch of methods to the list was pretty mental—maps
work pretty differently when they're immutable. I ended up just
implementing it in terms of a list, which is slow but easy. Next time I
think I'll try for a proper O(1) lookup table.

<!--more-->

Here's the thing I'm most proud of: figuring out whether a hand
contained a straight. It involved predicates, set combinations and an
interesting attempt at equality.

    public enum Category {
        ...

        Straight("Straight", new Predicate<FunctionalList<Card>>() {
            @Override public boolean matches(final FunctionalList<Card> cards) {
                return cards.combinationsOfSize(5).contains(new Predicate<FunctionalList<Card>>() {
                    @Override public boolean matches(final FunctionalList<Card> groupedCards) {
                        return areConsecutive(groupedCards.map(rank()), Card.RANKS);
                    }
                });
            }
        }),

        ...

        private static <T> boolean areConsecutive(final FunctionalList<T> list, final FunctionalList<T> order) {
            return list.isEqualTo(order.dropWhile(not(equalTo(list.head()))).take(list.size()));
        }

        ...

        private static Function<Card, Rank> rank() {
            return new Function<Card, Rank>() {
                @Override public Rank apply(final Card card) {
                    return card.rank();
                }
            };
        }
    }

Mental, right? You should see the other stuff. Fortunately, if my naming
is as good as I think it is, you don't need to. It's pretty readable as
it is (though by no means perfect: I should have extracted that
anonymous predicate, for one). Of course, if you do want to follow the
code around, it's [available on
Github](https://github.com/SamirTalwar/Texas-Hold-Em).

One thing I wish I'd done better was to hold onto the idea of inversion
of control. It works differently when developing in a functional style,
but it definitely works. That would have given me more fine-grained
control over my testing, rather than relying on acceptance tests to
cover everything. The business stuff is tested, but a lot of the helper
methods are not. I should have pulled them out into their own classes
and pumped them in from the top.

If you did attempt the problem, I'd love it if you looked through [my
code](https://github.com/SamirTalwar/Texas-Hold-Em) and told me what you
did differently. Did you pass generic functions around? Did you add
methods to `FunctionalList`, or put them somewhere else? Did you extract
a ton of methods—more than you usually would? How hard was it to name
things? Was it more complicated than mine or simpler?

Did you learn anything?
