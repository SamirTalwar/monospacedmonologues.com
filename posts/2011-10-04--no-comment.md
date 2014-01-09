**Unless you have a damn good reason, don’t write comments.**

And if you see a comment, you should probably delete it.

I didn’t come up with this—it’s the policy in the office, as well as
various tech shops all over the planet. I thought I’d start with a fun
one though. Half the people that read that will think I’m an idiot. The
other half will shrug and say, “We taught *you* this, boy.” (The latter
don’t need to keep reading.)

Why this insane proposal? It’s my opinion that there’s always[^1] a
better way. Let’s take a fairly simple example:

    // cannot have an odd number of sprockets
    if (n % 2 == 1) {
        throw new InvalidNumberOfSprocketsException(n);
    }

The comment in the snippet above explains the next few lines to the
reader. This is a good thing—you can’t expect everybody to know your
ridiculous business rules straight off the bat. However, I’d argue it
could be better:

    public static boolean isEven(int n) {
        return n % 2 == 0;
    }

    public static boolean validNumberOfSprockets(int n) {
        return isEven(n);
    }

    ...

    if (!validNumberOfSprockets(n)) {
        throw new InvalidNumberOfSprocketsException(n);
    }

Here, the code explains itself. No comments are needed, and as a bonus,
the logic is reusable. If I put that function somewhere sensible, I can
use it anywhere, and when our new sales guy, Mr. Fibonacci, tells me
we’re we’re now packaging our sprockets in far more aesthetically
pleasing boxes, I can adjust it once and clock off early.[^2]

You do that already? Excellent. OK, let’s take a look at a different
example. Say you write some JavaScript with jQuery to highlight all the
changed fields in your form, as well as creating a map to store the form
data:

    function formSubmission() {
        var toSubmit = {};
        $('#sprocket-order-form input[type=text]').filter(function() {
            if ($(this).attr('data-original-value') !== $(this).val()) {
                toSubmit[$(this).attr('name')] = $(this).val();
                return true;
            }
            return false;
        }).addClass('changed');
        return toSubmit;
    }

You leave it for a few months, until a user reports a bug in your
application. Ever the good developer, you immediately dive back in and
see the above code glaring at you. After making yourself another coffee
and staring at it for a while, you figure out what it all means and
decide to add some comments to prevent you from having to go through the
rigamarole again.

    function formSubmission() {
        var submission = {};
        // Grab all text input fields and filter out those that haven't changed
        $('#sprocket-order-form input[type=text]').filter(function() {
            // If the data's changed
            if ($(this).attr('data-original-value') !== $(this).val()) {
                // Add it to the collection of things to submit
                submission[$(this).attr('name')] = $(this).val();
                return true;
            }
            // Filter out if the data's not changed since the last submit
            return false;
        }).addClass('changed'); // Highlight the fields
        return submission;
    }

This may look better to someone who already knows how the code works,
but it’s even harder to decipher at a glance. More lines of code are a
heavier burden on my eyes. In addition, while they’re correct now, if
someone comes in and changes the logic but doesn’t touch the comments
(which happens all the time), they’re worse than useless: they’re
actively misleading everyone who reads them.

Fixing this particular case isn’t too tricky. The esteemed Edsger
Dijkstra would tell you to separate the concerns: split the logic into
distinct pieces of behaviour. Currently, this chunk of code does two
things: extract the data from the form fields, and highlight the fields.
Let’s break that up.

    function formSubmission() {
        // Filter out those that haven't changed
        var changedFields = $('#sprocket-order-form input[type=text]').filter(function() {
            return $(this).attr('data-original-value') !== $(this).val();
        });

        // Highlight the fields
        changedFields.addClass('changed');

        // Grab all text input fields
        var submission = {};
        changedFields.each(function() {
            submission[$(this).attr('name')] = $(this).val();
        });
        return submission;
    }

Much cleaner. Of course, the comments are still there, but more
importantly, that code looks pretty reusable to me. If we whack each
chunk into a function, we can use them all over the place. Wouldn’t that
be nice?

    $.fn.changedFieldsOnly = function() {
        return $(this).filter(function() {
            return $(this).attr('data-original-value') !== $(this).val();
        });
    };

    $.fn.highlight = function() {
        return $(this).addClass('changed');
    };

    $.fn.toObject = function() {
        var obj = {};
        $(this).each(function() {
            obj[$(this).attr('name')] = $(this).val();
        });
        return obj;
    };

    ...

    function formSubmission() {
        var changedFields = $('#sprocket-order-form input[type=text]').changedFieldsOnly();
        changedFields.highlight();
        return changedFields.toObject();
    }

Look at that. No comments, because we don’t need any. The function names
are more than adequate. “No comments” might sound silly at first, but
it’s simply a natural extension of developing readable and maintainable
code. I think it looks pretty good.

* * * * *

I should probably point out that while the title is “No Comment”,
comments are indeed open. Hit me.

[^1]: Not always. But most of the time. All rules can be broken.
[^2]: I wish.
