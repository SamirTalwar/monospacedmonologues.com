---
title: "Comprehending Lists"
date: 2011-10-26T23:50:00Z
---

Today I ran a workshop on functional programming in object-oriented
languages at a [London Software Craftsmanship
Community](http://www.meetup.com/london-software-craftsmanship) meetup.
I'll post up the problem I asked people to solve in the next couple of
days, but as I'm currently physically incapable of sleeping, I thought
I'd take some time and talk to you about lists.

Lists are one of the most powerful and versatile constructs we have in
our day-to-day toolkits. We use them *everywhere*. I can probably count
the number of times I've implemented anything even slightly complex
without using a list on the fingers of one hand. Today, I want to
explain why we use them wrongly.

First, let's identify the most common operations we perform on lists. We
loop over them, inspecting and using each element of the list. We add
items to them, and remove others. We don't often retrieve arbitrary
items from them (how many times have you asked specifically for element
12 of a list?), but we do often need just the first or last element.

Most mainstream programming languages—Java, Ruby, Python and C\# among
them—use an array to implement the default list type. In memory, arrays
are continuous chunks of memory, allocated all at once. The array object
itself is represented by the memory address of the 0th element, its
length, and the size of each individual element (which must be the same
across the entire array). Arrays, and therefore lists, are optimised for
random access. Element 34 lives at location `start + 34 * element_size`.
Easy.

While retrieving elements is a simple process, adding a new one is
relatively complicated. If I have a hundred items in my array and I want
to add another, I need to create a new array of 101 elements, copy
everything over, and add the last one. As you can imagine, this is
pretty time-consuming. The normal way for "ArrayLists" (that's what Java
calls 'em) to scale is to multiply the size by a constant factor
(normally 1.5 or 2) using the above method every time the user exceeds
its capacity, and store the actual number of elements in addition to the
length of the internal array. That means they don't have to duplicate
the array every time the user adds another item—just every so often, and
it happens less frequently as you add more elements.

Enter the linked list. If you, like me, studied programming at school or
university, you may remember the linked list as an interesting concept,
but with no real practical use. I want to change that.

The wonderful thing about linked lists is that if you treat them right,
they're entirely immutable. And treating them right is quite simple:
only add values to the beginning of the list.

Say I have the numbers from 1 to 10:

    numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

I then want to prefix the number 0, because all good programmers count
from 0.

    numbers_from_zero = 0 : numbers

That colon (`:`) is the *cons* operator. Odd name, I know, but it's a
simple enough concept. It takes an object on the left and a list on the
right, and returns a new list which is the old one prefixed with the
object on the left. The lovely thing about this is that I can keep the
pointer to the old list and it hasn't changed at all. It still points to
the right place. In this case, `numbers` still points to the first
element of my linked list, `1`, and goes on from there.
`numbers_from_zero` points to the `0`, which points to the `1`. I can
use these lists independently even though they share most of their
nodes.

Say I want to decompose the list. Let's give it two methods: `head` and
`tail`. `head` returns the first item of the list, and `tail` returns
the rest. This is the exact opposite of the cons operation, which took a
head and a tail and stuck them together. Now we're breaking them back
apart.

So let's do something simple. How about multiplying everything in our
list by two? Let's define a function that does exactly that.

    multiply_by_two (list) = (list.head * 2) : multiply_by_two(list.tail)

Well, there's one problem here. That will recurse forever. Let's fix
that.

    multiply_by_two (list) = if list.isEmpty
                                 then []
                                 else (list.head * 2) : multiply_by_two(list.tail)

We've introduced a new operation here. As well as pulling the head and
tail out of the list, we need to be able to test it to see whether it's
empty or not. The `isEmpty` function here does exactly that. We then
return *nil*, the empty list, if it is. This means that when we finally
get to the end of the list, we stop.

Let's expand this one.

    multiply_by_two([1, 2, 3, 4, 5])
        = (1 * 2) : multiply_by_two([2, 3, 4, 5])
        = 2 : (2 * 2) : multiply_by_two([3, 4, 5])
        = 2 : 4 : (3 * 2) : multiply_by_two([4, 5])
        = 2 : 4 : 6 : (4 * 2) : multiply_by_two([5])
        = 2 : 4 : 6 : 8 : (5 * 2) : multiply_by_two([])
        = 2 : 4 : 6 : 8 : 10 : []
        = [2, 4, 6, 8, 10]

Done. We have an entirely new list which contains the same numbers as
the first, multiplied by two. And we did this without ever mutating the
original list. We just popped stuff off and pushed new things on. The
important thing to remember is that the `:` operator creates new lists,
it doesn't change the existing one.

We can generalise this a little. We often want to transform every item
in the list. So let's define a way of mapping a function—any function—to
each item in the list. That way we can apply any function we like across
an entire list without having to rewrite it for lists. This is the
cornerstone of good functional programming: reusable, composable
functions.

Let's call it `map`, and make it a method on the List class. It takes a
function, called `f`.

    List.map (f) = if this.isEmpty
                       then []
                       else f(this.head) : this.map(f, this.tail)

I can then reimplement my `multiply_by_two` function pretty easily.

    multiply_by_two (list) = list.map((x) => x * 2)

Bam. Functional programming. Ain't it tidy?

Here's an exercise for you. How would you implement a method on List
that removes all elements that don't match a predicate? Call it
`filter`. Here's your test case:

    isEven (x) = x % 2 == 0
    [1, 2, 3, 4, 5, 6].filter(isEven) == [2, 4, 6]

I've written all these examples in a fictional language, so if you want
to code it, you'll have to reimplement them. That said, you don't have
to try and code it. Just think about it. When you've got it, post it in
the comments.
