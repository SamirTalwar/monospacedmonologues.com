---
title: "Docker, Part Seventeen: Continuous Deployment"
slug: docker-part-seventeen--continuous-deployment
date: 2016-10-25T07:00:30Z
aliases:
  - /post/152284505852/docker-part-seventeen-continuous-deployment
---

*Apologies folks. I wrote this ages ago and apparently never published it. Well, late is better than never, so here it is!*

*You may want to remind yourself of [Docker Compose][Docker, Part Ten: Docker Compose] and [The Guts Of Docker Compose][Docker, Part Eleven: The Guts Of Docker Compose] first.*

[Docker, Part Ten: Docker Compose]: http://monospacedmonologues.com/post/141079525786/docker-part-ten-docker-compose
[Docker, Part Eleven: The Guts Of Docker Compose]: http://monospacedmonologues.com/post/141136358098/docker-part-eleven-the-guts-of-docker-compose

---

Once we have a container, we can run it on a server.

    $ ssh my-production-server docker-compose up -d

Of course, we need to get the container images there first. This is where continuous integration comes in.

<!--more-->

## The Continous Delivery Pipeline

Imagine we're using a continuous integration server such as [Jenkins][] or [Travis CI][]. We need to define a pipeline. It won't just *integrate*; it'll *deliver* as well.

### Step One: Build The Image

    $ docker-compose build --pull

We'll use the `--pull` switch to ensure we're using the latest versions of all our images and base images.

### Step Two: Run The Tests

You can run these inside Docker or outside. I'm still not sure which approach is better. For [bemorerandom.com][], I opted to run them outside as I want to be able to run a single one in my IDE. To do the same here, I'll just use Maven.

    $ mvn -B verify

Some of my tests require a database, so [I've created a docker-compose YAML file][docker-compose.test.yml] that runs the tests and [a script that gathers the results][test script]. I run it like this:

    $ ./test

### Step Three: Publish the Images

After building the images, we need to push them to our registry. You might be using Docker Hub for this or your own. We'll specify the specific image name in the *docker-compose.yml* file so that we can push to registry.

    services:
      api:
        image: samirtalwar/bemorerandom-api
        build:
          context: .
          dockerfile: api.Dockerfile

      ...

Ideally, as well as pushing a new `latest` image, we'd be versioning our images and pushing them with the version numbers as the tags. As that's different for every project, you'll probably want to figure out how to do that yourself on a per-project basis rather than letting me tell you how. (I *would* recommend avoiding a scheme that requires manually incrementing a number. I like to use the Git commit hash as the version.)

Next, we just need a simple script to push the images.

    #!/bin/sh

    set -e

    docker-compose build api init-db
    docker push 'samirtalwar/bemorerandom-api'
    docker push 'samirtalwar/bemorerandom-initialize-database'

## Automating It

Once we have a simple way to run our tests, we can define a build pipeline. This can be done in a number of ways, either through your continuous integration UI or in code. I prefer to do it in code, as it can be versioned alongside the rest of the code. Using the new [Jenkins 2.0][] pipeline DSL, we can do something like this:

    node {
        stage 'build'
        sh 'docker-compose build --pull'

        stage 'test'
        sh './test'

        stage 'push'
        sh './push-to-registry'
    }

Or in a *.travis.yml* file:

    script:
      - docker-compose build --pull
      - ./test
      - ./push-to-registry

Nothing gets pushed unless it passes the tests.

Now here's the cool part. We can instruct the CI server to log in to our server, pull the latest images and spin up the containers. We'll use Docker Compose for this part too. Because we've named the images, we can pull them using `docker-compose pull`, then start (or restart) them using `docker-compose up -d`.

    #!/bin/sh

    set -e

    scp docker-compose.yml production-server:/app/docker-compose.yml
    ssh production-server sh -c '
        set -e
        cd /app
        docker-compose pull
        docker-compose up -d
    '

The script above copies the *docker-compose.yml* file over to a server named *production-server*, then tells `docker-compose` to do its work. After a few seconds, you should be able to navigate to your server's domain and see your application running.

## What's Next?

When we bring up the new version of our application, for a little while, it won't respond, as the previous process will have stopped and the new one won't have initialised it. To get it working correctly, we'll need to venture into blue-green deployment—in other words, starting the second instance up, verifying it's working correctly, then shutting the old one down.

In this scenario, we're also running the database on the same server as the application. If you'd like to keep them separate, we have two options: making the instructions more complicated, or using clustering technology such as [Docker Swarm][], [Kubernetes][] or [Marathon][] to intelligently distribute containers among a cluster of servers. These technologies can also handle proper blue-green deployment, as they know how to run multiple instances of a given container.

[bemorerandom.com]: https://github.com/SamirTalwar/bemorerandom.com
[docker-compose.test.yml]: https://github.com/SamirTalwar/bemorerandom.com/blob/master/docker-compose.test.yml
[test script]:  https://github.com/SamirTalwar/bemorerandom.com/blob/master/test

[Jenkins]: https://jenkins.io/
[Jenkins 2.0]: https://jenkins.io/2.0/
[Travis CI]: https://travis-ci.org/

[Docker Swarm]: https://www.docker.com/products/docker-swarm
[Kubernetes]: http://kubernetes.io/
[Marathon]: https://mesosphere.github.io/marathon/
