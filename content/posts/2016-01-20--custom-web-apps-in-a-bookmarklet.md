---
title: "Custom Web Apps… In A Bookmarklet"
slug: custom-web-apps-in-a-bookmarklet
date: 2016-01-20T08:00:23Z
aliases:
  - /post/137674672680/custom-web-apps-in-a-bookmarklet
---

A couple days ago, I demonstrated how to use a bookmarklet to automate the time-consuming process of discovering a link to an RSS or Atom feed and subscribe to it. Today I want to do something a bit weirder.

I once wrote a JIRA plugin to reformat the Agile board (how I hate that it's called "Agile"… it's nothing of the sort) to something more useful for a project manager. It reformatted it so that every box was very small and colour-coded by discipline (front-end, back-end, infrastructure, design, etc.), making it easy to see where the bottlenecks were in a sprint. I didn't use JIRA's plugin architecture though—it's a nightmare. Instead I just wrote some JavaScript to do the work. With a website with sane markup, which fortunately JIRA has, it's often far more trivial and maintainable to write something to manipulate the client than it is to write server-side code.

<!--more-->

Now, I hate JIRA with a passion, so we're not going to use that as an example. Instead, let's mess around with [Trello][], a tool that lets you organise things using lists of lists. In my opinion, it's still not great for project planning, in my mind, but is at least fairly simple and used by many organisations for exactly that purpose.

The simplest form of modification is removing content, so I'm going to focus on that. Adding or changing content follows similar principles. Here's an example Trello board—in fact, the Welcome Board that shows up when you sign up.

{{% asset "Welcome Board" "2016-01-20+-+Welcome+Board.png" %}}

When using Trello as a kind of [kanban board][], we often want to focus on just a few columns. For example, we might not be interested in the first or last column, as they describe things that have been done ages ago or won't be started for a while.

Because most websites of any size use jQuery or a compatible library for their own JavaScript, it's almost always available by default. This means we can use [jQuery][] to select the list elements. They're elements with the class `list` inside an element with an ID of `board`, which makes it pretty easy. Type the following into the developer console, which you can usually access by hitting _Ctrl+Shift+I_ or _Cmd+Shift+I_ and clicking the _Console_ tab:

    $('#board .list')

It should result in an object with properties similar to this one. If you hover over the element objects, you should see them highlighted in the browser. In my case, because my board has three lists, this selector has returned three elements.

    Object {
        0: <div.list.js-list-content>,
        1: <div.list.js-list-content>,
        2: <div.list.js-list-content>,
        length: 3,
        prevObject: Object,
        context: HTMLDocument → welcome-board,
        selector: "#board .list"
    }

We only want to remove certain columns, so we can filter that selection to check the text. First of all, as we're working in the REPL, we can explore the API a bit and see if we can grab the text by mapping over the elements. (If you're not familiar with `map`, [Wikipedia has a good explanation][map (higher-order function)].)

    $('#board .list').map((i, element) => $(element).find('[attr=name] h2').text())

jQuery's `map` function is a bit different to a standard array map function, as it passes both the index and the object to the function provided. This is generally pretty annoying, but we can just ignore the first argument. We then use it to grab the header, which is inside some element with an attribute `attr="name"`, and then the text of that element. In my browser, the output looks like this:

    Object {
        0: "Basics",
        1: "Intermediate",
        2: "Advanced",
        length: 3,
        prevObject: Object,
        context: HTMLDocument → welcome-board
    }

OK, great. We've used `map` to explore (this is why I love REPLs), but it's not actually where we want to go. Instead `filter` that down so we just get the _Basics_ column in my example. (Again, [Wikipedia covers `filter`][filter (higher-order function)].)

    var listsToHide = $('#board .list')
            .filter((i, element) => $(element).find('[attr=name] h2').text() == 'Basics');
        // => Object {
        //        0: <div.list.js-list-content>,
        //        length: 1,
        //        prevObject: Object,
        //        context: HTMLDocument → welcome-board
        //    }

Brilliant. That's the one we want. (If we wanted more, we could check that the `text()` is one of an array of the column names.) Now we just need to make it go away.

    listsToHide.hide();

{{% asset "Welcome Board with missing column" "2016-01-20+-+Welcome+Board+with+missing+column.png" %}}

Brilliant. It's gone… but the space is still there.

Turns out there was a wrapper element. Now, we could go and change the code to refer to `.list-wrapper` instead, but I'm lazy. So let's jump up one element in the DOM tree and remove that instead.

    listsToHide.parent().hide();

{{% asset "Welcome Board with hidden column" "2016-01-20+-+Welcome+Board+with+hidden+column.png" %}}

Fantastic. If we want to show it again, we can just call `show()`. Now all we need to do is stick it in a bookmark to make a useful button that formats the page just how we need it, when we need it.

    javascript:(function() {
        var listsToHide = $('#board .list')
                .filter((i, element) => $(element).find('[attr=name] h2').text() == 'Basics');
        listsToHide.parent().hide();
    })();

Make your own, shove it in a bookmark and make your tools work the way _you_ need them to.

JavaScript. Because you're worth it.

[trello]: https://trello.com/
[kanban board]: http://leankit.com/learn/kanban/kanban-board/
[jquery]: https://jquery.com/
[map (higher-order function)]: https://en.wikipedia.org/wiki/Map_%28higher-order_function%29
[filter (higher-order function)]: https://en.wikipedia.org/wiki/Filter_%28higher-order_function%29
