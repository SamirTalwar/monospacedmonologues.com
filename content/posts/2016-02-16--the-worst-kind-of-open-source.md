---
title: "The Worst Kind of Open-Source"
slug: the-worst-kind-of-open-source
date: 2016-02-16T08:00:34Z
aliases:
  - /post/139411961508/the-worst-kind-of-open-source
---

There's a growing trend among software developers which I absolutely love. More and more, people are checking their *dotfiles* (configuration files, normally starting with "`.`") and other personal scripts into version control and pushing them up to the Internet. It's mostly selfish—just a useful way to make sure we don't lose them, to be honest, and perhaps help us set up another computer quickly.

There's also one massive benefit I've found to pushing [my configuration files and shell scripts][fygm] up to GitHub.

<!--more-->

When pairing, we might notice that someone else's machine is not configured optimally. In that situation, we can just point them towards the relevant line of one of our own dotfiles, and then get on with the task at hand, knowing that if they're interested, they'll take a look later. The alternative is to start shaving the yak. It takes a while to get your computer working just the way you like it, and it's very easy to start hacking together configuration files instead of getting work done. By simply pointing someone to a file, we can avoid getting distracted for more than a few seconds. It also means that if they're not actually that interested, it doesn't waste more than a few seconds of their time.

In other words, sharing is caring. Just, y'know, go easy on the sharing.

Let's be clear. This is open-source software, same as anything else, but it's the worst kind. No one is going to use your dotfiles as-is—they're going to take the bits they want and fold them into their own. There's going to be massive duplication across repositories because no one is packaging their scripts and configuration into a library—they're just putting them out there. There's no update mechanism, no tests, and if it only works on my machine, that's fine by me.

I can't decide whether or not this is a good thing. If I were to package and release, for example, [my Git scripts][fygm/bin/git], I'd probably get it wrong. I'd have to optimistically generalise in some places, test in environments I don't have easy access to, and overall, put in way more effort than I'm ready to for things I change at a whim, while drunk, often in the middle of something else with very little forethought.

After all, [as Sandi Metz said][The Wrong Abstraction]:

> Duplication is far cheaper than the wrong abstraction.

[fygm]: https://github.com/SamirTalwar/fygm
[fygm/bin/git]: https://github.com/SamirTalwar/fygm/tree/master/bin/git
[The Wrong Abstraction]: http://www.sandimetz.com/blog/2016/1/20/the-wrong-abstraction
