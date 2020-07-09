---
title: "Untriggered traps in zsh"
slug: untriggered-traps-in-zsh
date: 2020-07-09T16:00:00Z
---

Recently, I had the displeasure of experiencing a few interesting situations in which traps in zsh don't run. This isn't the first time I've wasted hours or days debugging this problem, so I'm writing it down.

For those of you who may not know, a _trap_ is a catch-all exception handler. Think of it as a `finally` block for your shell script.

Try this script:

```sh
#!/usr/bin/env zsh

set -e

trap 'echo "Finished."' EXIT

echo 'Started.'
false
echo 'This will not print.'
```

This script will exit with a failure code due to the `false` invocation. This is because `set -e`, or `set -o errexit`, will tell the shell to exit as soon as one command fails. (This is not the default, or your shell would keep quitting on you every time you made a typo.)

It'll output this:

```
Started.
Finished.
```

<!--more-->

## `errexit` in zsh functions

Now here's the problem. This doesn't work:

```sh
#!/usr/bin/env zsh

set -e

function setup {
  echo 'Started.'
}

function do_the_thing {
  echo 'Doing the thing.'
  false
  echo 'This will not print.'
}

function cleanup {
  echo 'Finished.'
}

trap cleanup EXIT
setup
do_the_thing
```

This prints:

```
Started.
Doing the thing.
```

It turns out that functions are a little special. If a function aborts with a failure, the trap doesn't fire. (This isn't the case when using `bash`.) I have to assume this is a bug in zsh, which I've reproduced on multiple platforms.

Fortunately, there's an easy fix. Instead of using `set -e`/`set -o errexit`, you can use `set -o err_return`. This instructs functions to behave as you would expect. When I change that line, I get the following output:

```
Started.
Doing the thing.
Finished.
```

Ta da! We have working code.

## traps with `no_unset`

Another common line at the top of a shell script is `set -u`, or `set -o no_unset`. This tells the script to abort immediately if it references a variable that doesn't exist, instead of substituting it with the empty string. It's very useful for making sure you don't, for example, delete everything on your computer by running `rm -rf $DRICETROY/*`, which would resolve to `rm -rf /*`.

(If that's not a reason not to use a safer language, then, well, best of luck.)

Unfortunately, it really works. It works so well, unfortunately, that traps don't fire.

I wish I had a solution for you here, but honestly, I don't think it's possible to make the trap fire. Your best bet is to factor out the setup and cleanup into wrapper script, because an unset variable in a called script will appear as a conventional failure to the calling script, meaning your trap will fire as usual.

## traps when running with `exec`

When the last command in a script is to defer to another program to do the heavy lifting, we often use `exec` to replace the current process, rather than starting it as a child process. This means we don't have to worry about two processes at once, which makes life easier.

```sh
#!/usr/bin/env zsh

function cleanup {
  echo "This won't happen."
}

trap cleanup EXIT
setup
exec ./main.sh
echo "This won't happen either."
```

However, when doing so, we're effectively throwing away our current script. This means that `exec` is always the last thing to happen. Anything after that, whether they're subsequent statements or a trap, are tossed. The solution is simple (but not always easy): don't use `exec` if you have behavior that needs to happen afterwards.

## It's a trap!

I hope this helps. I can't be the only person who runs into these issues once a year or so.

It's been remarked, by various people, pretty much constantly, that a shell script that's more than 10 lines should be rewritten with a safer programming language. I don't think this is a bad advice, and I'd encourage you to seriously consider something like Python or Ruby if you run into these problems a lot.

That said, there's a class of solutions that are just a lot more pleasant to work with in a shell language, where calling another program is normal, and doesn't require any special effort. I've personally been spending a lot of time at work spinning up and shutting down cloud instances for performance testing, and while Google Cloud probably has a decent HTTP API, it's a lot easier to just hit it with the CLI.

So if you're adamant that a shell script is the right way to go, more power to you. Just make sure you're practicing basic scripting hygiene:

```sh
set -o err_return
set -o no_unset
set -o pipefail
```
