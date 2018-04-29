---
title: "Isolating Gems With RVM"
slug: isolating-gems-with-rvm
date: 2016-05-12T07:00:32Z
aliases:
  - /post/144238805415/isolating-gems-with-rvm
---

When working on a Ruby project, it's tempting to just install the gems with `bundle install` and get to work. While Bundler is pretty good at ensuring you only use the gems you specify, and that you get the right versions, you still end up with a ton of gems in one directory with no way to identify which ones you need and which ones exist for projects you don't maintain any more, or are older versions of gems that you've updated.

<!--more-->

Fortunately, [RVM][] has your back. You may be using RVM to install multiple versions of Ruby already. If you're using the version that ships with your operating system or package manager, I'd recommend switching to RVM so you can select your Ruby version on a project-by-project basis. It also lets you keep your gems in your own user profile instead of installing them at the system level.

Once you've [installed RVM][Installing RVM], install the version of Ruby you'd like to use for your project:

    rvm install <ruby version>

For example, if we wanted to use version 2.3.1, we'd type:

    rvm install 2.3.1

Once that's successfully installed, `cd` to your project directory and type:

    rvm use --create --ruby-version <ruby version>@<project name>

If our project was named "fizzbuzz" and we wanted to use Ruby v2.3.1, we'd do the following:

    rvm use --create --ruby-version 2.3.1@fizzbuzz

This will create a *gemset* for your project and switch to it. A gemset is a specific directory on your file system which contains gems, usually in the format *~/.rvm/gems/ruby-&lt;version&gt;@&lt;gemset&gt;* (type `echo $GEM_HOME` to find out where it is in your case). In this case, we've named it after our project, which means we won't re-use the same gemset outside the project, keeping them totally isolated.

It will also create two files, *.ruby-version* and *.ruby-gemset*, which will instruct RVM to switch to that version and gemset whenever you `cd` to that directory. You can commit these to the project to ensure that everyone is using the same Ruby version and keeping their gems isolated in the same way.

Once you've created your gemset, install your gems in the usual way with `bundle install`. They'll be installed to the `GEM_HOME`, which is specific to the gemset. This means that when you're done with the project, all you need to do is delete the gemset with `rvm gemset delete <project name>` and you have a clean house again.

[RVM]: https://rvm.io/
[Installing RVM]: https://rvm.io/rvm/install
