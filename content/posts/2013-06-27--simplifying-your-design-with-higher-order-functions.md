---
title: "Simplifying your Design with Higher-Order Functions"
slug: simplifying-your-design-with-higher-order-functions
date: 2013-06-27T15:17:00Z
aliases:
  - /post/54018347100/simplifying-your-design-with-higher-order
---

That was the name of the ~~talk~~ live-coding demonstration I gave at [I
T.A.K.E.](http://itakeunconf.com/), a conference in Bucharest, Romania.

[My last blog
post](/post/51465038762/live-coding-at-a-conference-and-why-it-is-scary)
was on why I was pretty scared of doing this. This one (which is late)
is going to be talking about what I covered in the talk. A written
version of it, if you will.

<!--more-->

We started with me. In case you were wondering, I'm Samir. In my
defence, my audience didn't necessarily know this. So I showed them this
tweet:

> /\* Temporary hack \*/. Oh really? \`git blame\` says you wrote that
> in October.
>
> — Samir Talwar (@SamirTalwar) [May 3,
> 2013](https://twitter.com/SamirTalwar/statuses/330318101176524802)

[Peter Flint](https://twitter.com/drumbux) tells me that sums me up
pretty well. Hopefully that's enough to tell people what I do: get angry
about code. And then hopefully fix things.

## The Four Elements of Simple Design

After that brief introduction, I started talking about the four elements
of simple design. I used [J. B. Rainsberger's
definitions](http://www.jbrains.ca/permalink/the-four-elements-of-simple-design),
which he took from Kent Beck. I quote:

> I define simple design this way. A design is simple to the extent that
> it:
>
> 1.  Passes its tests
> 2.  Minimizes duplication
> 3.  Maximizes clarity
> 4.  Has fewer elements

The rules are sort of in order of importance, except that sometimes \#3
trumps \#2. It's really a gut feeling. When they contradict each other,
it's up to the developer to figure out which is more important.

I didn't focus much on the first rule, because pretty much every other
talk at the conference was on testing. I figured it was covered pretty
well by people far better at writing tests than me. Instead I looked at
the other three. I love that these rules are clear by themselves—it's
obvious what they mean just by reading. My goal for the session was to
refactor some of the [Quacker](https://github.com/SamirTalwar/Quacker)
code base so it better conformed to those three rules.

Below are three examples. I won't explain why they conform better to the
four elements; that's for you to decide. Obviously, I think they do, but
rather than listen to me telling you _why_ a piece of code is better, I
think you'll get more out of the exercise by reasoning about it.

## Refactoring \#1: Loops

I started with this code:

    public void renderTo(TimelineRenderer renderer) {
        int count = 0;
        for (Message message : messages) {
            if (count == Feed.MaximumFeedLength) {
                break;
            }
            renderer.render(message);
            count++;
        }
    }

And turned it into this:

    public void renderTo(TimelineRenderer renderer) {
        LazySeq.of(messages)
               .limit(Feed.MaximumFeedLength)
               .forEach(renderMessageTo(renderer));
    }

    private static Consumer<Message> renderMessageTo(final TimelineRenderer renderer) {
        return new Consumer<Message>() {
            @Override void accept(Message message) {
                renderer.render(message);
            }
        };
    }

That's some really pretty code followed by some butt-ugly code.
Fortunately, we can just fold the method up in our IDE or editor and
pretend it doesn't exist, or even move it into the TimelineRenderer
class. It's static, after all. IntelliJ IDEA even makes it look like
this when you fold it up:

    private static Consumer<Message> renderMessageTo(final TimelineRenderer renderer) {
        return (Consumer<Message>) (message) -> { renderer.render(message); };
    }

And in Java 8, we can go one better, and use method references to do the
same thing without any boilerplate at all:

    public void renderTo(TimelineRenderer renderer) {
        LazySeq.of(messages)
               .limit(Feed.MaximumFeedLength)
               .forEach(renderer::render);
    }

## Refactoring \#2: Comparisons

The next section of the talk focused on this code:

    String command = commandLine.read();
    switch (command.charAt(0)) {
        case 'p':
             String message = command.substring(2);
             client.publish(message);
             break;
         case 't':
             String usernameToLookup = command.substring(2);
             client.openTimelineOf(usernameToLookup, new MessageListRenderer(messageRenderer));
             break;
         case 'q':
             return State.Done;
    }
    return state;

This is fairly readable, but won't be after I implement the rest of the
features. We only have a couple exposed via the command-line handler
here, and we're going to need lots more for a fully-fledged Quacker
client.

Here was my first stab. It's using lambdas for conciseness and
readability, but in the talk I actually used full-sized anonymous
implementations of the `CommandHandler` interface.

    Map<Character, CommandHandler> handlers = new HashMap<>();
    handlers.put('p', message -> {
        client.publish(message);
        return state;
    });
    handlers.put('t', usernameToLookup -> {
        client.openTimelineOf(usernameToLookup, new MessageListRenderer(messageRenderer));
        return state;
    });
    handlers.put('q', command -> State.Done);

    String command = commandLine.read();
    return handlers.get(command.charAt(0)).handle(command.substring(2));

Here's the interface as well:

    public static interface CommandHandler {
        State handle(String arguments);
    }

So far, so good, except when quitting, the command only had one
character, and so calling `command.substring(2)` threw an exception.
That was simply fixed: instead of taking a string, we took a supplier to
one. A lazy string, if you will.

    public static interface CommandHandler {
        State handle(Supplier<String> arguments);
    }

And called it like this:

    return handlers.get(command.charAt(0)).handle(() -> command.substring(2));

Then the code that wanted it could just call the `get` method on the
supplier, and the code that didn't (namely the quit handler) never ended
up calling `substring`.

Now, we could leave those as lambdas, but I actually preferred to make
them full classes in their own right:

    handlers.put('p', new PublishHandler());

    private class PublishHandler implements CommandHandler {
        @Override public State handle(String message) {
            client.publish(message);
            return state;
        }
    }

That way we can separate the `handlers` lookup table from the actual
behaviour of the handler, putting it somewhere else entirely if we like.

What I love about this example of higher-order functions is that it's
not just functional; it's object-oriented. It's proof that you don't
have to pick a side: quite often, you can write code that encompasses
the best principles of both. What's more object-oriented than
polymorphism?

## Refactoring \#3: Mutability

The last example concerned some horrible code to merge two Quacker
timelines into a single feed. I'm not going to show the code here,
because there's too much. [Head over to
GitHub](https://github.com/SamirTalwar/Quacker/blob/840c527edd8867e3d0bdb5b6d9a300903cc53d76/src/main/java/com/noodlesandwich/quacker/communication/feed/AggregatedProfileFeed.java)
and take a look.

It's OK. I'll wait.

Right. Now you've had a bit of time for your eyes to stop watering, I'll
explain how I fixed it. I applied just one principle: mutability is bad.
So I replaced the iterators and the mutable maps with immutable linked
lists (using the [LazySeq](https://github.com/nurkiewicz/LazySeq)
library), and instead of appending to a mutable list, I constructed new
lists through transformations.

About half-way through, I realised what I had on my hands was the
"merge" step of [merge sort](http://en.wikipedia.org/wiki/Merge_sort).
So I pushed in that direction, making things immutable as I went.

[The end result was
beautiful.](https://github.com/SamirTalwar/Quacker/blob/ea5671480963cfebf4ec2122e726eb5300101975/src/main/java/com/noodlesandwich/quacker/communication/feed/AggregatedProfileFeed.java)

Because the immutable code was clearer by default (as in, you can trace
through the code and understand what everything is at any given point),
I was able to write concise code that is still perfectly understandable.

OK, I used `reduce`. But apart from that, isn't it pretty?
