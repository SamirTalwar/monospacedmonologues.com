---
title: "Docker, Part Eight and a Half: docker volume"
slug: docker-part-eight-and-a-half--docker-volume
date: 2016-03-07T08:00:37Z
---

I know I said I wouldn't be writing about Docker this week but I wanted to correct the record. After Friday's post, [Lewis][@_lwis] got in touch to ask why I hadn't talked about the new Docker volumes. (Thanks Lewis!) I have to confess, I hadn't even heard of them. Like the new networking functionality, `docker volume` represents a shift in the way of thinking towards more than just containers. Instead of volumes being an attribute of a container, they're entities in their own right.

[@_lwis]: https://twitter.com/_lwis

<!--more-->

So let's revisit our PostgreSQL container from last week, but this time using a Docker volume.

First off, we need to create one.

    $ docker volume create --name=bemorerandom-postgresql

This will create a directory somewhere under */var/lib/docker*:

    $ docker volume inspect bemorerandom-postgresql
    [
        {
            "Name": "bemorerandom-postgresql",
            "Driver": "local",
            "Mountpoint": "/mnt/sda1/var/lib/docker/volumes/bemorerandom-postgresql/_data"
        }
    ]

Now, when we run PostgreSQL, we can just use the name of the volume rather than a path to it. In reality, it'll mount the path we see above.

    $ docker run \
        -d \
        --name=postgres \
        -v bemorerandom-postgresql:/var/lib/postgresql/data \
        postgres

Everything else proceeds as normal, except that as Docker is managing the volume, we don't need to worry about file permissions because the container *will* be able to write to the mount point, guaranteed. We can just start our application:

    $ docker run \
        -d \
        --name=bemorerandom-api \
        -p 8080:8080 \
        --net=bemorerandom \
        -e DB_URL=jdbc:postgresql://postgres.bemorerandom/bemorerandom \
        -e DB_USER=bemorerandom \
        -e DB_PASSWORD=<password> \
        samirtalwar/bemorerandom.com-api

And everything is gravy.

## But How Safe Is It?

That volume will last until you remove it, either deliberately or accidentally. It's very easy, when developing, to delete something you didn't mean to. Maybe you trash all volumes and then realise you needed one. Perhaps you delete your entire Docker Machine VM. Whatever. The point is that it's pretty easy to lose data during development.

Turns out this happens on production too. Servers die. Hard disks fail. People type the wrong thing and drop entire tables.

So wherever your data is, on a Docker volume or somewhere in the omnibenevolent cloud, back your data up. Volumes are for persisting data between containers, not a magical solution that will preserve it forever. The same is true of your hard disks when you're not using Docker. At the very least, set up a nightly backup and and practice a restore once per month.

End of freak-out.
