---
title: "Naming Things"
slug: naming-things
date: 2016-02-02T08:00:27Z
aliases:
  - /post/138532840924/naming-things
---

A couple of weeks ago, [I promised to talk about naming][Slash Slash Massive Hack].

> If you can name a function really well, it probably does one thing and one thing only. This means you've figured out a decent way to separate your concerns, which means that often, the name is really all you need to know. (Expect more on naming in a future post.)

<!--more-->

I just opened up Stack Overflow and clicked on [the latest question][Stack Overflow Question #35119755][^1] to find this code:

    function createList() {
        $.ajax({
            type: "POST",
            url: "fetch_registered_list.php?event_id=1",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function(data) {
                $('#table_data tr').not(':first').remove();
                if (data != '' || data != undefined || data != null) {
                    var html = '';
                    $.each(data, function(i, item) {
                        html += "<tr><td>" + data[i].sno + "</td>" + "<td>" + data[i].name + "</td>" + "<td>" + data[i].email + "</td>" + "<td>" + data[i].phone + "</td>" + "<td><input class='check' name='" + i +
                            "' type='checkbox'/></td>" + "<td><input class='score' name='" + data[i].email + "' type='number'/></td></tr>"
                    })
                    $('#table_data tr').first().after(html);
                }

            }
        });
    }

Look at the contents, and then look at the name of the function: `createList`. Does that resonate with you?

Let me enumerate the things *I* think this function's doing. Of course, I could be wrong. One of the issues with legacy code is that we often are.

  * Make an AJAX call to fetch a list of registered *somethings*… I guess users, because it gets sent back as a JSON array with fields like "name", "email" and "phone".
  * Remove all rows from our table except the first one.
  * Iterate through the array returned as JSON, construct a table row as an HTML string and append it to a string containing all the HTML generated.
  * Add this HTML to the DOM after the first (and now only) row of the table.

Right. Let's think of a better name for this.

Go on. Take your time. There's no rush.

When you're ready, scroll down and I'll give you mine.

...

Ready?

Really?

You sure? No peeking.

Alright, here we go.

Mine is `fetchRegisteredUsersAndRenderToTableAfterClearingOldData`.

Mouthful, isn't it? You may have had something similar. I think this is a good name, because it explains what the function does. While `retrieveRegisteredUsers` might be a more pleasant name, I don't like it, because that kind of information hiding doesn't make my code cleaner, it just makes it more obtuse. With a name like `retrieveRegisteredUsers`, I might not realise that it's asynchronous behaviour, and so I might invoke it and then something that depends on the result immediately afterwards. I definitely won't realise that it's updating a table.

"Updating a table". I like that. It's more succinct. OK, how about `fetchRegisteredUsersAndUpdateTable`? That's a bit better. It captures that the code does two things, which is one thing too many. That's good. Now we have a goal. Figure out how to split this so that the two things are done separately. I think the easiest way would be to pull the success function out:

    function fetchRegisteredUsersAndUpdateTable() {
        $.ajax({
            type: "POST",
            url: "fetch_registered_list.php?event_id=1",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: updateRegisteredUsersTable
        });
    }

    function updateRegisteredUsersTable(data) {
        $('#table_data tr').not(':first').remove();
        if (data != '' || data != undefined || data != null) {
            var html = '';
            $.each(data, function(i, item) {
                html += "<tr><td>" + data[i].sno + "</td>" + "<td>" + data[i].name + "</td>" + "<td>" + data[i].email + "</td>" + "<td>" + data[i].phone + "</td>" + "<td><input class='check' name='" + i +
                    "' type='checkbox'/></td>" + "<td><input class='score' name='" + data[i].email + "' type='number'/></td></tr>"
            })
            $('#table_data tr').first().after(html);
        }
    }

Disregarding the innards of each function for now, that's a little better. Now, what if we inject that callback?

    function fetchRegisteredUsers(onSuccess) {
        $.ajax({
            type: "POST",
            url: "fetch_registered_list.php?event_id=1",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: onSuccess
        });
    }

We're able to invoke it like this:

    fetchRegisteredUsers(updateRegisteredUsersTable);

Great. Two functions, one purpose each, totally decoupled. I'm much happier. And with a little syntactic sugar in the form of JavaScript promises, we can make it read really nicely.

    function fetchRegisteredUsers() {
        return Promise.resolve($.ajax({
            type: "POST",
            url: "fetch_registered_list.php?event_id=1",
            contentType: "application/json; charset=utf-8",
            dataType: "json"
        }));
    }

    ...

    fetchRegisteredUsers().then(updateRegisteredUsersTable);

Marvellous.

[^1]: I'm really sorry to the author of this code. I don't mean to pick on them—it really was at random, and I honestly wouldn't have an issue with this code as-is most of the time. Code on Stack Overflow is licenced under [Creative Commons Attribution-ShareAlike 3.0 Unported][].

[Slash Slash Massive Hack]: http://monospacedmonologues.com/post/137738860257/slash-slash-massive-hack
[Stack Overflow Question #35119755]: https://stackoverflow.com/questions/35119755/checkboxes-and-number-fields-set-by-jquery-appear-for-a-split-second-then-sudde
[Creative Commons Attribution-ShareAlike 3.0 Unported]: https://creativecommons.org/licenses/by-sa/3.0/
