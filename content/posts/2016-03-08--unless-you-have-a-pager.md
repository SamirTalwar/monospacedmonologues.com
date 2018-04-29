---
title: "Unless You Have A $PAGER"
slug: unless-you-have-a-pager
date: 2016-03-08T08:00:39Z
---

I just found a bug in [SDKMAN!][] that you'll probably never see. It only manifested in my machine when I ran the test cases inside a Docker container.

SDKMAN! is a program that manages, well, SDKs. It started off as the Groovy Version Manager, or GVM, but now it can install multiple versions of Scala, Grails, SBT… you name it in the Java world, and it's there. You run it with the `sdk` command in your terminal.

<!--more-->

Anyway, `sdk list` is a command that lists all available "candidates" it can install. It's a bit more complicated than this, but it essentially boils down to:

    __sdkman_list_candidates {
        echo "$(curl -s "${SDKMAN_SERVICE}/candidates/list")" | ${PAGER-less}
    }

It just hits a URL on the Internet and pipes it to your `$PAGER`, or `less` if you don't have the variable set. `less` is on pretty much every computer, so it's a safe bet.

Except when it's not.

The Docker image, `java:8`, is pretty lightweight. It has Java on it, of course, and a bunch of system utilities, but a lot of fairly basic tooling is missing. `less` included. So when you try and run the SDKMAN! tests inside a Docker container (which is encouraged), one fails because there's no pager.

So I fixed it. Instead of `less`, I defaulted `$PAGER` to `$(which less)`. `which` is a built-in shell command that finds the given executable on your `$PATH`. Inside a `java:8` container, `$PATH` looks like this:

    /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

This means that `which less` will look for a program called `less` in each of those six directories in order, then output the full path of the first one it finds. If it doesn't find one, it'll print nothing and exit with a non-zero status code (in *bash*), or sometimes print an error message as well (in *zsh*).

So if we don't have a `$PAGER` but we do have `less` in */usr/bin*, we can ask our shell to default to the latter.

    $ echo "${PAGER-$(which less)}"
    /usr/bin/less

However, if we don't have `less` at all:

    $ echo "${PAGER-$(which less)}"

Nothing. We can use that. If we set that to a variable, we can check whether the variable exists, and then only pipe to the pager if we have one:

    __sdkman_list_candidates {
        local pager="${PAGER-$(which less)}"
        if [[ -n "$pager" ]]; then
            echo "$(curl -s "${SDKMAN_SERVICE}/candidates/list")" | $pager
        else
            echo "$(curl -s "${SDKMAN_SERVICE}/candidates/list")"
        fi
    }

Sorted. The only problem is the duplication. Functions to the rescue, of course.

    __sdkman_list_candidates {
        local pager="${PAGER-$(which less)}"
        __sdkman_page echo "$(curl -s "${SDKMAN_SERVICE}/candidates/list")"
    }

    __sdkman_page {
        local pager="${PAGER-$(which less)}"
        if [[ -n "$pager" ]]; then
            "$@" | $pager
        else
            "$@"
        fi
    }

Here, we've written a function that checks whether we have a pager. If it finds one, it runs its full set of arguments (`$@`) as a command and pipes the output to the pager. If it doesn't, it simply runs the arguments as a command.

Because when you're shipping software to run on Mac OS, Linux and BSD OSes all over the world, you really can't trust that anything is as it seems.

[SDKMAN!]: http://www.sdkman.io/
