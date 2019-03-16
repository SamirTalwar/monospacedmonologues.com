---
title: "Localised dotfiles"
slug: localised-dotfiles
date: 2016-02-18T08:00:26Z
aliases:
  - /post/139532402881/localised-dotfiles
---

So you followed yesterday's guide to setting up your dotfiles repository. Now it's time to get your shell configuration in there.

If you're using Bash, you're in luck. Just move your `.bash_profile` to `dotfiles/bash_profile` and commit. Done and dusted. If you're using ZSH, well, you have to copy your `.zshrc`, `.zshenv`, `.zlogin`, `.zlogout` and `.zprofile`. That might take a while. It's OK. I'll wait.

<!--more-->

Or you could `cd` into your dotfiles directory, then copy and paste this:

    for file in zshrc zshenv zlogin zlogout zprofile; do
        if [[ -e ~/.$file ]]; then
            cp ~/.$file $PWD/$file
        fi
    done

Right. Done? Add the requisite lines to create the symlinks to your `init` script (and transform it into a `for` loop like the one above if you like), then run it.

Groovy. Don't commit yet.

Here's the problem. If you use those files at all, you probably have lots of different things all jumbled together. There's going to be some stuff that makes sense to share across computers and push online, and some stuff that's relatively secret—at least stuff you shouldn't be putting on GitHub.

Fortunately, we're dealing with shell scripts here. We can fix this. Let's pretend we're working with `.zshrc`, but this can apply to any file.

First of all, add a block to the bottom:

    if [[ -e ~/.zshrc.local ]]; then
        source ~/.zshrc.local
    fi

(Replace "`zshrc`" as necessary.)

Then move everything that you don't want to push up to the Interwebs into that file, `~/.zshrc.local`. It will be loaded at the end of your `.zshrc`. To give you an idea of what you might put in there, here's mine:

    eval "$(javav 8)"

    export DOCKER_TLS_VERIFY="1"
    export DOCKER_HOST="tcp://192.168.99.100:2376"
    export DOCKER_CERT_PATH="$HOME/.docker/machine/machines/default"
    export DOCKER_MACHINE_NAME="default"

    function awesome-client {
        cd /Users/samir/Work/AwesomeClient

        nvm use v4
        export NODE_ENV=development

        rvm use --create ruby@awesome-client

        local machine='awesome-client'
        if [[ $(docker-machine status $machine) != 'Running' ]] \
            || docker-machine start $machine
        eval "$(docker-machine env $machine)"
    }

That first line uses a home-grown script, [`javav`][javav], to add Java 8 to my `PATH`. The next four set up a connection to my Docker VM (using [Docker Machine][]). These are things that might not make any sense on another computer. I might, for example, not be using Docker, or using Linux, where that `javav` script doesn't work.

That last block is a function that sets up a working environment for one of my clients, _Awesome Client, PLC_. It moves to the right directory, sets up node.js and Ruby with the correct versions, and starts a Docker instance specifically for that project. This makes no sense on any machine but this one, and so here it goes.

I try to make an effort to keep this file as small as possible. `$PATH` manipulation that used to be in my `.zshenv.local` file is now in my [`.zshenv`][.zshenv] file, surrounded by `if` blocks when necessary. It's nice to have a split between private and public, though, and while this isn't the fanciest of tricks, simple works.

[javav]: https://github.com/SamirTalwar/fygm/blob/master/bin/mac/javav
[.zshenv]: https://github.com/SamirTalwar/fygm/blob/master/dotfiles/zshenv
[docker machine]: https://docs.docker.com/machine/overview/
