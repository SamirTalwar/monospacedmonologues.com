---
title: "Docker, Part Eight: Turn Up The Volume"
slug: docker-part-eight--turn-up-the-volume
date: 2016-03-04T08:00:39Z
aliases:
  - /post/140436373509/docker-part-eight-turn-up-the-volume
---

(Can you tell I'm enjoying these awful puns?)

Yesterday, we created a container for PostgreSQL, my database of choice in a pinch. This was fairly simple, but had a problem you don't see with stateless applications: the data on disk needs to be preserved across restarts and even replacements of the container.

Once the PostgreSQL container starts, it checks for a database in its own _/var/lib/postgresql/data_. If there is no database there, it creates one (and we can tell it how using environment variables which this container is specifically designed to observe). If there is a database there, it uses it.

<!--more-->

When we run containers, we can tell Docker to mount a _volume_. This takes the form of a path in the host, mounted as a path in the container. Here's a simple example. Imagine we have a script called _increment_:

    #!/bin/sh

    set -e

    file=/data/counter

    if [ ! -e $file ]; then
        mkdir -p `dirname $file`
        echo 0 > $file
    fi

    dc "`cat $file` 1 + p" > /tmp/counter
    mv /tmp/counter $file

(The reason we write to a temporary file is in case the calculation fails for some reason; it won't overwrite the original file with nothing.)

In case you were wondering, `dc` is a reverse-Polish notation calculator I learnt how to use about two minutes ago. If the _/data/counter_ file contains "7", we'll run `dc '7 1 + p'`, which means:

1. Push `7` onto the stack.
2. Push `1` onto the stack.
3. Run the `+` operation, which pops the first two numbers off the stack and pushes their sum.
4. Run the `p` command, which peeks at the first value on the stack (but does not pop it) and prints it.

Basically, it outputs `8`.

Back to volumes. If I run this script in a new container each time, it'll just print `1` over and over again. Let's put it in one with a Dockerfile.

    FROM busybox
    COPY increment /increment
    CMD sh -c '/increment && cat /data/counter'

Let's run it.

    $ docker build --tag=increment .
    ...
    $ docker run --rm -it increment
    1
    $ docker run --rm -it increment
    1
    $ docker run --rm -it increment
    1

It's… as we expected. The container creates a new file, increments it and prints it.

However, if we _mount a volume_ in the container, things are a bit different.

    $ docker run --rm -it -v ~/Projects/increment/data:/data increment
    1
    $ docker run --rm -it -v ~/Projects/increment/data:/data increment
    2
    $ docker run --rm -it -v ~/Projects/increment/data:/data increment
    3

Here, I've mounted a new directory (which was created for me), _data_ in my current directory, to _/data_ on the host. This means that when my container writes to _/data/counter_, it's actually writing to _~/Projects/increment/data/counter_, which, unlike my container, is persistent.

(By the by, the reason this works when using Docker Machine is because the _/Users_ directory (on Mac OS) is a shared directory between the host and the VM. Docker uses standard Linux filesystem mounts, so it can't mount directories across networks.)

So where does this leave us? If we want to preserve our database data, we can use the same tools. Stop and remove the PostgreSQL container, then restart it as follows:

    $ docker run \
        -d \
        --name=postgres \
        --net=bemorerandom \
        -v ~/Projects/bemorerandom.com/postgresql:/var/lib/postgresql/data \
        postgres

Now, if I inspect the logs, I might see it won't start. Something like this:

    postgres cannot access the server configuration file "/var/lib/postgresql/data/postgresql.conf": Permission denied

This is because the files don't have the correct permissions. There are two courses of action to take, depending on whether you're mounting files from the _actual_ host or if you're sharing directories between your computer and the Docker host in a VM.

If you're running containers directly on your operating system, you need to change the ownership of the directory you want to mount so it's owned by the `postgres` user. As you don't have that user on your machine, you need to find out what its ID is instead.

    $ docker exec -it postgres bash
    # ls -l /var/lib/postgresql
    total 4
    drwx------ 19 postgres root 4096 Mar  4 01:11 data

We can see here that the _/var/lib/postgresql/data_ directory is owned by the `postgres` user, as we stated. We can now check for its user ID:

    # fgrep postgres /etc/passwd
    postgres:x:999:999::/home/postgres:/bin/sh

It has a user ID of `999`, which is also its own group ID. So we should change ownership as follows:

    $ chown -R 999:999 postgresql

Now, if you're using a Docker Machine shared directory, things are a little different. The directories are _always_ owned by the same user. Just SSH in and find out.

    $ docker-machine ssh

    $ ls -l /Users/samir/Projects/bemorerandom.com
    total 20
    -rw-r--r--    1 docker   staff           53 Feb 28 14:14 README.md
    drwxr-xr-x    1 docker   staff          204 Mar  3 03:04 api/
    -rw-r--r--    1 docker   staff          725 Feb 28 21:21 api.Dockerfile
    -rw-r--r--    1 docker   staff          606 Feb 28 14:13 bemorerandom-parent.iml
    -rw-r--r--    1 docker   staff         2653 Mar  3 02:52 pom.xml
    drwxr-xr-x    1 docker   staff          102 Mar  2 22:10 postgresql/
    -rw-r--r--    1 docker   staff         1541 Feb 28 21:52 settings.xml

    $ fgrep docker /etc/passwd
    docker:x:1000:50:Linux User,,,:/home/docker:/bin/sh

We can see here that everything is owned by the `docker` user, which as an ID of `1000`. We can use this to change ownership appropriately:

    $ chown -R 1000 postgresql

Now we can restart that container properly and have it store data to a persistent directory. No more data loss.

## Anti-Patterns

I want to talk briefly about two anti-patterns that are often recommended by the Docker folks.

The first is mounting a volume without specifying a host directory. You can do this by providing the `-v` switch with only the container directory:

    $ docker run -d -v /var/lib/postgresql/data postgres

The second is a _data container_, which is a container which hosts the volumes.

    $ docker run --name=postgresql-data -d -v /var/lib/postgresql/data postgres true

We can then run our real container with volumes mounted from the data container:

    $ docker run -d --volumes-from=postgresql-data postgres

Both of these create volume mounts, but hide them away in _/var/lib/docker_ with the rest of the container information. While we can use `docker inspect` to find out the volume path, it's still not very helpful, as it's very easy to destroy with `docker rm` and can't be easily shared across containers. For these reasons, I recommend you always mount data outside Docker, rather than relying on Docker to maintain your data.

---

This has been a really hard week for me, as these posts have taken way longer than planned. Next week, I'm going to keep things a little less intense and concentrate on more of the management side of software development (I think). I'll be back to talking about Docker the following week, starting with orchestrating multiple containers using Docker Compose.
