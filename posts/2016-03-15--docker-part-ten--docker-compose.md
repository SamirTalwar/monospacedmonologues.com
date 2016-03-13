# Docker, Part Ten: Docker Compose

Yesterday, we wrote a script to spin up all the various containers we need to start our application. Today, let's take a look at a better way to do all that without worrying too much about the intricacies of Bash scripting.

[Docker Compose][] is a tool for doing this sort of thing in a declarative fashion. You write a specification for what your application looks like, and Compose handles building and running it.

## Installation

First of all, check whether you've already installed Docker Compose. If you installed the Docker Toolbox, you should already have it. Try typing `docker-compose` on the command line. If you have it, you should see a handy usage guide. If not, time to install it. If you're using Docker Toolbox, [update to the latest version][Docker Toolbox]. On Mac OS with Homebrew, `brew install docker-compose` should cover you. And on Linux, [follow the installation guide][Install Docker Compose].

[Docker Compose]: https://docs.docker.com/compose/overview/
[Docker Toolbox]: https://www.docker.com/products/docker-toolbox
[Install Docker Compose]: https://docs.docker.com/compose/install/

## Converting to Docker Compose

Once you're confident it's installed, let's convert our script. Here it is again for reference.

    #!/bin/bash

    set -e

    if [[ -z "$(docker network ls --filter=name=bemorerandom -q)" ]]; then
        docker network create bemorerandom
    fi

    docker volume create --name=bemorerandom-postgresql

    docker run \
        -d \
        --name=bemorerandom-postgresql \
        --net=bemorerandom \
        -v bemorerandom-postgresql:/var/lib/postgresql/data \
        postgres

    PSQL='docker exec -it bemorerandom-postgresql psql -U postgres bemorerandom'

    retries=10
    while ! $PSQL -c 'SELECT 1' > /dev/null; do
        retries=$((retries - 1))
        if [[ $retries -eq 0 ]]; then
            echo >&2 "PostgreSQL is not responding"
            exit 1
        fi
        sleep 1
    done

    if [[ -z "$($PSQL -c "SELECT usename FROM pg_user
                          WHERE usename = 'bemorerandom'")" ]]; then
        $PSQL -c "CREATE USER bemorerandom WITH PASSWORD '$DB_PASSWORD'"
    fi

    if [[ -z "$($PSQL -c "SELECT datname FROM pg_database
                          WHERE datname = 'bemorerandom'")" ]]; then
        $PSQL -c "CREATE DATABASE bemorerandom WITH OWNER $DB_USER"
    fi

    docker run \
        -d \
        --name=bemorerandom-api \
        -p 8080:8080 \
        --net=bemorerandom \
        -e DB_URL=jdbc:postgresql://bemorerandom-postgresql.bemorerandom/bemorerandom \
        -e DB_USER=bemorerandom \
        -e DB_PASSWORD=<password> \
        samirtalwar/bemorerandom.com-api

As everything else depends on our database, we can convert that one first. Let's create a file named *docker-compose.yml* in the root directory of our project, with one *service*, our database:

    version: '2'

    services:
      database:
        image: postgres

(We're using version 2 of the Docker Compose syntax, which supports named volumes and networks.)

That's enough to start up a database. Let's try it:

    $ docker-compose up
    database_1 | The files belonging to this database system will be owned by user "postgres".
    database_1 | This user must also own the server process.
    database_1 |
    database_1 | The database cluster will be initialized with locale "en_US.utf8".
    database_1 | The default database encoding has accordingly been set to "UTF8".
    database_1 | The default text search configuration will be set to "english".
    database_1 |
    database_1 | Data page checksums are disabled.
    database_1 |
    database_1 | fixing permissions on existing directory /var/lib/postgresql/data ... ok
    database_1 | creating subdirectories ... ok
    database_1 | selecting default max_connections ... 100
    database_1 |
    database_1 | <... snip ...>
    database_1 |
    database_1 | PostgreSQL init process complete; ready for start up.
    database_1 |
    database_1 | LOG:  MultiXact member wraparound protections are now enabled
    database_1 | LOG:  database system is ready to accept connections
    database_1 | LOG:  autovacuum launcher started

We have a database! Press *Ctrl+C* to stop it.

Now, of course, we want to store that data in a named volume so that we don't lose it. Let's add that to the service:

    services:
      database:
        image: postgres
        volumes:
          - postgresql:/var/lib/postgresql/data

    volumes:
      postgresql: {}

Here, we're specifying we're creating a volume named `postgresql`. We don't need to give it any special parameters, so we can define an empty object as its value. (YAML is a superset of JSON, so any JSON syntax will work.) We then assign that volume as normal.

Here we can start to see how Docker Compose allows us to *declare* the structure of our application, rather than executing instructions sequentially. Bring up the application again, and we'll get slightly different output right at the top:

    Creating volume "bemorerandomcom_postgresql" with default driver

(We'll talk about that name in a bit.)

The API service is next. This one is a bit more intricate:

    services:
      api:
        build:
          context: .
          dockerfile: api.Dockerfile
        ports:
          - 8080:8080
        environment:
          - DB_HOST=database
          - DB_NAME=bemorerandom
          - DB_USER=bemorerandom
          - DB_PASSWORD
        depends_on:
          - database

Let's take that a piece at a time.

        build:
          context: .
          dockerfile: api.Dockerfile

Unlike the database, we need to build our own image here. To do this, instead of specifying an `image` property, we specify the directory to build and location of the Dockerfile. (If the Dockerfile were simply named *Dockerfile*, as is conventional, we could just write `build: .`.)

        ports:
          - 8080:8080

Next, we expose port `8080` externally, using the same port on the host. This is just like passing `-p 8080:8080` as arguments to `docker run`.

        environment:
          - DB_HOST=database
          - DB_NAME=bemorerandom
          - DB_USER=bemorerandom
          - DB_PASSWORD

We specify four arguments here: the database host, name, username and password. The first three are fixed, and the last is taken from the running environment. The `DB_HOST` is simply *database*, which is the name of the database service. Docker Compose creates a Docker network (named `default` with a prefix) for the application, which means that we can simply refer to other services by name and they'll be resolved.

        depends_on:
          - database

This service depends on the database, so this block tells Docker Compose that it should never be started without it. This means that `docker-compose up api` will bring up both the API service *and* the database.

Let's run it:

    $ docker-compose up
    Creating volume "bemorerandomcom_postgresql" with default driver
    Creating bemorerandomcom_database_1
    Building api
    Step 1 : FROM azul/zulu-openjdk:8
     ---> d4f03c7f130b
    Step 2 : EXPOSE 8080
     ---> Running in 096dacd22cb4
     ---> 41a82b35ff7d
    Removing intermediate container 096dacd22cb4
    Step 3 : RUN apt-get update && apt-get install -y curl
     ---> Running in 7d8b83b2f8ca
    ...
    Step 16 : CMD java -cp api/target/app.jar:api/target/dependency/\* com.bemorerandom.api.ApiServerMain
     ---> Running in 45e22378a3f6
     ---> 9483181fd50d
    Removing intermediate container 45e22378a3f6
    Successfully built 9483181fd50d
    Creating bemorerandomcom_api_1

You'll see that the API service image is automatically built. This is only done if one isn't already present, so if we change it, we'll need to remember to run `docker-compose build` first. After it's built, the service starts.

    Attaching to bemorerandomcom_database_1, bemorerandomcom_api_1
    database_1 | LOG:  database system was shut down at 2016-03-13 18:51:12 UTC
    database_1 | LOG:  MultiXact member wraparound protections are now enabled
    database_1 | LOG:  database system is ready to accept connections
    database_1 | LOG:  autovacuum launcher started
    ...
    api_1      | Mar 13, 2016 6:54:01 PM com.twitter.finagle.http.HttpMuxer$$anonfun$4 apply
    api_1      | INFO: HttpMuxer[/admin/metrics.json] = com.twitter.finagle.stats.MetricsExporter(<function1>)
    api_1      | Mar 13, 2016 6:54:01 PM com.twitter.finagle.http.HttpMuxer$$anonfun$4 apply
    api_1      | INFO: HttpMuxer[/admin/per_host_metrics.json] = com.twitter.finagle.stats.HostMetricsExporter(<function1>)
    api_1      | 2016-03-13 18:54:01,790 INF ApiServerMain$            Process started
    ...
    api_1      | I 0313 18:54:04.455 THREAD1: An exception was caught and reported. Message: java.net.UnknownHostException:
    database
    api_1      | org.flywaydb.core.api.FlywayException: Unable to obtain Jdbc connection from DataSource (jdbc:postgresql://
    database:5432/bemorerandom) for user 'bemorerandom': The connection attempt failed.
    ...
    api_1      | Caused by: java.net.UnknownHostException: database
    api_1      | Exception thrown in main on startup
    bemorerandomcom_api_1 exited with code 1

And crashes.

Unfortunately, due to something that looks like a bug in the Ubuntu image (though I'm not a good enough network engineer to be sure I haven't done something wrong myself), and therefore all its descendants including the Azul Systems JDK image, a certain kind of DNS resolution fails. We can prove this by running a container attached to the same network and making a couple of queries:

    root@c61890596067:/# getent hosts database
    172.18.0.2      database
    root@c61890596067:/# getent ahosts database
    root@c61890596067:/# getent ahostsv4 database
    172.18.0.2      STREAM database
    172.18.0.2      DGRAM
    172.18.0.2      RAW

When we query `ahosts`, we get nothing, and that, unfortunately, uses the same *libc* call as Java's `InetAddress.getByName` function. To get further into this, we're going to have to take a detour and talk about naming.

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

If we add new containers or change the way things need to be built, that'll still work. It just goes into the *docker-compose.yml* file, versioned with everything else.
