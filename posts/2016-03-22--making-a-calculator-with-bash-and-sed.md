Here's an easy way to make a calculator REPL:

    #!/usr/bin/env bash

    while read line; do
        echo $(($line))
    done

In Bash (and other shells), `$((…))` is the syntax for an *arithmetic expansion*. Anything inside the parentheses is evaluated as most programming languages would, for integer maths (no floating-point magic here). So you can do simple maths:

    $ echo $((2 + 2))
    4

You can also use shell variables as you'd expect, except you don't need to use the `$` to refer to them—it's implicit.

    $ i=7
    $ i=$((i + 1))
        # The above statement could also be written as:
        #   * `((i += 1))`
        #   * `let i='i + 1'`
    $ echo $i
    8

So, when we run our "program", we can even use variables, as long as we declare them outside.

    $ apple_price=17
    $ ./calculator
    2 + 2
    4
    4 * 5
    20
    3 * apple_price
    51

Unfortunately, we can't do the same with functions. My [triangular number][Triangular number] function works fine in the shell itself but can't be used as part of an arithmetic expression:

    $ $ function triangular { echo $(($1 * ($1 + 1) / 2)); }
    $ triangular 4
    10
    $ ./calculator
    triangular 4
    bash: triangular 4: syntax error in expression (error token is "4")

However, with a bit of regular expression magic in the script, we can replace `triangular <n>` with the expression itself. It's a hack and a half, but for prototyping, it works pretty well.

    #!/usr/bin/env bash

    triangular_replacement='s/triangular ([0-9]+)/\1 * (\1 + 1) \/ 2/g'
    sed --regexp-extended "$triangular_replacement" | while read line; do
        echo $(($line))
    done

(If you want a decent `sed` on Mac OS X, install `gsed` with `brew install gnu-sed` and use that instead.)

Let's try it.

    $ ./calculator
    triangular 3 + triangular 4

… Nothing happened. Let's try again:

    10 + triangular 4

Still nothing.

Unfortunately, `sed` buffers when piping to something else. I was pairing with [@sleepyfox][] a couple of weeks ago in a workshop, and it really confused us, so this is actually the original inspiration for this post. When I hit *Ctrl+D* to send the end-of-file character and tell `read` we're done here, `sed` flushes its buffer.

    <Ctrl+D>
    16
    20

Both outputs happen at the same time. Not so helpful. So today, when figuring this one out, I came across the `--unbuffered` switch. Duh.

    #!/usr/bin/env bash

    triangular_replacement='s/triangular ([0-9]+)/\1 * (\1 + 1) \/ 2/g'
    sed --unbuffered --regexp-extended "$triangular_replacement" | while read line; do
        echo $(($line))
    done

Running it:

    $ ./calculator
    triangular 5 * triangular 6
    315

Excellent.

[Triangular number]: https://en.wikipedia.org/wiki/Triangular_number
[@sleepyfox]: https://twitter.com/sleepyfox
