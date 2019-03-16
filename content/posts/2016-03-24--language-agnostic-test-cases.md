---
title: "Language-Agnostic Test Cases"
slug: language-agnostic-test-cases
date: 2016-03-24T08:00:22Z
aliases:
  - /post/141593543350/language-agnostic-test-cases
---

When pairing with [@sleepyfox][] on a kata, we decided to write the code in a shell script. Someone snarkily asked how we were going to test-drive our solution. So, after a second of thought, I remembered my test framework, [Smoke][].

Smoke is a little different from other test frameworks. It was designed to test code written in any language, so you don't write the tests in code. You simply specify the input to be provided to the program via command-line arguments and STDIN, and the expected STDOUT, STDERR and exit statuses. To do this, you just create five text files (though you can leave some out) with the `.args`, `.in`, `.out`, `.err` and `.status` file extensions.

<!--more-->

One advantage of this is that it constrains you to test the command-line interface of your program. While not helpful for lower-level testing, it really forces you to think about the output of your command-line application and how it should behave in various edge cases.

Another interesting feature is that if you switch programming languages, your tests can stay the same. We switched languages twice in an hour, from Bash to awk to Python. During the rewrites, our tests stayed exactly the same.

{{% asset "Smoke output" "2016-03-24+-+smoke.png" %}}

This got me thinking a lot. For high-level integration tests, _should_ we be using test frameworks that are coupled to the programming language? Wouldn't it be better to use frameworks that are coupled to the interface? One that pops to mind is [Aspec][], an HTTP API test framework that, sadly, looks pretty defunct. Its tests look like this (taken straight from the linked article):

    # create and retrieve artist trackings
    POST /users/7/artists/1    204
    POST /users/7/artists/2    204
     GET /users/7/artists      200    application/json   [1, 2]

Just musin'. Muse with me. Check out [Smoke][] and tell me if it's useful (and why it's not). Speculate wildly on separating your interface integration tests from your code some more. And let me know in the comments what you think.

[@sleepyfox]: https://twitter.com/sleepyfox
[smoke]: https://github.com/SamirTalwar/Smoke
[aspec]: http://devblog.songkick.com/2012/12/06/introducing-aspec-a-black-box-api-testing-dsl/
