---
title: "Docker, Part Five: Let's Make A Website"
slug: docker-part-five--lets-make-a-website
date: 2016-02-29T08:00:32Z
aliases:
  - /post/140202783219/docker-part-five-lets-make-a-website
---

OK, the weekend has happened and I can't remember where we left off. So let's recap, as much for my sake as for yours.

<!--more-->

We had this program, *google.rb*, that Googled:

    #!/usr/bin/env ruby

    require 'cgi'
    require 'nokogiri'
    require 'open-uri'

    query = ARGV[0]
    html = open("https://google.com/search?q=#{CGI.escape(query)}") { |io|
      Nokogiri::HTML(io)
    }
    results = html.css('.g')
    results.each do |result|
      header = result.at_css('h3')
      puts header.text if header
    end

A *Gemfile* that specified its dependencies:

    source 'https://rubygems.org'

    gem 'nokogiri'

and a *Dockerfile* that told Docker how to build an image that held it all together:

    FROM ruby

    RUN mkdir /app
    WORKDIR /app

    COPY Gemfile Gemfile
    RUN bundle install

    COPY google.rb google.rb
    RUN chmod +x google.rb
    ENTRYPOINT ["./google.rb"]

These are all available as [a gist][google.rb] if you want to make cloning it locally easier.

[google.rb]: https://gist.github.com/SamirTalwar/f0fd3b23fb98a3ecf197

Once we have these three files, we can build a Docker image and run it:

    $ docker build --tag=google .
    ...
    $ docker run --rm google 'eggs benedict'
    Gordon's eggs Benedict | BBC Good Food
    Eggs Benedict with smoked salmon & chives | BBC Good Food
    Super Eggs Benedict | Egg Recipes | Jamie Oliver
    Images for eggs benedict
    Eggs Benedict - Wikipedia, the free encyclopedia
    BBC Food - Recipes - Eggs Benedict
    BBC Food - Recipes - Eggs Benedict
    Eggs Benedict - English - Recipes - from Delia Online
    Eggs benedict recipe - Telegraph
    Best Eggs Benedict Recipe - Delicious Techniques - No Recipes

Simples. Of course, not many of us are shipping command-line applications to users, and even if we were, we can't always expect those users to have Docker installed and running. Where containerisation shines is when we have control of the computers we deploy to—for example, when we're creating a website.

So let's write one. I just bought the domain, [*bemorerandom.com*][bemorerandom.com], and I want to spin up a web service that speaks JSON. This time round, I'm going to use Scala, not Ruby.

[bemorerandom.com]: https://bemorerandom.com/

---

OK, it's a few hours later. I've figured how to make [Finatra][] work[^Finatra and Maven] and created a very simple web service. It's not hosted yet, but [it's real][bemorerandom.com repository] and I can run it locally. It generates random numbers.

[^Finatra and Maven]: This was ridiculous. It turns out Finatra lives on its own Maven repository which has somewhat *relaxed* rules… in that the dependency chains are broken, so you need to express dependencies yourself. This is documented exactly nowhere. Remind me to write a post on how to do this.

[Finatra]: https://twitter.github.io/finatra/
[bemorerandom.com repository]: https://github.com/SamirTalwar/bemorerandom.com

Currently, it has one endpoint. When I run it locally and hit `http://localhost:8080/xkcd`, it returns this:

    {
      "random": {
        "number": 4
      },
      "documentation": {
        "uri": "https://xkcd.com/221/"
      }
    }

Truly, a better random number generator has never been seen.

So. We have a web service. Let's package it up. As this is a Scala application, I'm going to choose OpenJDK 8 as my base. Azul Systems provide [a Docker image][azul/zulu-openjdk] with their own, certified version of OpenJDK, [Zulu][], which is a little more stable than Docker's official Java image, so I'm going to use that.

[azul/zulu-openjdk]: https://hub.docker.com/r/azul/zulu-openjdk/
[Zulu]: https://www.azul.com/products/zulu/

So, I got to writing a Dockerfile (named *api.Dockerfile*, because it's specific to my *api* subproject). Here's what I ended up with:

    FROM azul/zulu-openjdk:8

    EXPOSE 8080

    RUN apt-get update && apt-get install -y curl

    ENV MAVEN_VERSION 3.3.9
    ENV PATH /opt/maven/bin:$PATH

    RUN mkdir /opt/maven
    RUN curl -fsSL "http://mirror.ox.ac.uk/sites/rsync.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" > /opt/maven/apache-maven-bin.tar.gz
    RUN tar xf /opt/maven/apache-maven-bin.tar.gz -C /opt/maven --strip-components=1 \
        && rm /opt/maven/apache-maven-bin.tar.gz

    COPY pom.xml /app/pom.xml
    COPY api/pom.xml /app/api/pom.xml
    COPY api/src /app/api/src
    WORKDIR /app
    RUN mvn package

    ENTRYPOINT ["mvn", "--projects=api"]
    CMD ["exec:java"]

A lot of that is boilerplate. Let's go through it. In turn, we:

  1. "Expose" port 8080 to the outside world. This is a way of instructing an image to *declare* that a port is exposed, which means we can ask it to map all its ports. More on this in a bit.
  2. Install Maven. We need `curl` to download that, so the second line does that. The next batch downloads Maven (version 3.3.9, currently) and untars it to */opt/maven*.
  3. Copy the relevant files over—specifically, the *pom.xml* files, which instruct Maven on how to build my application, and the source code of the application itself.
  4. Build the application using `mvn package`.
  5. Finally, set up the image to run the following command on start, which instructs the "api" subproject to run itself as a Java application:

        mvn --projects=api exec:java

     We split the command into an entry point, Maven itself, tied to a subproject, which shouldn't change, and the command to be passed to Maven, which might well change. This means that we could, for example, use the same image to run the tests.

Right, time to build it:

    $ docker build --tag=samirtalwar/bemorerandom.com-api .

Cue about ten minutes of waiting around while Maven downloads the world. (Do not run this over a capped Internet connection. Seriously.) This is partially because the `package` Maven task depends on `test`, which means the tests have to run, which means all the test dependencies (and there are many) must be downloaded. As one of the tests starts the application, we even spend some time with it running before it's through.

Once it's done, we can run it:

    docker run -P --rm -it --name=bemorerandom.com-api samirtalwar/bemorerandom.com-api

And we have a web server! (Eventually, after Maven downloads the *exec* plugin, which wasn't needed until just now.) That `-P` tells Docker to forward all exposed ports to the Docker host, and we can ask Docker itself which port it was forwarded to:

    $ docker port bemorerandom.com-api
    8080/tcp -> 0.0.0.0:32781

Port 8080 on the container has been forwarded to port 32781 on the host. (If I wanted to fix the port, for example, to port 9000 on the host, then I'd use `-p 9000:8080` instead.)

So then, it's time to hit the web service. It looks to be working fine:

    $ http $(docker-machine ip):32781/xkcd
    HTTP/1.1 200 OK
    Content-Encoding: gzip
    Content-Length: 94
    Content-Type: application/json;charset=utf-8

    {
        "documentation": {
            "uri": "https://xkcd.com/221/"
        },
        "random": {
            "number": 4
        }
    }

So far, so good. Except I hate it.

Building this takes forever. Each time anything changes, it has to download all the dependencies again, taking over ten minutes on my poor ADSL connection, which runs through miles of copper wires that were installed in the reign of King Henry VIII before it reaches the nearest exchange at the other end of town. Tomorrow, we're going to look at ways to mitigate this problem.
