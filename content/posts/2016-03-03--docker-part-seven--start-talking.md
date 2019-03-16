---
title: "Docker, Part Seven: Start Talking"
slug: docker-part-seven--start-talking
date: 2016-03-03T08:00:21Z
aliases:
  - /post/140379415297/docker-part-seven-start-talking
---

When we left off, we had a Scala web service running inside a Docker container. That's all well and good, but we usually need a little more than a stateless machine. How about we bring in a database?

I've added a feature to [_bemorerandom.com_][bemorerandom.com] that'll make use of a PostgreSQL database. Here's how it works:

<!--more-->

    $ http :8080/dnd/npc/female/halfling
    HTTP/1.1 200 OK
    Content-Encoding: gzip
    Content-Length: 175
    Content-Type: application/json; charset=utf-8

    {
        "attribution": {
            "name": "Chris Perkins",
            "uri": "http://brandondraga.tumblr.com/post/66804468075/chris-perkins-npc-name-list"
        },
        "random": {
            "npc": {
                "name": "Vil Tricker",
                "race": "halfling",
                "sex": "female"
            }
        }
    }

It generates random NPC names, using [Chris Perkins' wonderful name lists][chris perkins' npc name list], and serves them up. I've written a (fairly long) SQL file that lobs all of the names into the PostgreSQL database. Now I just need to wire the two together.

So, let's fire up a PostgreSQL instance. There's an official image on Docker Hub called `postgres`, so let's use that.

    $ docker run -d --name=postgres -p 5432:5432 postgres

Give it a few minutes to download, and then check the logs with `docker logs -f postgres`. They should look like this:

    LOG:  MultiXact member wraparound protections are now enabled
    LOG:  database system is ready to accept connections
    LOG:  autovacuum launcher started

Not a lot there, but the true test of the database isn't whether it's logging. It's whether we can connect to it. We'll start by creating a local connection. The `postgres` image ships with the PostgreSQL client tools, including `psql`, the command-line interface to the database. We can run it in the running container:

    $ docker exec -it postgres psql -U postgres

It defaults to the _root_ user, as that's who we end up running as when we `docker exec`, so we need to tell the client to switch to the _postgres_ user, which is the default superuser account in this image.

Note that we didn't have to tell it where PostgreSQL lives. That's because it defaults to connecting over a local socket. That's also why we didn't need to provide a password—that's only necessary if you connect over a network socket.

You should be able to play around a bit. Create a table, drop it. That sort of thing. Experiment.

OK, we have a database instance. We're good to go. Let's create a user and a database for the application. PostgreSQL instances can have multiple databases, keeping your applications totally isolated from each other. To do this, we'll use the `createuser` and `createdb` programs, which also ship with the image.

    $ docker exec -it postgres createuser -U postgres -P bemorerandom

The `-P` switch tells `createuser` to prompt for a password. Type in a complicated one. I like to use [GRC's password generator][grc perfect passwords].

    $ docker exec -it postgres createdb -U postgres -O bemorerandom bemorerandom

That `-O` switch tells the `createdb` command that the _bemorerandom_ user should own this new database. We call it the same name because PostgreSQL assumes that a user will connect to a database with the same name by default, so it makes life a little easier when using the tooling.

Right. Back to the I've instructed my application to load the `DB_URL`, `DB_USER` and `DB_PASSWORD` environment variables on startup, so we can tell it where the database lives. Let's run it without using Docker for now, just to keep things simple:

    export DB_URL=jdbc:postgresql://<my docker IP>:5432/bemorerandom
    export DB_USER=bemorerandom
    export DB_PASSWORD=<password>
    mvn --projects=api exec:java

Voila. We have a working application that talks to a database in Docker! Now we just need to get the application inside Docker.

We could access PostgreSQL from an external location because port 5432 is forwarded to the Docker host. When we run inside a container, we won't be able to access it. We need to connect the containers together.

We used to solve this problem with _container linking_, but that's considered a little old-hat now. I recommend avoiding it in favour of the new shiny thing, _container networks_. However, I'd recommend looking up linking, as you might see it in the wild (usually in the form of a `--link` switch passed to `docker run`), and it's good to know what you might encounter.

Anyway. Back to the point. Let's create a container network.

    $ docker network create bemorerandom

That was easy. Now we need to connect our running _postgres_ container to it:

    $ docker network connect bemorerandom postgres

Finally, we need to start our application container and connect it to the network. To do this, rather than connecting it after starting it, we'll use the `--net` switch to connect it on launch. I'm going to space this one out so we catch everything.

    $ docker run \
        -d \
        --name=bemorerandom-api \
        -p 8080:8080 \
        --net=bemorerandom \
        -e DB_URL=jdbc:postgresql://postgres.bemorerandom/bemorerandom \
        -e DB_USER=bemorerandom \
        -e DB_PASSWORD=<password> \
        samirtalwar/bemorerandom.com-api

There's two interesting things here. One is that, as we said, we're using the `--net` switch to tell Docker to connect this container to the _bemorerandom_ network as soon as it launches. The second thing is that the database URL has changed. Now the host name is _postgres.bemorerandom_. This isn't a coincidence. It's simply the name of the container, followed by the name of the container network. Because they're on the same isolated network, they can talk to each other without issue.

So there we have it. Two containers, happily talking to each other. They just needed to be shown how.

Except… there's just one more thing. (I've been saying that a lot. All I need is a cigar and a glass eye to complete the picture.)

Stop the containers, and remove them. Then start them up again.

    $ docker stop bemorerandom-api postgres
    $ docker rm bemorerandom-api postgres
    $ docker run ...

All the data from PostgreSQL is gone. Kaput. No more. It was in the container, and it's gone with the container. Obviously, this isn't good enough.

Tomorrow, we're going to look at _volumes_, and how we can keep our data around.

[bemorerandom.com]: https://github.com/SamirTalwar/bemorerandom.com
[chris perkins' npc name list]: http://brandondraga.tumblr.com/post/66804468075/chris-perkins-npc-name-list
[grc perfect passwords]: https://www.grc.com/passwords
