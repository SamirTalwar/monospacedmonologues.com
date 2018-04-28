---
title: "Fairy Godmother"
date: 2011-11-13T17:49:00Z
---

In our [last
installment](http://monospacedmonologues.com/post/12627672433/pinocchio),
we looked at a piece of code and removed some of the nulls. At the end
of it, it looked like this:

    Books books = (Books) cache.get("books");
    if (books == null) {
        books = readListOfBooks();
        downloadBookIsbnsFor(books);
    }
    cache.set("books", books);

    for (Book book : books) {
        String isbn = book.getIsbn();
        if (isbn == null) {
            isbn = "[not found]";
        }
        System.out.println(isbn);
    }

There are still two null checks in there. In this episode, I'm going to
explain how to get rid of the first one: `if (books == null)`.

The problem is that `null` can mean many things. When we used it last
time, it signified there was no cache: it meant, essentially, "this is
not a thing". In this instance, however, it tells us that we couldn't
find an object—it's a default which works for any situation. This is
really because `null` breaks the type system: how can an object
represent any type?

One way to get around this is by providing the default ourselves.
Instead of our `get` method of our cache object returning an object or
null, we can have it return an object or, if it can't find it, the
default we provide:

    interface Cache {
        Object get(Object key, Object defaultValue);
        void set(Object key, Object value);
    }

Then, when using it, we just give it our list of default books.

    Books defaultBooks = readListOfBooks();
    downloadBookIsbnsFor(defaultBooks);

    Books books = (Books) cache.get("books", defaultBooks);
    cache.set("books", books);

Excellent. No null check, and the code makes just as much sense. There's
just one problem: we read in default list of books even if we don't need
it.

A little while ago, I wouldn't shut up about passing functions around.
This is another situation where this could come in handy. What if,
instead of providing a default value to return, we provide a function
that generates a default value?

    Books books = (Books) cache.get("books", function () {
        Books defaultBooks = readListOfBooks();
        downloadBookIsbnsFor(defaultBooks);
        return defaultBooks;
    });
    cache.set("books", books);

OK, sorted. Either grab me my books, or run this function which will get
them for you. Wonderful. The only problem is that this isn't real Java.
We really need an interface that represents our function. In Guava, it's
called
[Supplier](http://docs.guava-libraries.googlecode.com/git-history/v10.0.1/javadoc/com/google/common/base/Supplier.html),
so let's go with that.

    interface Cache {
        Object get(Object key, Supplier<Object> defaultValue);
        void set(Object key, Object value);
    }

Sweet. What does our code look like now?

    Books books = (Books) cache.get("books", new Supplier<Object>() {
        @Override public Object get() {
            Books defaultBooks = readListOfBooks();
            downloadBookIsbnsFor(defaultBooks);
            return defaultBooks;
        }
    });
    cache.set("books", books);

Magical. We could even get rid of the casting if we were a little
cleverer with the interface types. If we then pulled out that supplier
into a constant value somewhere, it'd be clean and easy to read too.

    Books books = (Books) cache.get("books", readBooks);
    cache.set("books", books);

Three nulls down, one to go. I'm looking forward to the last one.
