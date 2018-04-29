---
title: "Docker, Part Two: Images and Containers"
date: 2016-02-23T08:00:15Z
---

We left off, dear reader, with you running the following:

    $ docker run hello-world

That would have resulted in output similar to this:

    To generate this message, Docker took the following steps:
     1. The Docker client contacted the Docker daemon.
     2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
     3. The Docker daemon created a new container from that image which runs the
        executable that produces the output you are currently reading.
     4. The Docker daemon streamed that output to the Docker client, which sent it
        to your terminal.

    To try something more ambitious, you can run an Ubuntu container with:
     $ docker run -it ubuntu bash

    Share images, automate workflows, and more with a free Docker Hub account:
     https://hub.docker.com

    For more examples and ideas, visit:
     https://docs.docker.com/userguide/

Let's break it down.

<!--more-->

## Client and Server

As we explained before, the `docker` program is actually just a client that connects to a service or daemon, sometimes on the same computer, but often on a different one. If you're using Docker Machine, you're taking advantage of this to talk to a VM (and if you open up your VM manager, probably VirtualBox, you'll see it right there). It uses the `DOCKER_HOST` environment variable to find it. You can check yours by `echo`-ing it.

    $ echo $DOCKER_HOST
    tcp://192.168.99.100:2376

If it's blank, you'll be connecting to your local machine through a Unix socket, probably located at */var/run/docker.sock*. Of course, as Docker rides on the back of Linux containers, this can only work on Linux, as the daemon must be running on Linux.

## Pulling an Image

Before we can run a container, we need an image to base it on. In this case, we're looking for an image tagged *hello-world*. You can explicitly pull an image by using `docker pull <image tag>`, but if you just try to run one, `docker run` will automatically pull the image, assuming you haven't done so already.

In doing so, you'll see a few progress bars that look like this:

    latest: Pulling from library/hello-world
    03f4658f8b78: Downloading [====>                                              ] 103 B/601 B
    a3ed95caeb02: Download complete
    Digest: sha256:8be990ef2aeb16dbcb9271ddfe2610fa6658d13f6dfb8bc72074cc1ca36966a7
    Status: Downloaded newer image for hello-world:latest

Docker will automatically download the image you need, but in order to run it, it also needs a few more. Images are *hierarchical*, in that each image is based on a previous image. These images sometimes have "tags" ("hello-world", in our case), but they always have IDs. These IDs are unique and immutable, just like Git commit hashes; if you change the image, you change the ID. However, the tags are not; *hello-world* might point to another image in the future.

Type the following into your terminal:

    $ docker images

If it's anything like mine, you'll see something like this:

    REPOSITORY                                        TAG                     IMAGE ID            CREATED             VIRTUAL SIZE
    hello-world                                       latest                  af340544ed62        9 weeks ago         960 B

This particular image is tiny, as you'd expect; it's only 960 bytes. But it's not the whole story. Run `docker images --all`, and you'll see what I mean.

    REPOSITORY                                        TAG                     IMAGE ID            CREATED             VIRTUAL SIZE
    hello-world                                       latest                  af340544ed62        9 weeks ago         960 B
    <none>                                            <none>                  535020c3e8ad        9 weeks ago         960 B

You have two images on your system. One is tagged *hello-world*, but the other has no tag at all, just an ID. It's there because just like Git commits, each Docker image depends on a previous image until you reach the root. The *virtual size* is the size of the image plus all its parents; the actual image may be much smaller. For example, the *hello-world* image itself (ID *af340544ed62* on my computer) takes no space at all; it's purely there to invoke the correct command.

## What's In An Image?

We can use the `docker inspect` tool to delve deep into the composition of an image.

    $ docker inspect hello-world

This will spit out a bunch of JSON. Most of it is uninteresting right now, but there are two parts that you should take a look at. First, the first couple of lines:

    [
    {
        "Id": "af340544ed62de0680f441c71fa1a80cb084678fed42bae393e543faea3a572c",
        "Parent": "535020c3e8add9d6bb06e5ac15a261e73d9b213d62fb2c14d752b8e189b2b912",
        ...

We can see the ID is 64 hexadecimal characters, or 32 bytes, unlike the one we saw before. They're actually the same ID; the one in the output of `docker images` is just the first 12 characters, which is pretty much guaranteed to be unique enough to identify the image. (You can refer to Docker images and containers through any unique prefix of their ID—try typing `docker inspect af3`.) We can also see that the image has a parent.

The other interesting part is this:

    [
    {
        ...
        "ContainerConfig": {
            ...
            "Cmd": [
                "/bin/sh",
                "-c",
                "#(nop) CMD [\"/hello\"]"
            ],
            ...
        },
        ...

This is a bit perplexing, but the important part is this (without the escape characters): `CMD ["/hello"]`. This tells Docker that the image should run the command `/hello` as it is run.

If we inspect the parent using its ID, we can find out more:

    $ docker inspect 535020c3e8ad

Two things are different about this. First of all, this image has no parent—it was created from scratch. You will almost never do this; you'll always start from a useful base image. Secondly, it has the following command:

    [
    {
        ...
        "ContainerConfig": {
            ...
            "Cmd": [
                "/bin/sh",
                "-c",
                "#(nop) COPY file:4abd3bff60458ca3b079d7b131ce26b2719055a030dfa96ff827da2b7c7038a7 in /"
            ],
        },
        ...

This command copies a file from the host to the container. You'll have to trust me when I say it's the `hello` script that's being invoked in the child image.

Now, this has already been run. One interesting thing about the way Docker works is that containers are created from images, but images are created by *committing* a container, which takes a running container and saves its disk as an image. We'll see how to do this ourselves soon. Each of the two images that make up `hello-world` are constructed like this.

In short, we asked for an image, and we got two.

## Creating a Container from an Image

By using Docker's `run` command, you asked it to run the *hello-world* image as a container. You can see that container now, by running the following command:

    $ docker ps --all

The `--all` (or `-a`) flag tells it to show stopped containers as well as running ones. Mine shows this:

    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
    eb1a963dc91f        hello-world         "/hello"            6 seconds ago       Exited (0) 3 seconds ago                       sharp_wozniak

Yours will look somewhat different, but parts will be the same. It has an ID and a name; you can specify the name when running with the `--name` flag when running, but the ID is always unique and automatically generated. We can see that the container was created from the *hello-world* image (more on that later). The `/hello` command was run as the container started, and it exited with a status code of 0, so it's no longer running.

Often, we'll create containers that continue to run for a long time, for example when running a web server or other service. In that case, we'll see a status that looks something like "Up 17 minutes", to tell us that the container is running and will continue to run. We'll see an example of this in the next article.

Stopped containers will stick around forever, or at least until you actively remove them with `docker rm <container name or ID>`. You may think that this can cause a lot of clutter, and you'd be right. In fact, you can pass the `--rm` flag to `run` in order to make sure the container is removed as soon as it's stopped. However, there's an important reason why you might not.

## Output to the Terminal

When we run a container, any output to STDOUT or STDERR is sent directly back to the client. This is very useful for short-lived tasks, but if we want to run a web server, we don't necessarily want to leave a terminal window open to capture the output. Fortunately, Docker also captures the output in a log file, which we can query using the `docker log` command.

Try it. I'm using the name of my container, *sharp_wozniak*, here, but you should substitute it for your own.

    $ docker logs sharp_wozniak

You should see exactly the same output as you saw before. This becomes more useful when running a container in *detached mode* using the `--detach` or `-d` flag:

    $ docker run -d hello-world

Instead of the output of the command, this time it just printed out the full ID of the container (mine was `cc3088e8a2e2119f47ae09d146646602b11f0eb38c116bce41ab171246b61380`). This is useful when scripting, as you can capture it for further work. Of course, on the command line, we can always get the name and the ID by running `docker ps -a`.

So how do we see the output? Using `docker logs`, of course. Try it. I'm using my container ID here, but you should use your own.

    $ docker logs cc3088e8a2e2

You should get exactly the same "To generate this message…" output.

## So, why is this useful?

A "Hello, World!" script isn't too amazing, but remember what's happening: we pulled down an image, ran it on a server and streamed the output to the client, all in under a few seconds. Next we'll see how to run our own software and keep it running in the background.
