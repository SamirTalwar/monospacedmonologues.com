---
title: "Docker, Part Four: Repeating Yourself"
date: 2016-02-25T08:00:40Z
---

Yesterday we made a Docker image that packages a simple Ruby application. However, recreating that image each time the application changed quickly became tiresome. Today we're going to see how to automate that.

Here's the application, in all its glory.

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

You'll recall that yesterday we performed the following steps:

  1. We created a container from the `ruby` base image.
  2. We then installed the `nokogiri` gem.
  3. We created a directory called `/app`.
  4. We changed the working directory to `/app`.
  5. We copied the *google.rb* file into the container.
  6. We made *google.rb* executable.
  7. We committed the container, setting the entry point to `./google.rb`.

Conveniently, Docker allows us to script all that using something called a *Dockerfile*.

## Script Your Image

Create a new file called *Dockerfile* in the same directory as your *google.rb* file. All we're going to do is transcribe the above steps into a specific language:

    FROM ruby
    RUN gem install nokogiri
    RUN mkdir /app
    WORKDIR /app
    COPY google.rb google.rb
    RUN chmod +x google.rb
    ENTRYPOINT ["./google.rb"]

Seven steps, using the Dockerfile language. You can see that some commands have been directly transplanted in, prefixed with the `RUN` directive. However, some don't have equivalent command-line invocations. `FROM` is always the first directive, and tells Docker where to start from. `WORKDIR` changes the working directory, which might seem like another way of saying `RUN cd /app`, but isn't necessarily, as `cd` is a shell function, not a command in its own right. `COPY` copies a file from the host to the container, which solves the problem we had yesterday. And finally, `ENTRYPOINT`, which we saw in the `docker commit` instruction, sets the entry point of the new image.

Let's build an image. In the same directory, run the following:

    $ docker build --tag=google .
    Sending build context to Docker daemon  68.1 kB
    Step 1 : FROM ruby
     ---> f90e47a6a135
    Step 2 : RUN gem install nokogiri
     ---> Running in 67330cbab921
    Successfully installed mini_portile2-2.0.0
    Building native extensions.  This could take a while...
    Successfully installed nokogiri-1.6.7.2
    2 gems installed
     ---> d782b5f00147
    Removing intermediate container 67330cbab921
    Step 3 : RUN mkdir /app
     ---> Running in 0dcd6ab5c818
     ---> 46dc3a0525be
    Removing intermediate container 0dcd6ab5c818
    Step 4 : WORKDIR /app
     ---> Running in 1f981dbad94b
     ---> 2016cc3db554
    Removing intermediate container 1f981dbad94b
    Step 5 : COPY google.rb google.rb
     ---> 94546d2356ef
    Removing intermediate container b9729a9d5d88
    Step 6 : RUN chmod +x google.rb
     ---> Running in 9d4744a69370
     ---> 7a5fbca425f2
    Removing intermediate container 9d4744a69370
    Step 7 : ENTRYPOINT ./google.rb
     ---> Running in a02df2628cd2
     ---> 94f57058e065
    Removing intermediate container a02df2628cd2
    Successfully built 94f57058e065

We can see that it did indeed run seven steps, culminating in image `94f57058e065`. By running `docker images`, I can confirm that that really has been tagged as `google`:

    $ docker images
    REPOSITORY                         TAG                 IMAGE ID            CREATED             SIZE
    google                             latest              94f57058e065        2 minutes ago       758.6 MB

Let's decompose one of those steps in more detail. Here's step 2 again:

    Step 2 : RUN gem install nokogiri
     ---> Running in 67330cbab921
    Successfully installed mini_portile2-2.0.0
    Building native extensions.  This could take a while...
    Successfully installed nokogiri-1.6.7.2
    2 gems installed
     ---> d782b5f00147
    Removing intermediate container 67330cbab921

`RUN` simply passes the command as a string to the user's default shell. We can see here that a container, `67330cbab921`, is created for this operation. Nokogiri is built and installed, which results in a new image, `d782b5f00147`. Finally, the container is removed, leaving us with an image, and the next step proceeds by creating a container from that image.

You may remember from yesterday that we created containers from images by running commands, and then *committed* those containers as images after modifying the file system. `docker build` simply automates that process, committing after every directive and spawning a new container for the next one.

## Change Fast

Interestingly, because we have an image after each line, modifying the app and rebuilding won't take as long as rebuilding from scratch. Because all the images are stored in the local image cache, `docker build` will recognise when a command has already been run on a parent image and simply reuse the image from the cache. This means that if I were to change the application, it will only change things from step 5 onwards; step 4 and above will re-use images from the cache. This is why I've structured my Dockerfile to install the dependencies straight away—by doing so, I don't have to wait for them to install on rebuild.

    $ docker build --tag=google .
    Sending build context to Docker daemon  68.1 kB
    Step 1 : FROM ruby
     ---> f90e47a6a135
    Step 2 : RUN gem install nokogiri
     ---> Using cache
     ---> d782b5f00147
    Step 3 : RUN mkdir /app
     ---> Using cache
     ---> 46dc3a0525be
    Step 4 : WORKDIR /app
     ---> Using cache
     ---> 2016cc3db554
    Step 5 : COPY google.rb google.rb
     ---> fd6ece098348
    Removing intermediate container 1d251e09a7e4
    Step 6 : RUN chmod +x google.rb
     ---> Running in d2ac2ee277bf
     ---> 401f56e40fc5
    Removing intermediate container d2ac2ee277bf
    Step 7 : ENTRYPOINT ./google.rb
     ---> Running in a098e8dc9b01
     ---> a7add432dbb5
    Removing intermediate container a098e8dc9b01
    Successfully built a7add432dbb5

Notice that the first four steps don't create intermediate containers; they simply use the cache. The first time round, it took thirty seconds or so for Nokogiri to install on my machine. This time, the entire build took less than half a second.

So, let's run it.

    $ docker run --rm google pizza
    Local business results for pizza
    Pizza Delivery, Restaurants and Takeaway | Order Online with Pizza ...
    The 10 Best Pizza Places in London - TripAdvisor
    The best pizza in London – from sourdough to by-the-slice ...
    Pizza London - Best pizzas in London - Time Out
    Best pizza in London - NY Fold, Pizza Pilgrims and Bocconcino ...
    Images for pizza
    Pizza East | Home - London
    Pizza East | Kentish Town - London
    Domino's Pizza: Homepage
    London's Best Pizza Restaurants | Londonist - London

## Generalise

It's good practice in the Ruby world to provide a *Gemfile* with a list of dependencies. This is used by a tool called *bundler* to install dependencies and ensure everyone is running the same version. We won't worry about dependency versions for now, but it's still good practice. Let's make one.

    source 'https://rubygems.org'

    gem 'nokogiri'

Simple, isn't it? Save that in a file called *Gemfile* in the same directory as everything else.

Now we need to use that file in our Docker build process. Change the Dockerfile to the following:

    FROM ruby

    RUN mkdir /app
    WORKDIR /app

    COPY Gemfile Gemfile
    RUN bundle install

    COPY google.rb google.rb
    RUN chmod +x google.rb
    ENTRYPOINT ["./google.rb"]

Notice I've spaced it out a bit. That's not necessary, but it does make it readable. You can also add comments by using the `#` character if you like.

This is more general. We copy the Gemfile over to the container, then run `bundle install` to install all dependencies. The first time we run this, we won't be able to make use of the cache, so it'll take a little while to install Nokogiri again. However, the second time we run it, things will be the same as before. As long as *Gemfile* doesn't change, Docker will recognise that and ensure that the cache is reused. By copying *google.rb* to the container *after* running `bundle install`, we ensure that changing the application file doesn't break the cache. Structuring Dockerfiles can often become a black art, and it's worth experimenting to find the right combination to save yourself time in the long run.

## Don't Stop Now

I really recommend reading the [Dockerfile reference][] to find out more about the directives available and what you can do, as we've just scratched the surface here. Next week we'll be looking at hosting services, rather than one-shot applications, and so we'll take a look at the `EXPOSE` directive for exposing your service's ports. Before that, though, I'd like to leave you with a bonus one. Add this line to the end of your Dockerfile:

    CMD ["docker"]

If you don't provide a command to run after the image name in your `docker run` invocation, it will default to the commands specified by the `CMD` directive.

    $ docker run --rm google
    Docker - Build, Ship, and Run Any App, Anywhere
    Docker (software) - Wikipedia, the free encyclopedia
    News for docker
    GitHub - docker/docker: Docker - the open-source application ...
    What is Docker and why is it so darn popular? | ZDNet
    What is Docker? | Opensource.com
    Containers everywhere! Getting started with Docker • The Register

Often, we set this to the command to be run in the container by default—like `irb` for the `ruby` image. However, if we set an entry point, the two are concatenated, just as when providing a command to `docker run`. In these cases, we usually set the command to `--help` or something useful so that starting a container with no arguments prints some useful output. This time, though, I just felt like providing a default, and what better than Docker itself?

[Dockerfile reference]: https://docs.docker.com/engine/reference/builder/
