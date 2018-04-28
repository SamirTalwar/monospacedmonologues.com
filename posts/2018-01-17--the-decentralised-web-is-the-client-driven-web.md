I'm getting pretty excited about the idea of a completely decentralised World Wide Web.

Last year I went to the [Mozilla Festival][]. I loved it. I could only make one of the two days, but it was enough for me. The highlight was the [Beaker Browser][], a browser that's able to request *and serve* web pages over a secure peer-to-peer networking protocol called [DAT][DAT Project].

Over the holidays, I decided to serve [my website][Noodle Sandwich] over DAT using the Beaker Browser, just to see how it goes. And I discovered something really interesting.

I'd forgotten that despite that website being pretty much static, it still had a server attached. The server mostly served HTML (rendered from [Pug][] templates), but there was one thing that was dynamic: the list of upcoming talks and workshops. It used today's date to figure out whether the event was "upcoming" or "previous", in order to render them in the correct section.

My first thought was, "Oh, this won't work then. It needs to know today's date before rendering."

My second thought was, "I could do this on the client side, with JavaScript."

My third thought was, "But then I'd have to serve a bunch of extra data in JSON, which is unnecessary."

And I left it at that.

---

I couldn't sleep that night. It was one of those nights where there's too many thoughts running around my brain, and it can't relax enough to drift off.

One of those thoughts was about my website. I thought it was a shame I couldn't serve it over DAT.

So I got up, opened my laptop, and I rewrote my site to serve the "database" ([a YAML file][database.yaml], [converted to JSON][database.json]), then to render the list of talks and workshops dynamically.

There's a trade-off here. My website used to just be a bunch of HTML and CSS, with JavaScript just for [Font Awesome][] and Google Analytics, both of which the site is fine without. Now it uses JavaScript to load primary content, which I'm less happy about.

But it's also more open. Everything happens on the client now. The site can be served from anywhere (even a CDN), which makes it much truer to how the web used to be, and how I'd like it to be again: a collection of resources, shared by everyone, and not a bunch of walled gardens without any interoperability.

[And now it's served over DAT too][Noodle Sandwich over DAT], and mirrored by [Hashbase][], which means I don't need to be online for you to view it. Try it out in [Beaker][Beaker Browser] sometime.

[Noodle Sandwich]: https://noodlesandwich.com/
[Noodle Sandwich over DAT]: dat://noodlesandwich.com/
[database.json]: https://noodlesandwich.com/database.json
[database.yaml]: https://github.com/SamirTalwar/noodlesandwich.com/blob/master/database.yaml

[Beaker Browser]: https://beakerbrowser.com/
[DAT Project]: https://datproject.org/
[Font Awesome]: http://fontawesome.io/
[Hashbase]: https://hashbase.io/
[Mozilla Festival]: https://mozillafestival.org/
[Pug]: https://pugjs.org/
