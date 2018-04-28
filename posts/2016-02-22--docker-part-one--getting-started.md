I've been using Docker heavily in development, test and production for almost a year now, and more and more, I’m asked how to get started with it and use it. I thought I’d write a quick guide to Making Things Happen™ on your local machine, and perhaps touch on deploying services inside Docker containers in the future.

## First and foremost, what is Docker?

I’m fairly sure at this point we’re familiar with virtual machines and their impact on software development. Many organisations now run their server applications and services inside virtual machines to keep them contained and ensure that one failing, buggy or out-of-control service doesn’t impact another. We even rent virtual machines from cloud providers such as Amazon, Rackspace, Joyent and many more.

Docker is based on [control groups (cgroups)][cgroups] and [namespace isolation][] in the Linux kernel, as well as union filesystems such as [aufs][], which together allow it to *contain* processes and directory structures in containers.[^libcontainer update] These containers are often referred to as “lightweight VMs”, so called because they allow you to get VM-like capabilities, including segregated file systems, memory caps and separate networking layers, but without paying the price of having several operating systems running on one computer. This is done by sharing the kernel: each container re-uses the Linux kernel, which means less overhead per container. While I can only run two or three VMs on my laptop before it slows to a crawl, the same machine can often run 20 or 30 containers, especially if each one doesn’t require a lot of CPU time or dedicated memory.

Of course, all this means you need to be running Linux. Fortunately, it’s easy to spin up a virtual machine specifically for the purpose of running Docker containers.

[^libcontainer update]: Thanks to [Peter Idah][@peteridah] for updating me. I originally wrote that it was based on Linux Containers (LXC), but Docker now uses libcontainer, which is essentially its own implementation.

[cgroups]: https://en.wikipedia.org/wiki/Cgroups
[namespace isolation]: https://en.wikipedia.org/wiki/Cgroups#NAMESPACE-ISOLATION
[aufs]: https://en.wikipedia.org/wiki/Aufs
[@peteridah]: https://twitter.com/peteridah

## Running Docker on Windows and Mac

The recommended method of running Docker on a non-Linux operating system is to use Docker Machine, a VM provisioning tool, to spin up a Linux virtual machine. It's suggested you use the [Docker Toolbox][] to install Docker and Docker Machine. Docker Toolbox also installs [Docker Compose][], which we use for managing multiple containers at once, and [VirtualBox][], a free, open-source virtual machine host.

On Windows, Docker Toolbox is your best choice—just download and run the installer. On Mac OS, you can take the same approach, but I prefer to use [Homebrew][] and [Caskroom][], which I use for installing most of my developer tools. If you already have Homebrew, you can install everything you need by running:

    $ brew tap caskroom/cask
    $ brew update
    $ brew install docker docker-machine docker-compose
    $ brew cask install virtualbox

[Docker Toolbox]: https://www.docker.com/toolbox
[Docker Compose]: https://docs.docker.com/compose/
[VirtualBox]: https://www.virtualbox.org/
[Homebrew]: http://brew.sh/
[Caskroom]: http://caskroom.io/

### Creating a VM

If you installed Docker Toolbox, all you need to do is run the *Docker Quickstart* shortcut that should have been installed for you. On Windows, this runs in Cygwin, a Unix terminal in Windows which makes life way more consistent.

If you're going the manual route, once you have installed Docker and Docker Machine, you can create a new VM on VirtualBox:

    $ docker-machine create --driver=virtualbox default

This will create a new VM named "default". It'll take a while to download everything the first time, but then you'll have a shiny new VM. It should have already started, but if not, you can start it using `docker-machine start default`, and stop it using `docker-machine stop default`.

### Connecting to the VM

Finally, we need to connect our Docker client on the Windows or Mac host to the Docker server running inside the VM. We do this by setting some environment variables. Type `docker-machine env default` and you'll see something like the following:

    export DOCKER_TLS_VERIFY="1"
    export DOCKER_HOST="tcp://192.168.99.100:2376"
    export DOCKER_CERT_PATH="~/.docker/machine/machines/default"
    export DOCKER_MACHINE_NAME="default"
    # Run this command to configure your shell:
    # eval "$(docker-machine env default)"

Copy that last line from your output into your terminal prompt to run all those `export` commands.

### Every Time?

You'll need to run that command each time you want to interact with your Docker server in a new terminal session. This is boring and error-prone, so I've added the following to my `.zshenv` file in my home directory; you can do the same thing if you use Bash by adding it to your `.bash_profile` file.

    if [[ "$("$(which gtimeout || which timeout)" 3 docker-machine status default 2>/dev/null)" == 'Running' ]]; then
        eval "$(docker-machine env default)"
    fi

That simple script asks `docker-machine` if the VM is up and running, and if so, runs those `export` commands. This means that you will have to do it manually if the VM is stopped when you start your terminal session.

The command times out after three seconds in case something is wrong, so your shell will not block forever. To make that work on Mac OS, you'll need to install the GNU coreutils:

    $ brew install coreutils

With all that, you should be able to get started.

## Running Docker on Linux

If you're already using Linux, congratulations! No virtual machines for you (though if you'd prefer that, scroll to the bottom of this section). You just need to run [an installation script][Installation on Ubuntu]. This guide is written for Ubuntu users, but there are lots more in the navigation menu.

On Ubuntu and some other distros, `wget` isn't available, so you'll need to install it. You can check by running `which wget`; if the terminal shows the path to a binary, you're good to go. Otherwise:

    $ sudo apt-get update
    $ sudo apt-get install -y wget

Then follow the instructions in the page linked above. At the time of writing, they tell you to do this:

    $ wget -qO- https://get.docker.com/gpg | sudo apt-key add -
    $ wget -qO- https://get.docker.com/ | sh

It will instruct you to add yourself to the *docker* group if you'd like to use Docker without `sudo`. You can do this with the command provided:

    $ sudo usermod -aG docker $USER

Then just start it up:

    $ sudo service docker start

As the Docker server is running locally, it will launch Docker processes alongside everything else on your system. This can be problematic, as Docker is not yet entirely stable, and it's sometimes necessary to restart your computer to flush errant processes. If you would like a little more containment than Docker can provide, it might be worth creating a virtual machine *anyway*. If you'd prefer this, you can just [install Docker Machine][Install Docker Machine] and follow the Mac instructions above.

[Installation on Ubuntu]: https://docs.docker.com/installation/ubuntulinux/
[Install Docker Machine]: https://docs.docker.com/machine/install-machine/

## Running Your First Application

Once you've configured Docker Machine and spun up a VM, let's run a Docker container.

    $ docker run hello-world

If all is working, Docker will start pulling an "image" from the [Docker Hub][]. Once that's done, it'll print out a message that explains what just happened. Read it carefully; we'll go through it in a bit.

On my machine, it looks like this:

Hello from Docker.
This message shows that your installation appears to be working correctly.

    To generate this message, Docker took the following steps:
     1. The Docker client contacted the Docker daemon.
     2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
     3. The Docker daemon created a new container from that image which runs the
        executable that produces the output you are currently reading.
     4. The Docker daemon streamed that output to the Docker client, which sent it
        to your terminal.

    To try something more ambitious, you can run an Ubuntu container with:
     $ docker run -it ubuntu bash

    Share images, automate workflows, and more with a free Docker Hub account:
     https://hub.docker.com

    For more examples and ideas, visit:
     https://docs.docker.com/userguide/

If it didn't work, and the output doesn't look much like that at all, then read on. Otherwise, if you see that or something quite like it, you're good to go! The next article will cover using Docker for something useful. You can skip the rest of this article and move straight on to the next one.

[Docker Hub]: https://hub.docker.com/

### But it broke!

It's probable that either the service didn't start correctly or the connection between the client and the server failed. The former is beyond the scope of this article; the latter is often just a problem with your VM state or your environment variables.

#### Windows, Mac or Linux with Docker Machine

First off, check that your environment variables are set correctly. If you're using Docker Machine on Mac or Linux, you can do this by running the following on the command line:

    $ env | grep DOCKER

Afterwards, run:

    $ docker-machine env default

Then compare the two sets of environment variables. They should be the same, possibly with more in the first batch. If not, check you put the correct commands into your `.zshenv` or `.bash_profile` files and start a new terminal window or tab.

Next, you should check whether the machine is running at all. Executing `docker-machine status default` should print out `Running`. If it doesn't, you need to start it: type `docker-machine start default`. If it is, it may be stuck.

First of all, try restarting it:

    $ docker-machine restart default

Remember that this will restart any running Docker processes, so be wary before doing it without thinking.

If you still get no connection, try SSHing into the box:

    $ docker-machine ssh default

Once there, you can view the Docker logs by checking */var/log/docker.log*. Look for any errors and start Googling.

If you can't connect at all, it might be worth removing the machine entirely with `docker-machine rm` and starting from scratch.

#### Linux without Docker Machine

As you're running Docker natively, there's far fewer things that can go wrong, though when they do, they can cause serious problems. As above, it's worth checking */var/log/docker.log* for errors and Googling them. You can also restart the service; on Ubuntu, it goes like this:

    $ sudo service docker restart

If that doesn't work on your distro, try this:

    $ sudo /etc/init.d/docker restart

Often, restarting a stuck Docker service will solve your problem. Note that this will stop all of your processes, so be careful.

### Same Time, Same Place

I'm going to be going for a while. Tune in tomorrow for a more low-level analysis on how Docker works.
