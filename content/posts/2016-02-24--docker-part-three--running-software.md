---
title: "Docker, Part Three: Running Software"
slug: docker-part-three--running-software
date: 2016-02-24T08:00:28Z
aliases:
  - /post/139899978331/docker-part-three-running-software
---

We've played with "Hello, World!" long enough. Let's do something useful.

Hello, World is a simple example, but containers can wrap any software you like. This becomes especially useful when creating software that requires a lot of runtime dependencies. For example, your average command-line Ruby program probably depends on a bunch of libraries (gems), and shipping them is a pain. We don't just have to ship the application, but the gems and the Ruby interpreter too. The alternative is to just ship the code and the `Gemfile`, and hope the remote location has the correct version of Ruby, Internet access to download all the gems, any required native code (for example, the Nokogiri gem requires a C compiler), and a whole load of prayer.

So let's package one up. How about a Ruby application that Googles from the command line?

<!--more-->

## Make A Thing

We're going to need the library I mentioned earlier, Nokogiri, for this one. Nokogiri is a very fast XML parser that allows you to search it using XPath and CSS queries, which makes life very easy when scraping the web.

So, the first thing we need to do is grab the HTML and parse it:

    #!/usr/bin/env ruby

    require 'cgi'
    require 'nokogiri'
    require 'open-uri'

    query = ARGV[0]
    html = open("https://google.com/search?q=#{CGI.escape(query)}") { |io|
      Nokogiri::HTML(io)
    }

If you `puts` the `html` variable you'll get a whole stream of noise out the end. Google's HTML is not pretty. However, by opening up the page and inspecting it, we can see that the actual search results each live in an element with `class="g"`. (This may have changed by the time you read this. If so, I apologise for not being up-to-date.)

    results = html.css('.g')

Next, we need the headlines. They're in `<h3>` tags, so that's easy. The only thing we need to be careful about is that they might not exist.

    results.each do |result|
      header = result.at_css('h3')
      puts header.text if header
    end

I'll leave it as an exercise for you, the reader, to figure out how to grab the links. Google proxies all of them, so it's not as easy as you might think. When you're done (or if you don't feel like it), save it in a file named `google.rb` in a new directory… or just [download it from the gist][google.rb].

[google.rb]: https://gist.github.com/SamirTalwar/f0fd3b23fb98a3ecf197

So, we have an application. All you need to do is ship it with instructions to install Ruby and Nokogiri. Or. OR. We could containerise it.

## Container The Thing

So let's start a new container. We'll use the official `ruby` image as the base because, well, it's a good place to start.

    $ docker run -it ruby bash

We need to specify to run Bash explicitly because this image defaults to starting IRB, the Ruby REPL. That's really useful for small experiments but not very helpful if you need to install a gem first.

The `ruby` image comes with RubyGems, the Ruby library package manager, so we're good to go. Let's install Nokogiri.

    $ gem install nokogiri
    Fetching gem metadata from https://rubygems.org/.........
    Fetching version metadata from https://rubygems.org/..
    Resolving dependencies...
    Installing mini_portile2 2.0.0
    Using bundler 1.11.2
    Installing nokogiri 1.6.7.2 with native extensions
    Bundle complete! 1 Gemfile dependency, 3 gems now installed.
    Bundled gems are installed into /usr/local/bundle.

Great. That took a while though. We don't want to do that again. Let's save it as an image. Spin up another terminal and leave that one going, then find out what your container's called:

    $ docker ps
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    203f19f6f4ab        b46f630bbbd9        "bash"              3 minutes ago       Up 3 minutes                            serene_aryabhata

Mine's called `serene_aryabhata`, but you should use the name of your own.

We're going to _commit_ this container as an image. This saves the file system as an image. I'm going to call this image `google_gems`, as it's got the gem dependencies for my `google` program.

    $ docker commit serene_aryabhata google_gems

If we were to create a new container from the image, it would start the same command we used to start the original container—`bash`, in our case. Give it a try.

    $ docker run --rm -it google_gems

You should see a Bash prompt. This is a separate container that is functionally equivalent to the other container we have running. It's really easy to fork containers by committing, which becomes very useful when creating base images such as the `ruby` image we started with.

Close it down by typing `exit`–we don't need it. Let's go back to the other container. We need to add the `google.rb` file we created earlier. It's not easy to copy files into containers, but as it's so small, we can just copy the text.

First, let's make a place for it. We have an entire file system available to us. You should be in the root directory, but even if you're not, you can list it with `ls -al /`.

    $ ls -al /
    total 76
    drwxr-xr-x  57 root root 4096 Feb 23 22:15 .
    drwxr-xr-x  57 root root 4096 Feb 23 22:15 ..
    -rwxr-xr-x   1 root root    0 Feb 23 22:15 .dockerenv
    -rwxr-xr-x   1 root root    0 Feb 23 22:15 .dockerinit
    drwxr-xr-x   2 root root 4096 Feb 16 21:40 bin
    drwxr-xr-x   2 root root 4096 Jan  6 15:18 boot
    drwxr-xr-x   5 root root  380 Feb 23 22:15 dev
    drwxr-xr-x  62 root root 4096 Feb 23 22:15 etc
    drwxr-xr-x   2 root root 4096 Jan  6 15:18 home
    drwxr-xr-x  12 root root 4096 Feb 16 21:41 lib
    drwxr-xr-x   2 root root 4096 Feb 16 17:57 lib64
    drwxr-xr-x   2 root root 4096 Feb 16 17:56 media
    drwxr-xr-x   2 root root 4096 Feb 16 17:56 mnt
    drwxr-xr-x   2 root root 4096 Feb 16 17:56 opt
    dr-xr-xr-x 127 root root    0 Feb 23 22:15 proc
    drwx------   5 root root 4096 Feb 17 18:00 root
    drwxr-xr-x   3 root root 4096 Feb 16 17:56 run
    drwxr-xr-x   2 root root 4096 Feb 16 17:57 sbin
    drwxr-xr-x   2 root root 4096 Feb 16 17:56 srv
    dr-xr-xr-x  13 root root    0 Feb 23 22:15 sys
    drwxrwxrwt   2 root root 4096 Feb 23 21:56 tmp
    drwxr-xr-x  36 root root 4096 Feb 23 21:55 usr
    drwxr-xr-x  23 root root 4096 Feb 17 17:56 var

(Look at those timestamps. I'm cutting this fine.)

Let's put our application files in `/app`. We need to create it first, of course.

    $ mkdir /app
    $ cd /app

Now we can copy the contents of `google.rb`.

    $ cat > google.rb

You may have noticed that nothing happened. This is because `cat` is waiting for your input. Paste the contents of the file. Make sure you end with a new line, then press _Ctrl+D_ to send the end-of-file marker and signify to `cat` we're done. You can verify that you did it correctly by typing `cat google.rb` to print the contents again.

Next, let's make it executable.

    $ chmod +x google.rb

Brilliant. We have everything we need to create our final image. Let's commit it, this time with the tag `google`. Flip over to your other terminal and type:

    $ docker commit --change='ENTRYPOINT ["./google.rb"]' serene_aryabhata google

See that? We didn't just commit, but we instructed Docker to make a change to the image as it committed. In this case, we instructed it to set the _entry point_ of the Docker image to be our script, `./google.rb`. This means that any extra arguments passed to the `run` command will actually be passed to that entry point. Unlike the `ruby` image, which allowed us to override it and specify `bash` as our starting program, our `google` image won't.

## Run The Thing

So let's try it.

    $ docker run --rm google badgers
    Images for badgers
    Badger - Wikipedia, the free encyclopedia
    Amazing facts about badgers | OneKind
    Badger Trust - Home
    Top ten facts about badgers you never knew | Top 10 Facts | Life ...
    Badgers | Environment | The Guardian
    London's badgers | Greenspace Information for Greater London
    London Badgers? - Wild About Britain
    Scottish Badgers - Promoting the study, conservation and protection ...
    London Badgers Basketball - Facebook

Perfect. I don't even have Ruby installed on this computer, and I can run this Ruby application without issue. I can save the image as a file and ship it to another computer, or even push it up to the Docker Hub to share it with others.

In fact, I did. Try it.

    $ docker run --rm samirtalwar/google koalas

## Change The Thing

Because we committed our `google_gems` image, changing the application is easy. We can simply run a new container from that image, paste in a new script and commit with the `google` tag again. Docker doesn't allow duplicate tags, so it'll simply remove the tag from the old image before placing it upon the new one.

We can even make it simpler to copy the file in, by side-loading a command in the same container using `docker exec`. This command will write the file from STDIN, then pipe the file in from the host:

    $ docker exec -i amazing_bassi bash -c 'cat > /app/google.rb' < google.rb

(This time round, my container was called `amazing_bassi`. Go figure.)

So when you finally figure out how to extract the links from Google, you can change it really easily.

## Repeat The Thing

You'll find that even though you have a decent process for copying files into the container and committing them, it's not exactly designed to be repeatable. After all, anything repeatable should be automatable, and this is definitely not that. Fortunately, the Docker folk have solved this one with _Dockerfiles_, which we'll be talking about tomorrow.
