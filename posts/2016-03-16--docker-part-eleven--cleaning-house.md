# Docker, Part Eleven: Cleaning House

We've come a long way, but as they say, you can't make an omelette without breaking some eggs.

Lets have a look at the mess I've made in the last couple of days.

    $ docker images
    REPOSITORY                      TAG                 IMAGE ID            CREATED             SIZE
    bemorerandomcom_api             latest              ee591f000c4c        2 minutes ago       643.2 MB
    samirtalwar/the-tiniest-service latest              401522f0175b        6 minutes ago       1.114 MB
    <none>                          <none>              9fbf9a59988f        7 minutes ago       1.114 MB
    <none>                          <none>              c22ec25253af        8 minutes ago       1.114 MB
    <none>                          <none>              ebbf152e136f        9 minutes ago       1.114 MB
    <none>                          <none>              034202381eca        9 minutes ago       1.114 MB
    <none>                          <none>              ec5891ebc3f9        9 minutes ago       1.114 MB
    <none>                          <none>              e91988c244d5        22 minutes ago      1.114 MB
    the-tiniest-service             latest              aa71c157e5c9        24 minutes ago      1.114 MB
    <none>                          <none>              32fcd4341331        About an hour ago   643.2 MB
    <none>                          <none>              60a018e9ae4b        About an hour ago   643.2 MB
    <none>                          <none>              efdbce09b64a        About an hour ago   643.2 MB
    <none>                          <none>              7e40d3d4a74a        2 hours ago         643.2 MB
    <none>                          <none>              d4bbd39cccf8        2 hours ago         643.2 MB
    <none>                          <none>              26cc23f815d7        2 hours ago         643.2 MB
    <none>                          <none>              d6ffefc6672b        2 hours ago         643.2 MB
    <none>                          <none>              8f345a9c9755        2 hours ago         643.2 MB
    <none>                          <none>              90937b11bd07        2 hours ago         643.2 MB
    <none>                          <none>              e4e91ba734ae        2 hours ago         643.2 MB
    <none>                          <none>              62de87eca7f0        2 hours ago         643.2 MB
    <none>                          <none>              1946af721e75        2 hours ago         643.2 MB
    <none>                          <none>              619a2b13231c        2 hours ago         643.2 MB
    <none>                          <none>              504b61bd6b9e        2 hours ago         643.2 MB
    <none>                          <none>              886cb7baed18        2 hours ago         643.2 MB
    <none>                          <none>              2eb24ea71dae        2 hours ago         643.2 MB
    <none>                          <none>              41a82b35ff7d        2 hours ago         643.2 MB
    <none>                          <none>              02b46b0f1f88        2 hours ago         643.2 MB
    ...

Welp. That's a lot of images. Let's take a look at the processes.

    $ docker ps -a
    CONTAINER ID        IMAGE                                                COMMAND                  CREATED             STATUS                        PORTS                    NAMES
    5803a88a6e6f        bemorerandomcom_api                                  "/bin/sh -c 'java -cp"   33 seconds ago      Up 9 seconds                  0.0.0.0:8080->8080/tcp   bemorerandomcom_api_1
    83f842511e98        bemorerandomcom_init-db                              "/docker-entrypoint.s"   34 seconds ago      Exited (0) 11 seconds ago                              bemorerandomcom_init-db_1
    eae5f834e9af        postgres                                             "/docker-entrypoint.s"   35 seconds ago      Up 12 seconds                 5432/tcp                 bemorerandomcom_database_1
    cc153b24d5c6        jfrog-docker-reg2.bintray.io/jfrog/artifactory-oss   "/bin/sh -c /tmp/runA"   3 hours ago         Up 2 minutes                  0.0.0.0:8081->8081/tcp   artifactory
    4352c0fb03f2        e91988c244d5                                         "/bin/sh -c ./web-ser"   10 minutes ago      Exited (130) 9 minutes ago                             hopeful_jepsen
    4861186678c3        e91988c244d5                                         "/bin/sh -c ./web-ser"   20 minutes ago      Exited (137) 19 minutes ago                            drunk_mcclintock
    6b733988ce9b        e91988c244d5                                         "/bin/sh -c ./web-ser"   20 minutes ago      Exited (137) 20 minutes ago                            serene_morse
    ed94a77e8522        the-tiniest-service                                  "/bin/sh -c ./web-ser"   22 minutes ago      Exited (137) 20 minutes ago                            determined_easley
    63a37ffabd00        postgres                                             "/docker-entrypoint.s"   23 minutes ago      Exited (130) 23 minutes ago                            sick_hoover
    982ccb7eea2b        ab091b02e41d                                         "/bin/sh -c ./web-ser"   28 minutes ago      Exited (130) 27 minutes ago                            desperate_stallman
    e599ff2f1b5b        ab091b02e41d                                         "/bin/sh -c ./web-ser"   29 minutes ago      Exited (130) 28 minutes ago                            elegant_franklin
    685d301d688f        hello-world                                          "/hello"                 35 minutes ago      Exited (0) 35 minutes ago                              high_albattani

Huh. What about the volumes and networks?

    $ docker network ls
    NETWORK ID          NAME                      DRIVER
    d5f0b701f820        bemorerandomcom_default   bridge
    2dd4c458c57a        none                      null
    b0137f015403        host                      host
    5200d85d8129        bridge                    bridge

    $ docker volume ls
    DRIVER              VOLUME NAME
    local               artifactory-data
    local               artifactory-etc
    local               artifactory-logs
    local               bemorerandomcom_postgresql
    local               6328ee0027c6d461ff15149fc073e020b0c200e1b9c2ef6e35993e1677dda573
    local               33779fc6ac0d72620e56aaa9a31e6116cd39c64a1900304cdae6f59804994e73
    local               artifactory-backup

There's a lot of old containers, old images… you get the idea.

## Cleaning Up Processes

Let's take a look at the processes first. We probably don't need to keep around exited containers. While you may want to restart containers, I find it's generally better to assume they're transient and keep anything you really need around in volumes. So let's `docker rm` them all.

First of all, let's get a list of just the exited ones.

    $ docker ps -a -f status=exited
    CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                        PORTS               NAMES
    f8cac2b6a910        bemorerandomcom_init-db   "/docker-entrypoint.s"   About a minute ago   Exited (0) About a minute ago                       bemorerandomcom_init-db_1
    4352c0fb03f2        e91988c244d5              "/bin/sh -c ./web-ser"   11 minutes ago       Exited (130) 10 minutes ago                         hopeful_jepsen
    ...

Brilliant. We can now just get the IDs.

    $ docker ps -a -f status=exited -q
    f8cac2b6a910
    4352c0fb03f2
    ...

And now we can delete them all by piping them to `docker rm`. This command takes container names or IDs on the command line, just like `rm`, so we'll use `xargs` to convert standard input to arguments.

    $ docker ps -a -f status=exited -q | xargs docker rm

## Removing Old Images

Next up are the images. We can do pretty much the same thing, by asking for a list of dangling images:

    $ docker images -f dangling=true
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    <none>              <none>              9fbf9a59988f        18 minutes ago      1.114 MB
    <none>              <none>              c22ec25253af        19 minutes ago      1.114 MB
    <none>              <none>              ebbf152e136f        19 minutes ago      1.114 MB
    <none>              <none>              034202381eca        19 minutes ago      1.114 MB
    <none>              <none>              ec5891ebc3f9        19 minutes ago      1.114 MB
    <none>              <none>              e91988c244d5        33 minutes ago      1.114 MB
    <none>              <none>              9483181fd50d        3 hours ago         643.2 MB
    <none>              <none>              ab091b02e41d        9 months ago        2.434 MB

Then we just pipe it to `docker rmi`:

    $ docker images -f dangling=true -q | xargs docker rmi

## Cleaning Up Networks

Networks don't often get created by accident, so I'd like to leave those alone for now. The best advice I can give you is to check the list every now and again and run `docker network rm` to remove the extras.

## Trashing Expired Volumes

Volumes can be created in one of three ways:

  1. we've created it explicitly with `docker volume create`,
  2. we bound a volume but didn't give it a target with the `-v` flag, passed to `docker run`, or
  3. the image we're using specifies that a certain directory must be mounted as a volume.

I operate on a simple policy: if I care about the data, I name the volume. If I don't care, I don't bother. This allows me to easily distinguish between the volumes I care about and the one's I don't: the volumes I didn't create have names that consist of 64 characters of hexadecimal.

Just like images, `docker volume ls` can take a filter to find only volumes that are unattached to any container (including stopped containers):

    $ docker volume ls -f dangling=true
    DRIVER              VOLUME NAME
    local               bemorerandomcom_postgresql
    local               6328ee0027c6d461ff15149fc073e020b0c200e1b9c2ef6e35993e1677dda573

Next, we can just get the name, and filter out anything that isn't randomly generated with a simple regex[^simple regex]:

    $ docker volume ls -f dangling=true -q | awk '$0 ~ "^[0-9a-f]{64}$"'
    6328ee0027c6d461ff15149fc073e020b0c200e1b9c2ef6e35993e1677dda573

That `awk` expression compares each line to the regular expression `^[0-9a-f]{64}$`, which only matches if the string is exactly 64 characters, consisting only of `0-9` and `a-f`.

Finally, we pipe it to `docker volume rm`:

    $ docker volume ls -f dangling=true -q | awk '$0 ~ "^[0-9a-f]{64}$"' | xargs docker volume rm

[^simple regex]: Lies. Regular expressions are never simple.

## A Simple Script

I keep a simple cleanup script named [*docker-cleanup*][docker-cleanup] on my *PATH*, consisting of those three lines. I run it whenever I find myself squinting at the output of `docker ps` or `docker images`, trying to find the item I want. It doesn't just keep my system clean, but my mind too.

    #!/usr/bin/env zsh

    set -e

    echo 'Removing exited processes...'
    docker ps --filter=status=exited --quiet | xargs docker rm

    echo 'Removing dangling images...'
    docker images --filter=dangling=true --quiet | xargs docker rmi

    echo 'Removing dangling, unnamed volumes...'
    docker volume ls --filter=dangling=true --quiet | awk '$0 ~ "^[0-9a-f]{64}$"' | xargs docker volume rm

    echo 'Your Docker is now sparkling.'

I don't think it's stable enough to publish, but if you want to hang onto it, I won't stop you.

[docker-cleanup]: https://github.com/SamirTalwar/fygm/blob/master/bin/unix/docker-cleanup
