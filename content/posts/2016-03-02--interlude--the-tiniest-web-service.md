---
title: "Interlude: The Tiniest Web Service"
slug: interlude--the-tiniest-web-service
date: 2016-03-02T08:00:12Z
aliases:
  - /post/140321759565/interlude-the-tiniest-web-service
---

I don't have Internet now and I'm tethered to my phone, so I can't play with databases and Docker like I wanted to today. So instead, let's talk about a little project I made to demonstrate that you don't always need your favourite programming language to deliver something useful.

`nc`, or *netcat*, is a program that will connect to a **net**work socket and *cat* (just like `cat`) the result. It's on basically any Linux or BSD (including Mac) operating system. Let's try it.

    $ nc google.com 80

<!--more-->

You get… nothing. The prompt sits there waiting for you. You see, you've connected over port 80, which is HTTP. In order to get a response, you must first make a HTTP request.

Let's request the root path, `/`. Type this:

    GET / HTTP/1.1

Then hit *Return* twice. That signals the end of the request. You should get back something like this:

    HTTP/1.1 302 Found
    Cache-Control: private
    Content-Type: text/html; charset=UTF-8
    Location: http://www.google.co.uk/?gfe_rd=cr&ei=RRbWVqaPC4rCaJeckLAF
    Content-Length: 259
    Date: Tue, 01 Mar 2016 22:23:01 GMT

    <HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
    <TITLE>302 Moved</TITLE></HEAD><BODY>
    <H1>302 Moved</H1>
    The document has moved
    <A HREF="http://www.google.co.uk/?gfe_rd=cr&amp;ei=RRbWVqaPC4rCaJeckLAF">here</A>.
    </BODY></HTML>

By the by, if you don't have `nc` on your computer, don't worry. It's available on Busybox. Just type this instead:

    $ docker run --rm -it busybox nc google.com 80

Right. Back to the response. The first line's status code, `302`, is in the *3xx* range, which tells us that's a redirect. You can follow it if you like—just enter the "resource" (as it's known in [the specification][RFC 2616]) given in the `Location` header. The resource is everything after the host (and port, if it's there)—in my case it's `/?gfe_rd=cr&ei=RRbWVqaPC4rCaJeckLAF`. If you like, you can issue a request to that by typing the following:

    GET /?gfe_rd=cr&ei=RRbWVqaPC4rCaJeckLAF HTTP/1.1

(If the connection is still open, type it there. If not, start a new one. Either way, don't forget to hit *Return* twice.)

That gave me another redirect… Google bounces you around for a while.

However, just like `cat`, `nc` doesn't just go in one direction. It can also *listen* on sockets. To prove it, let's start a *server* by using `nc` to listen on port 3000:

    $ nc -l -p 3000

(If you're on BSD or Mac OS, you may need to drop the `-p` and just type `nc -l 3000`.)

Now open up another terminal and connect to it with a *client*:

    $ nc localhost 3000

You should have two terminals waiting for input. The client is waiting for the server, and the server is waiting for you. So give it it something. Type anything you like in that terminal, and hit *Ctrl+D* when you're done to send the end-of-file character. (You may need to start a new line by typing *Return* first.)

See what happened? Your input got sent straight to the client.

{{% asset "Sassy `nc`" "2016-03-02+-+sassy+nc.png" %}}

We can short-circuit the typing by simply piping something in. In one shell, type this:

    $ echo 'Hi there.' | nc -l -p 3000

And in another:

    $ nc localhost 3000
    Hi there!

This time it's instant. We can use this to make a rudimentary web server. All you really need is the HTTP response header, which should look like this for an *OK* response:

    HTTP/1.1 200 OK

So let's make it happen:

    $ echo -e 'HTTP/1.1 200 OK\r\n\r\nHi there, mate.' | nc -l -p 3000

This is a web server, so we can use `curl` to talk to it:

    $ curl localhost:3000
    Hi there, mate.

{{% asset "`curl` to `nc`" "2016-03-02+-+nc+to+curl.png" %}}

Magic. The only problem is that the "web server" exists after a single request. We can solve this by restarting it again in a loop:

    #!/bin/sh

    while true; do
        echo -e 'HTTP/1.1 200 OK\r\n\r\nHi there, mate.' | nc -l -p 3000
    done

Stick that in a file and we're done. All we need to do is make it into a Docker image so we can ship it anywhere and make it indistinguishable from another web service that uses the latest enterprise framework. (Well, apart from the image size.)

So here's the Dockerfile for the simplest web service:

    FROM busybox

    EXPOSE 3000
    COPY web-server web-server

    RUN chmod +x web-server
    ENTRYPOINT ./web-server

Easy, right? Just build it and spin it up. And, in case you lose this, remember [I made one for you and stuck it on GitHub][the-tiniest-service]. You can even run it.

{{% asset "the-tiniest-service" "2016-03-02+-+the-tiniest-service.png" %}}

[RFC 2616]: https://www.w3.org/Protocols/rfc2616/rfc2616.txt
[the-tiniest-service]: https://github.com/SamirTalwar/the-tiniest-service/tree/dockerfile
