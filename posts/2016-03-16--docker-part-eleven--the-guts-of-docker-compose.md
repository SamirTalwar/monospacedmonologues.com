Where were we? Ah yes, DNS resolution wasn't working.

    org.flywaydb.core.api.FlywayException: Unable to obtain Jdbc connection from DataSource
    (jdbc:postgresql://database:5432/bemorerandom) for user 'bemorerandom': The connection attempt failed.

We dug a little and found out that something's up in the Ubuntu configuration:

    root@c61890596067:/# getent hosts database
    172.18.0.2      database
    root@c61890596067:/# getent ahosts database
    root@c61890596067:/# getent ahostsv4 database
    172.18.0.2      STREAM database
    172.18.0.2      DGRAM
    172.18.0.2      RAW

`InetAddress.getByName` internally invokes [`getaddrinfo`][getaddrinfo] in the operating system's core C library, as does `getent ahosts` when given a key to look up. I don't know how to fix it, but I know how to work around it.

[getaddrinfo]: http://man7.org/linux/man-pages/man3/getaddrinfo.3.html

## Naming

Docker Compose names all the various components of your application prefixed with the name of the directory, stripped of any special characters. As I'm working in a directory named *bemorerandom.com*, that becomes my prefix. It's true of the images and containers too:

    $ docker images
    REPOSITORY                  TAG         IMAGE ID            CREATED             SIZE
    bemorerandomcom_api         latest      9483181fd50d        10 minutes ago      643.2 MB

    $ docker ps -a
    CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS                     PORTS                    NAMES
    5a6c2e69997d        bemorerandomcom_api     "/bin/sh -c 'java -cp"   6 minutes ago       Exited (1) 6 minutes ago                            bemorerandomcom_api_1
    651122695d29        postgres                "/docker-entrypoint.s"   7 minutes ago       Up 6 minutes               5432/tcp                 bemorerandomcom_database_1

The image for my API service is `bemorerandomcom_api`. The container is the same, suffixed with `_1`. This is because Docker Compose has a mechanism for scaling containers up and down. If I want three of the same service running, I can instruct `docker-compose` to do that with the `scale` command.

Volumes work similarly.

    $ docker volume ls
    DRIVER              VOLUME NAME
    local               bemorerandomcom_postgresql

And, of course, networks are named in the same way. If you don't create an explicit netwokr, one named *default* is created for you.

    $ docker network ls
    NETWORK ID          NAME                      DRIVER
    62e7b7e044d9        bridge                    bridge
    d5f0b701f820        bemorerandomcom_default   bridge
    8dd7c2e2a1b3        none                      null
    c5a22fe8becc        host                      host

I have four networks. Three come out of the box—the default *bridge* network, the *host* network, which allows a container to share the host networking stack, and a null network named *none* which isolates a container from its peers. The fourth was created by Docker Compose, and is named *bemorerandomcom_default*. It's also a bridge network.

DNS resolution on a Docker bridge network allows you to use the container name for lookup, and Docker Compose creates a network alias that maps, for example, *database* to *bemorerandomcom_database_1*. These are simply abbreviations for a longer DNS name of the form `<container>.<network>`. And so we can look up our database in that form, which seems to work:

    $ docker run --rm -it --net=bemorerandomcom_default ubuntu bash
    root@f97a267c62ca:/# getent hosts database.bemorerandomcom_default
    172.18.0.2      database.bemorerandomcom_default
    root@f97a267c62ca:/# getent ahosts database.bemorerandomcom_default
    172.18.0.2      STREAM database.bemorerandomcom_default
    172.18.0.2      DGRAM
    172.18.0.2      RAW

This time round, the *ahosts* lookup works. It's not ideal, as we're encoding the project name into the Docker Compose file, but we can use that:

    services:
      api:
        build:
          context: .
          dockerfile: api.Dockerfile
        ports:
          - 8080:8080
        environment:
          - DB_HOST=database.bemorerandomcom_default
          - DB_NAME=bemorerandom
          - DB_USER=bemorerandom
          - DB_PASSWORD
        depends_on:
          - database

The important line is here:

          - DB_HOST=database.bemorerandomcom_default

Now let's start it up.

    $ docker-compose up
    ...
    api_1      | I 0313 19:26:06.990 THREAD1: An exception was caught and reported.
    Message: org.postgresql.util.PSQLException: FATAL: role "bemorerandom" does not exist
    ...
    api_1      | Exception thrown in main on startup
    bemorerandomcom_api_1 exited with code 1

## Containing Scripts

Oh, wonderful. We forgot to port the database initialisation. It turns out we can't get rid of that script completely. In order to have Docker Compose spin it up with everything else, we'll need to put it into a container, just like everything else.

Let's give it its own directory, *init-db*, and create a Dockerfile:

    FROM postgres
    WORKDIR /app
    COPY * ./
    CMD ./init-db.sh

Simplest Dockerfile ever, right? We're using the `postgres` image so we can still use `psql` in the script, except now we need to talk to another container. Telling `psql` where the database instance lives is as simple as passing it the `-h` and `-p` switches for the host and port respectively. Our commands will look the same, but our `$PSQL` variable now looks like this:

    PSQL="psql -h $DB_HOST -p $DB_PORT -U postgres -At"

Rather than hard-coding the database information, we'll pass them in through environment variables.

Now we can add it to the Docker Compose file:

    services:
      ...
      init-db:
        build: init-db
        environment:
          - DB_HOST=database
          - DB_NAME=bemorerandom
          - DB_USER=bemorerandom
          - DB_PASSWORD
        depends_on:
          - database

Right. Let's try again.

    $ docker-compose up
    Creating volume "bemorerandomcom_postgresql" with default driver
    Creating bemorerandomcom_database_1
    Creating bemorerandomcom_init-db_1
    Creating bemorerandomcom_api_1
    Attaching to bemorerandomcom_database_1, bemorerandomcom_init-db_1, bemorerandomcom_api_1
    database_1 | LOG:  database system was shut down at 2016-03-13 19:33:30 UTC
    init-db_1  | Created the PostgreSQL user bemorerandom.
    database_1 | LOG:  MultiXact member wraparound protections are now enabled
    init-db_1  | CREATE ROLE
    database_1 | LOG:  database system is ready to accept connections
    database_1 | LOG:  autovacuum launcher started
    init-db_1  | CREATE DATABASE
    init-db_1  | Created the PostgreSQL database bemorerandom.
    bemorerandomcom_init-db_1 exited with code 0
    ...

It's a bit interspersed, but we can see that the role and the database were created, and then the container finished. Next time, it'll just exit immediately.

    ...
    api_1      | INF ApiServerMain$            http server started on port: 8080
    api_1      | INF ApiServerMain$            Enabling health endpoint on port 9990
    api_1      | INF ApiServerMain$            App started.
    api_1      | INF ApiServerMain$            Startup complete, server ready.

And we're up! Sweet. Let's test it.

    $ http $(docker-machine ip):8080/xkcd
    HTTP/1.1 200 OK
    Content-Encoding: gzip
    Content-Length: 101
    Content-Type: application/json;charset=utf-8

    {
        "attribution": {
            "name": "xkcd",
            "uri": "https://xkcd.com/221/"
        },
        "random": {
            "number": 4
        }
    }

Excellent. By using Docker Compose to manage our containers, we can worry less about *how* to start them and more about *what* they are. If we start it in daemon mode with `docker-compose up -d`, they'll run in the background, and we can simply rebuild and recreate them as necessary:

    $ docker-compose build && docker-compose up -d

If we add new containers or change the way things need to be built, that'll still work. It just goes into the *docker-compose.yml* file, versioned with everything else. I love my shell scripts, but I'd still much rather that things worked well without them.
