---
title: "Docker, Part Nine: Scripted Deployment"
date: 2016-03-14T08:01:32Z
---

We left off [more than a week ago][Docker, Part Eight: Turn Up The Volume] with an introduction to Docker volumes (amended in [part eight and a half][Docker, Part Eight and a Half: docker volume]), which showed how to persist data across container restarts and upgrades. By the end of it, we could start [the bemorerandom.com API service][bemorerandom.com] and its database with just a few commands:

    $ docker network create bemorerandom

    $ docker volume create --name=bemorerandom-postgresql

    $ docker run \
        -d \
        --name=bemorerandom-postgresql \
        --net=bemorerandom \
        -v bemorerandom-postgresql:/var/lib/postgresql/data \
        postgres

    $ docker exec -it bemorerandom-postgresql \
        createuser -U postgres -P bemorerandom
    $ docker exec -it bemorerandom-postgresql \
        createdb -U postgres -O bemorerandom bemorerandom

    $ docker run \
        -d \
        --name=bemorerandom-api \
        -p 8080:8080 \
        --net=bemorerandom \
        -e DB_URL=jdbc:postgresql://bemorerandom-postgresql.bemorerandom/bemorerandom \
        -e DB_USER=bemorerandom \
        -e DB_PASSWORD=<password> \
        samirtalwar/bemorerandom.com-api

Seven commands is not bad, but I'd prefer to have one—a script that handles all seven. But there's an issue: some of them only need to be run once, and some need to be run each time we want to restart the services. Specifically, we only need to create the network and PostgreSQL volume once, and likewise with the PostgreSQL database.

Let's start with the volume, because that's easy. It turns out that creating a volume twice with the same name is totally fine; it's an idempotent operation. So that can just be run over and over again.

Second is the network. That's not so trivial, unfortunately. Before we create it, we should ask Docker whether it exists already. We can use the `docker network ls` command to do so:

    $ docker network ls
    NETWORK ID          NAME                DRIVER
    02d6ee72718f        bemorerandom        bridge

By passing a filter and switching it to quiet mode, we can get it to output the network ID if it exists, or nothing if it doesn't.

    $ docker network ls --filter=name=bemorerandom -q
    02d6ee72718f

We can then easily use this output to determine whether we should create the network.

    if [[ -z "$(docker network ls --filter=name=bemorerandom -q)" ]]; then
        docker network create bemorerandom
    fi

Next up is the `createuser` command. There's two problems there—firstly, we can't create the user twice, and secondly, the password is supplied through user input on the terminal. Let's tackle the second one first. By creating the user in SQL, we can supply the password.

    docker exec -it bemorerandom-postgresql \
        psql -U postgres -At \
            -c "CREATE USER bemorerandom WITH PASSWORD '$DB_PASSWORD'"

And the database, because it's nice to be consistent.

    docker exec -it bemorerandom-postgresql \
        psql -U postgres -At \
            -c "CREATE DATABASE bemorerandom WITH OWNER bemorerandom"

There's some duplication there. We can extract out the PSQL command itself, and just leave the actual SQL:

    PSQL='docker exec -it bemorerandom-postgresql psql -U postgres -At'
    $PSQL -c "CREATE USER bemorerandom WITH PASSWORD '$DB_PASSWORD'"
    $PSQL -c "CREATE DATABASE bemorerandom WITH OWNER bemorerandom"

Then we can use the same technique to determine whether we need to run these at all, asking PostgreSQL itself whether the user and database exist using SQL:

        if [[ -z "$($PSQL -c "SELECT usename FROM pg_user
                              WHERE usename = 'bemorerandom'")" ]]; then
        $PSQL -c "CREATE USER bemorerandom WITH PASSWORD '$DB_PASSWORD'"
    fi

    if [[ -z "$($PSQL -c "SELECT datname FROM pg_database
                          WHERE datname = 'bemorerandom'")" ]]; then
        $PSQL -c "CREATE DATABASE bemorerandom WITH OWNER $DB_USER"
    fi

As we're now scripting this, we need to be sure that the previous command has finished. Some of the commands only terminate after completing their work, but starting the PostgreSQL container in *detached* mode means that the command terminates after starting the container, not when the database is running. We need some way of waiting for PostgreSQL to start. The simplest way is just to issue a query repeatedly until it succeeds:

    while ! $PSQL -c 'SELECT 1' > /dev/null; do
        sleep 1
    done

Of course, we probably shouldn't wait forever. We can fail after 10 tries by decrementing a counter each time.

    retries=10
    while ! $PSQL -c 'SELECT 1' > /dev/null; do
        retries=$((retries - 1))
        if [[ $retries -eq 0 ]]; then
            echo >&2 "PostgreSQL is not responding"
            exit 1
        fi
        sleep 1
    done

String that all together, and we have a script for starting up all the relevant parts of our application. Adding `set -e` to the top makes sure that the script terminates immediately if any part fails.

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

The only thing we're not doing is checking whether the containers already exist before starting them, which I'd like to leave as an exercise for the reader.

So. That's a long script. It's not too complicated, but it does a lot of different things some of the time, and it's not clear why everything has to happen and in that order. Tomorrow, we'll take a look at a much more declarative way of doing the same thing with *Docker Compose*.

[Docker, Part Eight: Turn Up The Volume]: http://monospacedmonologues.com/post/140436373509/docker-part-eight-turn-up-the-volume
[Docker, Part Eight and a Half: docker volume]: http://monospacedmonologues.com/post/140618924626/docker-part-eight-and-a-half-docker-volume
[bemorerandom.com]: https://github.com/SamirTalwar/bemorerandom.com
