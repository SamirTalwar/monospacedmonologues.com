---
title: "Feed Me With Bookmarklets"
slug: feed-me-with-bookmarklets
date: 2016-01-18T08:00:18Z
aliases:
  - /post/137539729401/feed-me-with-bookmarklets
---

If you've been reading this blog since the start of the year, you may have noticed that posts go up at 08:00 UTC (…ish) every weekday. This is intentional, and I hope to keep it going all year.

I use Tumblr as my blogging engine, which lets me schedule posts. I then use [IFTTT][] to push a link to Twitter, which it does within minutes. If you follow me, you'll see them. However, I know a lot of people, especially techies, prefer to use a feed reader. Personally, I use [Feedly][], mostly because when Google Reader shut down, Feedly allowed me to import my feeds very easily.

<!--more-->

I subscribe to developer blogs all the time, but Feedly isn't really geared for trivially adding feeds. I have to find the RSS or Atom feed URL, paste it into the search box, then click the *+feedly* button to subscribe. The first bit, finding the feed URL on the page, is usually quite difficult, as there isn't a standard place to put it. Fortunately, the DOM is another story.

Take a look at the DOM structure of this website. Specifically, the `<head>`. Open up your developer tools (usually with *Ctrl+Shift+I* or *Cmd+Shift+I*), and then the *Inspector* tab:

{{% asset "monospacedmonologues.com DOM head structure" "2016-01-18+-+monospacedmonologues.com+DOM+head+structure.png" %}}

Right before the variables start, there's a line that looks like this:

    <link href="http://monospacedmonologues.com/rss" type="application/rss+xml" rel="alternate"></link>

Most websites with RSS feeds have one of these. Similarly, sites with Atom feeds, such as [Seth Godin's blog][Seth's Blog], usually have something like this:

    <link href="http://sethgodin.typepad.com/seths_blog/atom.xml" title="Posts on Seth's Blog (Atom)" type="application/atom+xml" rel="alternate"></liink>

Either way, we can find them pretty quickly with a little bit of JavaScript and a query selector (which is the same as a CSS selector, but in JavaScript):

    var element = document.querySelector(
        'link[rel="alternate"][type="application/atom+xml"], '
      + 'link[rel="alternate"][type="application/rss+xml"]');

Once we have that, we can get the feed's URL by accessing the `href` property:

    var feedUrl = element.href;

Feedly has a standard URL structure for the page where you can view a feed and potentially subscribe to it. It looks like this: *https://feedly.com/i/subscription/feed/&lt;feed URL&gt;*. We can construct it with simple string concatenation:

    var feedlySubscriptionUrl = 'https://feedly.com/i/subscription/feed/' + feedUrl;

Finally, we need to head over to that page so that we can subscribe:

    window.open(feedlySubscriptionUrl, '_top');

In that snippet, `'_top'` refers to the outermost frame, so that if we're dealing with `<frame>` or `<iframe>` elements in the browser, we won't open in one of them.

There's a couple more considerations. We might already be viewing the feed itself, rather than the website containing it. In Firefox, we can detect this by looking at the ID of the `<html>` tag—if it's "feedHandler", we know we're viewing the feed directly and it's being rendered by Firefox. Similarly, with Chrome, the first element of the `<body>` will have the ID "webkit-xml-viewer-source-xml". We can detect this and capture the current page location as the feed, rather than looking for the appropriate `<link>` element, by accessing `document.location.href`:

    var element, feedUrl;
    if (document.documentElement.id === 'feedHandler'
            || document.body.childNodes[0].id == 'webkit-xml-viewer-source-xml') {
        feedUrl = document.location.href;
    } else {
        element = document.querySelector(
            'link[rel="alternate"][type="application/atom+xml"], '
          + 'link[rel="alternate"][type="application/rss+xml"]');
        feedUrl = element.href;
    }

And, of course, we should probably check that the `element` is not `null` or `undefined` before accessing the `href` property, and also check that the `feedUrl` is similarly a non-empty value before attempting to open a new page.

Putting it all together, we end up with this:

    var element, feedUrl, feedlySubscriptionUrl;

    if (document.documentElement.id === 'feedHandler'
            || document.body.childNodes[0].id == 'webkit-xml-viewer-source-xml') {
        feedUrl = document.location.href;
    } else {
        element = document.querySelector(
            'link[rel="alternate"][type="application/atom+xml"], '
          + 'link[rel="alternate"][type="application/rss+xml"]');
        if (element) {
            feedUrl = element.href;
        }
    }

    if (!feedUrl) {
        alert('No feed found.');
        return;
    }

    feedlySubscriptionUrl = 'https://feedly.com/i/subscription/feed/' + feedUrl;
    window.open(feedlySubscriptionUrl, '_top');

Now all we have to do is wrap it in a function and prefix it with `javascript:`. This bit of magic turns it into a valid URI, which means we can create a bookmarklet by setting the entire source as the bookmark location.

    javascript:(function() {
        ...
    })();

To use it:

  1. Create a new bookmark in your Bookmarks Bar.
  2. Name it "Subscribe".
  3. Add your code, surrounded by the auto-running function and the `javascript:` prefix, into the "Location" or "URL" field. You can copy it from [feedly-subscribe.js][] (a gist on my GitHub) if you're feeling lazy.
  4. Save the bookmark.
  5. Click the button whenever you're on an interesting blog.

You can, of course, use the same technique to automate many web interactions, as long as it's a real website and not [a single-page application that breaks the web][Why I hate your Single Page App]. If it's something you do often and requires traipsing the DOM, JavaScript and bookmarklets have your back.

[Feedly]: https://feedly.com/
[IFTTT]: https://ifttt.com/
[Seth's Blog]: http://sethgodin.typepad.com/
[feedly-subscribe.js]: https://gist.github.com/SamirTalwar/6730180
[Why I hate your Single Page App]: https://medium.com/@stilkov/why-i-hate-your-single-page-app-f08bb4ff9134
