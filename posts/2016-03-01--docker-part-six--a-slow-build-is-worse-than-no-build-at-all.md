# Docker, Part Six: A Slow Build Is Worse Than No Build At All

A 22-line Dockerfile is all you need to create an image that runs a Java application with Maven.

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

It's not too bad—pretty readable. However, it has a major issue: it's ridiculously slow. It takes about five to ten minutes to run on my machine, as it has to download all the dependencies from scratch every time. It even runs the tests too, which is mostly pointless—I wouldn't be building a new image if I hadn't tested the thing.

Let's see if we can improve it a little.

## Structure the Dockerfile

The first thing we can do is force Maven to download all dependencies before we copy the source files over. Just like we did with *google.rb*, by running `bundle install` beforehand copying the source file over, we can run `mvn dependency:resolve`:

    WORKDIR /app
    COPY pom.xml /app/pom.xml
    COPY api/pom.xml /app/api/pom.xml
    RUN mvn dependency:resolve

    COPY api/src /app/api/src
    RUN mvn package

Next, we can skip the tests.

    RUN mvn package -DskipTests=true

If we do want to run the tests in Docker (and there are advantages to doing so—for example, it ensures that we test in the same environment as we run), then we can do that from the built image by replacing the `exec:java` command with `verify`:

    $ docker run --rm -it samirtalwar/bemorerandom.com verify

As long as we stick to changing the stuff inside `src`, this should be grand. However, as soon as we change the dependencies, cue another ten minutes of downloading the Interwebs.

## Stop Downloading the World

Unfortunately, this is where things get complicated. We can't easily inject extra information, such as a local Maven cache, into the `docker build` process—it's not as flexible as just running containers. We could disassemble it back into running a container and then `docker commit`-ing it as an image, but that'd be one complicated shell script, and I'm enjoying the simplicity of a build file.

One way to solve this problem is to run your own caching proxy on your local network. This could be a caching reverse proxy such as [Varnish][] or [Squid][], or you could run your own Maven repository (replace "Maven" with "RubyGems", "NPM", etc. as necessary) that proxies the central repository. The Maven website even considers this a "best practice", and [recommends a few repository managers that'll do the job][Maven - Repository Management]—at the time of writing, [Apache Archiva][], [JFrog Artifactory][] and [Sonatype Nexus][].

[Squid]: http://www.squid-cache.org/
[Varnish]: https://www.varnish-cache.org/
[Maven - Repository Management]: https://maven.apache.org/repository-management.html
[Apache Archiva]: https://archiva.apache.org/
[JFrog Artifactory]: https://www.jfrog.com/open-source/
[Sonatype Nexus]: http://www.sonatype.org/nexus/go/

So, let's configure one of those. We can run it as a Docker container if we like, but we need to do it properly, with a hostname that is fixed for the local network at the least—otherwise there's no chance of the build container finding it.

I decided to go with Artifactory because I've used it before (and because I spent half an hour trying and failing to make Sonatype Nexus work). I tend to float around London a lot, so the only local network I have is are the virtual networks I create on my own laptop. So I found a [first-party Docker image][Artifactory: Running with Docker] and followed the instructions. About two minutes later, I had it running on my machine.

[Artifactory: Running with Docker]: https://www.jfrog.com/confluence/display/RTF/Running+with+Docker

Next, I configured Maven to treat it as a repository, using the *~/.m2/settings.xml* file. It was running on port 8081 with the same port forwarded to the host, so I used my Docker Machine IP address to do this. However, for the build, I copied a *settings.xml* file that used the special IP address *172.17.0.1*. This IP address is always the Docker host, as far as the containers are concerned. The host sets up its own subnet to communicate with containers and allow them to communicate easily with each other (which we'll talk about soon), with IP adresses in the 172.17.0.0/16 range. As of Docker 1.9, the IP address of the host is the first one in that range. (It used to be 172.17.42.1 for some reason—when they changed it, they broke *everything* at my last client.)

Next, I configured Artifactory to proxy both Maven Central and Twitter's own Maven repository, with Twitter's ranking first. witter have some of their stuff on both, and only their own works. */me grumbles a lot*

The first time I ran the build after this, it was even slower. You can imagine that a proxy server discovering the remote repositories for the first time would be. The second time, though, it was super-fast.

## Design For Repeatability

Because Docker's build process often happens in a vacuum, designing your environment so that everything is easily repeatable is paramount. We can get some of the way by restructuring the Dockerfile, but that only gets us so far. The rest of the work is often in making sure that the expensive stuff becomes cheap.

I don't know about you, but if my build is expensive, then I spend more time making coffee than I do in front of my computer. Keeping that build process fast is paramount to keeping me focused. It's not just the time it takes that can be wasted, but the time it takes to remember what I'm doing, sit back down and get on with things again. Context-switching isn't cheap, so if I can keep myself from doing it, I save a lot of time.

I'm stil not totally happy with this. Currently, we're shipping an image with all of the source code as well as the binaries, which is a bit strange. I can deal with it though, as it means I can crack on with running my service. Tomorrow we'll look at hooking it up to a database, and what containers mean for persistent data.
