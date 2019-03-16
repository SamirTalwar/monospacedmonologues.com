---
title: "Docker, Part Thirteen: The Twelve-Factor App"
slug: docker-part-thirteen--the-twelve-factor-app
date: 2016-03-29T07:00:33Z
aliases:
  - /post/141886562802/docker-part-thirteen-the-twelve-factor-app
---

A lot of the principles and practices I've tried to embody in my previous posts on Docker come straight from [The Twelve-Factor App][], a document spawned from, among many sources, Heroku's engineering practices. The Twelve-Factor App explains the principles behind creating robust, scalable software that behaves the same in development as it does in production.

Docker makes some of the twelve factors easier, and some of them harder. I want to go through each of them in turn and explain how and why. Before going through this, I strongly encourage you to read through the document and familiarise yourself with the principles. It changed the way I develop software, and I bet that if you haven't read it already, it'll change the way you do too.

[the twelve-factor app]: http://12factor.net/

<!--more-->

### I. Codebase

> One codebase tracked in revision control, many deploys

Docker doesn't really impact how you version your software, so we'll skip this one. If you're not releasing software that's committed to source control, though, get on that. Seriously.

### II. Dependencies

> Explicitly declare and isolate dependencies

Your dependencies must be specified explicitly; depending on implicitly-available code or data is a great way to ensure that your application doesn't work on some environments, or breaks when moving to new hardware. By forcing you to choose a base image and constructing a new image from it, Docker ensures that all your dependencies are explicit. This is one of the reasons I like it so much.

### III. Config

> Store config in the environment

You'll have noticed that in my _docker-compose.yml_ files, I inject the database location and credentials through environment variables. This is because it's subject to change, and therefore should be considered configuration. By depending on environment variables as our sole source of configuration, we prevent implicit knowledge of the environment leaking into the application, which could make it brittle when changing the infrastructure. Keeping our application independent of the infrastructure it runs on is a key part of The Twelve-Factor App.

Unfortunately, Docker makes secrets harder to manage. Secure secrets don't just need to be provided to the server hosting the application, but then injected through environment variables to the container. That extra hop makes life awkward. Without extra technology such as [Kubernetes][] or [Vault][], I haven't really found a good solution to this.

[kubernetes]: http://kubernetes.io/
[vault]: https://www.vaultproject.io/

### IV. Backing services

> Treat backing services as attached resources

Your backing services—database, caching layer, messaging systems, etc.—are often stateful, have independent lifecycles and very different requirements from a stateless application. As such, they need to be managed separately. In Docker Compose, these would be considered _services_ in their own right, and would have their own containers, limiting communication to the network layer. Modifications to the services—for example, scaling them up, hot-swapping them or running regular maintenance tasks such as database optimisations—can be done independently of software deployment.

### V. Build, release, run

> Strictly separate build and run stages

With Docker, our image is our artifact. Once we create the image and publish it to a [Docker Registry][], it's fixed—we can't change it (though we can, but should not, replace it). We then run a container from that image on the application server. Building and then running directly on the application server is considered a bad idea, as you're not testing the same image that goes into production.

Versioning images is hard. If your versioning is manual, it won't happen. Two solutions that have worked for me are:

1. Having the continuous integration server increment a version counter that's stored in a file in the repository, committing it, then building the image with that new version number embedded.
2. Using the Git commit hash as the version.

The latter is much simpler but means you can't compare two image versions by eye very easily. This has almost never been a problem for me in practice.

[docker registry]: https://docs.docker.com/registry/

### VI. Processes

> Execute the app as one or more stateless processes

This is something that Docker makes easy: if you've managed to build an image, a container run from that image will be one or more processes. Containers are designed to be transient, so you'll be replacing that container often, which means trashing the file system it's running on. As long as you don't mount volumes, you'll need to transfer any state to a backing service or lose it, which makes it stateless.

### VII. Port binding

> Export services via port binding

Again, Docker enforces this one, and even makes it easy to bind a random port and query it. To talk to a container, you must communicate over a network socket.

### VIII. Concurrency

> Scale out via the process model

If you've followed the steps above, your software should be scalable. And, given we have an image that represents the software, deploying multiple containers should cover us.

Docker Compose has built-in support for scaling, which, combined with [Docker Swarm][], allows you to scale across servers quickly. Last time I looked at Swarm, it seemed a bit immature, but the tooling seems to be pretty solid now.

Try it on your local machine. This'll scale our `app` service to three containers:

    $ docker-compose scale app=3

[docker swarm]: https://docs.docker.com/swarm/

### IX. Disposability

> Maximize robustness with fast startup and graceful shutdown

Container start-up time is something we haven't really touched upon, but should be investigated if it's taking longer than a second or two. Sure, Java isn't the fastest off the starting block, but once it's going, it should be pretty quick to start listening for HTTP requests on port 80.

Shutting down is something I'll be looking at tomorrow. If you've tried our [_bemorerandom.com_][bemorerandom.com] application, you may have noticed that it takes ten seconds to die after _Ctrl+C_ is sent. This is because that's Docker's default timeout for giving up and killing the process. I haven't investigated why this is happening, but it's bugging me and I'd like to fix it.

[bemorerandom.com]: https://github.com/SamirTalwar/bemorerandom.com

### X. Dev/prod parity

> Keep development, staging, and production as similar as possible

This is what drew me to Docker in the first place. The container model makes it much, much easier to remove any diversity between local development and production server environments. If I can run my applications and all their dependencies with Docker Compose, I can be much more certain than I used to be that the behaviour will be the same in production.

Once you have confidence in the similarity between environments, you can have developers push code that, after going through some automated checks, rolls straight into production. No more throwing code over the wall, waiting six weeks for it to be deployed and then saying, "nothing to do with me" when it goes wrong. Write (and ideally test-drive) some code, push it to source control, and watch it go straight into production (or at least staging) under your very nose.

And when it does go wrong, developers will be able to debug it, because the environments are the same.

### XI. Logs

> Treat logs as event streams

By capturing STDOUT and STDERR, Docker makes it very easy to follow Twelve Factor logging. Processes write to STDOUT, and we can inspect the logs with `docker logs`. It's available through the API too, so you can write tools that scrape it.

In Docker 1.8, pluggable logging drivers were added to the mix. This means that we can spin up a log-capturing service such as Fluentd and [integrate Docker container logging with just a few switches][fluentd: docker logging]. Wire this up to [Elasticsearch and Kibana][efk] for easily-trawlable logs.

[fluentd: docker logging]: http://www.fluentd.org/guides/recipes/docker-logging
[efk]: https://www.digitalocean.com/community/tutorials/elasticsearch-fluentd-and-kibana-open-source-log-search-and-visualization

### XII. Admin processes

> Run admin/management tasks as one-off processes

Docker makes certain kinds of admin processes harder. Sure, you can sideload processes with `docker exec`, but doing that on production servers necessitates manual intervention to the point where it makes me very uncomfortable. Automating it well requires starting a new container that communicates with the same backing stores as the application itself.

For example, if we need to migrate the database, we might run the same image as the application itself with the same environment variables, but provide a different command:

    $ docker run --rm --env=... registry.internal/super-duper-app rake db:migrate

Docker Compose, unfortunately, doesn't really have a mechanism for these one-off processes, and so if we were to use that, we'd have to declare it as a service and just make sure we don't run it by accident. Not ideal. We could split the _docker-compose.yml_ file into two and make sure that they share names, but managing that sounds pretty painful.

The Twelve-Factor App also specifies that this technique is useful for running REPLs and similar debugging tools. If you're screwed enough that you're debugging in production, sideloading through `docker exec` is probably your best bet. Just hope you actually have the tools you need—often, because we try and minimise container size, even simple tools such as a text editor are missing, and seriously, good luck loading up a Java REPL if you don't have one available already. There's an art to making sure your debugging tools are present in the container, and it's not one I'm well-versed in. Best of luck.

## And So…

Ugh. So much work, right?

To me, this is an extension of agile software development practices. If you want to be iterating quickly, gathering feedback and improving continuously, you need to break down the walls between development and operations. Sure, everyone's going to have their strengths and their weaknesses, but if you don't care how your software really runs when it hits production, you'll find that the cycle time between development and deployment increases, meaning a lot more work in progress and much more lag between conception and feedback.

It's worth it.
