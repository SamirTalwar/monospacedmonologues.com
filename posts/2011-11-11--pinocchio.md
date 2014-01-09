<!--
id: 12627672433
link: http://monospacedmonologues.com/post/12627672433/pinocchio
slug: pinocchio
date: Fri Nov 11 2011 04:08:25 GMT+0000 (GMT)
publish: 2011-11-011
tags: 
title: Pinocchio
-->


Continuing in the vein of forbidding things because they are BAD, here’s
another one that I hope will leave you scratching your head a little.

Brace yourself. Here it comes.

Don’t use `null`.

I realise that at this point, I’ve either lost you, or you’re a Haskell
programmer. So to the first group, I ask you, why doesn’t the Haskell
developer use `null` (or `nil`, `None`, `undefined` or their brethren)?
The simple answer is that they’re not necessary: the various catch-all
representations for “nada” can be elegantly discarded without causing
any problems. In fact, there are many ways in which you can aid
readability and maintainability by scrapping the whole concept.

The real answer is a bit more complex. I’m getting to that.

The first thing I want to talk about is a design pattern called *Null
Objects*.

Null Objects
------------

Null Objects are more useful in a statically-typed language such as Java
or C\#, but proponents of duck typing may also find them quite useful.
The idea is to create an implementation of an interface which
purposefully does nothing. For simple types, such as strings and
numbers, this usually means using zero or the empty string, but it could
also be a default specific to the situation.

In bizarro-world, I own a waffle house, and it’s important to me to know
how many waffles I sell each year. Fortunately, I know how many I’ve
sold on any given day, so all I need to do is add them all up. Of
course, the shop’s closed on public holidays—I need to nurse my hangover
on New Year’s Day same as everyone else—so I don’t record the number of
sales on those days. I have a simple lookup table that tells me how many
waffles I sold on any given day, or `nil` (Ruby’s equivalent to `null`)
if I wasn’t open that day.

    dates = (Date.new(2010, 1, 1) .. Date.new(2010, 12, 31))
    dates.map { |date| waffles_sold[date] } \
         .reject { |waffle_count| waffle_count == nil } \
         .sum

What I’m doing here is creating a date range from 1st January 2010 to
31st December 2010. I then map that range to a function that looks up
how many waffles I’ve sold on each of those given days, creating a list
(which Ruby calls an “array”) with an item for each day of the year. For
the days on which I’ve been open, I have a number, and for the others, I
have `nil`. This is because Ruby’s `Hash` returns `nil` when the key you
use to look up a value doesn’t exist. I then have to filter these `nil`s
out before summing.

It doesn’t take much to realise that just expressing that on days I’m
not open, I’ve sold exactly zero waffles, and expressing this in my code
would make things a lot simpler. Fortunately, Ruby’s good about this: it
lets me instantiate my `Hash` with a default value to use instead of
`nil` when looking up a non-existent key:

    waffles_sold = Hash.new(0)
    # insert some waffles

Now I can lose the rejection altogether, as I’ll get zeroes for the days
I’m not open, which won’t impact the sum at all. In this situation, `0`
is a *null object*: a real, live object with behaviour that doesn’t at
all impact the operations surrounding it.

    dates = (Date.new(2010, 1, 1) .. Date.new(2010, 12, 31))
    dates.map { |date| waffles_sold[date] }.sum

Simples, right? We can extend this idea to other situations. Where I’m
doing a series of multiplication, I might use `1` as my null object, as
`x * 1 == x`. If I have a list, rather than using `nil` to mean “nothing
to see here”, I could just use an empty list—it’s really the same thing,
but I don’t have to litter my code with branches to ensure my code
operates correctly.

Primitives are so… primitive
----------------------------

This is all fairly simple when dealing with numbers and other basic
types, but it can help you with more complex structures too. Say I have
a Java interface that represents a cache:

    public interface Cache {
        Object get(Object key);
        void set(Object key, Object value);
    }

(C\# programmers, squint a little and you should be able to read this
one just fine.)

I might have a few different implementations of this: one that stores
values in an in-memory map, one that talks to memcached, one that stores
stuff in the database… you get the idea. The cache is initialised when
the application is launched, so I can use the in-memory map when running
my tests, and memcached, with all its bells and whistles, on the
production server. Or I may not want to cache things at all, in which
case I just set my `cache` variable to `null`. Let’s take a look at how
this might be used.

    Books books;
    if (cache != null) {
        books = (Books) cache.get("books");
    }
    if (books == null) {
        books = readListOfBooks();
        downloadBookIsbnsFor(books);
    }
    if (cache != null) {
        cache.set("books", books);
    }

    for (Book book : books) {
        String isbn = book.getIsbn();
        if (isbn == null) {
            isbn = "[not found]";
        }
        System.out.println(isbn);
    }

The first nasty I’m seeing in the above code is the repeated checks
against the cache to ensure it’s not null. A null object would slot in
well here. In this example, a “null cache” would simply not store
anything when setting a value, and always return `null` when retrieving
one. Here’s how a null cache would look in Java:

    public final class NullCache implements Cache {
        @Override
        public Object get(Object key) {
            return null;
        }

        @Override
        public void set(Object key, Object value) { }
    }

It just does nothing. However, we can use it in place of not having a
cache at all. If we instantiate one of these rather than just setting
cache to `null`, our code becomes simpler as a result. We can call `get`
and `set` as much as we like and they’ll have the same impact as not
calling them at all.

    Cache cache = new NullCache();

    # ...

    Books books = (Books) cache.get("books");
    if (books == null) {
        books = readListOfBooks();
        downloadBookIsbnsFor(books);
    }
    cache.set("books", books);

Shiny. Our `NullCache` may be made of wood, but he walks and talks like
a real boy: he adheres to the same contract as any other cache, we don’t
have to special-case him. We can simply use him safe in the knowledge he
does nothing. `null`, especially in Java and other C-based languages,
breaks the type system, reacting differently to anything else you could
have put in the same situation. If I have a `Cache`, I should always be
able to call `set` on it—there shouldn’t be a single case where I need
to do something differently. We can see that using null objects rather
than `null` itself helps me write cleaner code without littering it with
defensive checks. Instead, I can concentrate on expressing the intent.

"But Samir, we still have a null check in there!" I hear you cry. Yup,
we do, and I’d like to lose it. We’ll tackle that one in the next post,
coming [soon](http://developer.valvesoftware.com/wiki/Valve_Time) to a
blog near you.

