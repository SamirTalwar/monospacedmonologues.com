---
title: "Docker, Part Fourteen: Behave Like A Process"
slug: docker-part-fourteen--behave-like-a-process
date: 2016-03-30T07:00:32Z
---

I was going to write a long post on all the different ways in which stopping your container can go wrong, but it turns out Brian DeHamer beat me to it and did a much better job than I could. I'd recommend reading the article, [Gracefully Stopping Docker Containers][].

But for completeness' sake, I'd like to apply the advice in that article to my pet project, [*bemorerandom.com*][bemorerandom.com].

[Gracefully Stopping Docker Containers]: https://www.ctl.io/developers/blog/post/gracefully-stopping-docker-containers/
[bemorerandom.com]: https://github.com/SamirTalwar/bemorerandom.com

<!--more-->

---

Here's what happens when I terminate the *bemorerandom.com* API service:

    $ docker stop bemorerandomcom_api_1
    <tick>
    <tock>
    <tick>
    <tock>
    ...
    bemorerandomcom_api_1

There's a ten-second wait between me issuing the command and it actually happening. We can inspect the container and find out exactly how it terminated:

    $ docker inspect -f '{{.State.ExitCode}}' bemorerandomcom_api_1
    137

As explained in Brian's article, `137` means that it was terminated due to an unhandled signal—in this case, signal `9`, or `SIGKILL`. After 10 seconds, Docker gave up and killed it.

This is bad for a couple of reasons. First of all, it takes a long time to stop, which is no fun. But far more importantly, if the process was doing anything stateful, such as communicating over the network to a user or another service, writing data to a volume or uploading data to a database, then it'll have broken half-way through. Cleaning up that mess is going to be no fun at all, assuming you can even recognise a failure.

So, following the advice in Brian's article, I stopped letting `sh` bootstrap my process, as it doesn't forward signals. Instead, I instructed Docker to run it directly by providing the command and arguments as a JSON-like array.

What was this:

    CMD java -cp api/target/app.jar:api/target/dependency/\* com.bemorerandom.api.ApiServerMain

Is now this:

    CMD ["java", "-cp", "api/target/app.jar:api/target/dependency/*", "com.bemorerandom.api.ApiServerMain"]

It's a simple change, but made all the difference.

If I really needed the shell for something, I could instead instruct it to replace itself with the Java process, rather than starting it as a child process. To do this, you just use the `exec` command to instruct the operating system to replace the running process. Doing this keeps the process ID (PID), and so our Java process gets a PID of 1, which is what Docker expects the main process of the container to use.

    CMD exec java -cp api/target/app.jar:api/target/dependency/\* com.bemorerandom.api.ApiServerMain

In my case, I don't really need the shell anyway, so I'm opting for the former solution.

Containers are a little weird—they're not exactly completely compartmentalised. If your process spawns other processes, it better clean up after itself, otherwise you might find that you have a bunch of orphan processes running around in containers that don't really exist any more. Not exactly ideal. If your program *doesn't* clean up errant processes and isn't able to keep track of them, that's OK—this is exactly why we have *init*. [init][] is your typical first process in Unix—it starts all other processes and cleans them up when it's time to log off or shut down the system.

if you do decide to go down the *init* road, I recommend [tini][], which is a very small init-compatible binary that does the same thing, and is designed specifically for Docker containers.

    ENTRYPOINT ["/tini", "--"]
    CMD ["java", "-cp", "api/target/app.jar:api/target/dependency/*", "com.bemorerandom.api.ApiServerMain"]

[init]: https://en.wikipedia.org/wiki/Init
[tini]: https://github.com/krallin/tini

---

Avoiding Docker's shell-style `CMD` is a useful tip, but there's a broader lesson here. Your containers should behave just like processes do. Linux has a set of conventions that governs how processes should behave, and if you're not careful to abide by them, things are going to get confusing at the worst possible moment.

Keep an eye out for red flags like *having* to kill containers, rather than stopping them gracefully. Your users will be upset when you terminate their connection half-way through, but they won't be the only ones crying when things go pear-shaped and you can't figure out why. Comply to the Unix/Linux standards, and your life will become a lot easier in the long run.
