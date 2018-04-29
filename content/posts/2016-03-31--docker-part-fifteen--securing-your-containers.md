---
title: "Docker, Part Fifteen: Securing Your Containers"
date: 2016-03-31T07:00:35Z
---

Up until now, we've been neglecting security in favour of getting our application working and features delivered. It's time to look back and ensure that there are no holes in our application containers.

<!--more-->

## Docker Itself

First and foremost, having Docker access is having root access. If you're in the `docker` group on your operating system, you might as well grant access to the root user. It's the same thing. Because any Docker container can be run as *root*, and the only thing keeping the user inside the container is, essentially, a chroot, you can easily just mount `/` as `/host` and do whatever you like inside the container as the root user.

For the same reason, only mount the Docker socket (*/var/run/docker.sock*) when you absolutely trust the container in which it's mounted. Anything with access to that socket can simply start a new container with the host filesystem mounted and cause all sorts of damage if left unchecked.

## Attack Surface

One of the beautiful things about containers is that they're *small*. My go-to for one-off pieces of work, [busybox][], is 1.1 MB right now. Granted, that's a Linux distro designed to be absolutely miniscule, but it's still pretty amazing.

When creating an image, the fewer things, the less likely that an attacker that finds a hole will be able to exploit anything. OpenSSL is a great piece of software, but has had a few security vulnerabilities over the years. If you don't need it, don't install it.

[busybox]: https://hub.docker.com/_/busybox/

## Protection Against Yourself

There are plenty of ways you can shoot yourself in the foot when building containers, just as if you were building a bare-metal server or virtual machine. Your dependencies could be out of date and vulnerable, you could have misconfigured services running, or you might just be allowing connections from anyone without validating them first.

Standard advice applies: rebuild your images from scratch periodically—at least once per week—with the latest base images, check your configuration doesn't allow unauthenticated requests, and verify that only the relevant ports are exposed.

Containers also provide the capability to limit CPU and memory access. For example, if you know that your application should only use 256 MB of RAM at the very most, you can cap it by providing `docker run` with the `--memory` switch. The `--cpu*` and `--memory*` switches are also very relevant to constraining your containers. By providing a cap, you can ensure that a rogue process won't nix your entire system.

## User Access

Containers default to the root user unless you specify otherwise, either in the *Dockerfile* or by passing it the `--user` switch. Unfortunately, there are documented exploits that aren't too hard to run through which allow a root user to break out of the container and onto the host, at which point they'll have the run of the place.

It's best to create a user on the container that's independent of anything on the host. There's usually a *nobody* user on the host which has no access to anything private, and which you can map to inside the container. On my Docker Machine VM, the *nobody* user has a user ID and group ID of `65534`, so if I were to create a user and group with those IDs inside the image and run as those, I'd definitely be unable to access anything outside even if I were to find a way to access the host. If you do need data on the local filesystem, you can create a user specifically for the purpose with a UID/GID that's unused on the host instead.

Unfortunately, when you *do* add files to the image, you'll find you need to `chown` them to your new user, as the `COPY` directive in your Dockerfile [always copies files as the root user][Docker #6119]. This is no fun at all, and it's why I'm lazy and stick to *root* in my images despite advice to the contrary.

[Docker #6119]: https://github.com/docker/docker/issues/6119

## Kernel Security

[Docker's own page on security][Docker Security] goes into detail on how to secure the host system, so I won't delve too much. Suffice it to say that because containers share the kernel with the host system, safety measures such as AppArmor or SELinux apply to containers as well. Lock down the host, and your containers will be safer as a result.

[Docker Security]: https://docs.docker.com/engine/security/security/

## And More

This is just the tip of the iceberg. Containers aren't virtual machines, they're wrappers around processes. If you don't want it running on your computer, containers may not help you. Be careful, and treat them just like you would any other piece of code: if you found it on the Internet, read it first, understand the ramifications of running it, and definitely do not just hit the *Go* button without knowing what you're doing.
