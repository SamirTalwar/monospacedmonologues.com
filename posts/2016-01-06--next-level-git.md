It's no secret to anyone I've ever worked with that I essentially run my working life with an ever-growing, ever-changing set of shell scripts.

It is, however, somewhat of a secret that all of these are [hosted on GitHub][FYGM].

Some of them, I use every week or so, like [`up`][up], which updates basically everything on my machine using Homebrew, `apt-get`, RVM, NPM… you name it. Some, I've completely forgotten about, like [`whitespace`][whitespace], which *I'm pretty sure* converts tabs to spaces… I don't even remember why I wrote it. Today, though, I'd like to talk about [a set of scripts][git scripts] I use to save time and hassle when working on a project in a team with either manual or automated code reviews.

[FYGM]: https://github.com/SamirTalwar/fygm
[git scripts]: https://github.com/SamirTalwar/fygm/tree/master/bin/git
[up]: https://github.com/SamirTalwar/fygm/blob/master/bin/unix/up
[whitespace]: https://github.com/SamirTalwar/fygm/blob/master/bin/unix/whitespace

First of all, let me describe the potential workflows.

  1. `cd` to the project directory.
  2. Pull down the latest changes from `master` or whatever your main branch is. If you're on a fork, pull changes from upstream and push to your personal repository.
  3. Check out a new branch named after your new feature/bug fix/work of art/whatever.
  4. Make some changes, verify they work by running your tests (you do have tests, right?) and commit them.
  5. Repeat step 4 until the feature is done.
  6. Push the branch to the repository.
  7. Go to GitHub/BitBucket/GitLab/whatever and open a pull request.
  8. Post a link to that pull request in your IRC/Slack/Jabber channel.
  9. Wait for someone, either a human or a computer (or maybe both), to review it.
  10. If everything is successful, merge the pull request.

Whew. That's a lot of work. Note that steps 4 and 5 are the only part where you're contributing to the project. Everything else is [waste][The 8 Wastes]. But wait, there's more. If it's not successful, you need to change things and push more commits. In the mean time, something else has probably been merged and yours is no longer mergeable, so:

  1. Check out the master branch.
  2. Pull the latest changes.
  3. Switch back to your development branch.
  4. Merge the master branch in.
  5. Fix the conflicts.
  6. Commit.
  7. Push.

What a waste of life.

[The 8 Wastes]: https://goleansixsigma.com/8-wastes/

The thing is, apart from the bits where you're coding, it's *all* repetitive, boring work. And the beautiful thing about repetitive, boring work on a computer is you can script the hell out of it.

So I did. Here's how I roll.

  1. Type `j project` to jump to the project directory using [autojump][].
  2. Type [`git up`][git update-master]. This script:
    1. checks out the master branch if we're not already there,
    2. pulls the latest changes from either the upstream fork or the master branch,
    3. pushes the upstream changes to my local repository if I'm working on a fork,
    4. and switches back to the original branch.
  3. Start working.
  4. When I realise I forgot to switch branch and I've committed twice already, type [`git switch-to my-feature`][git switch-to] to change to a new branch, keep all my current commits and remove them from the master branch.
  5. When I'm done, type [`git pr`][git pull-request] to push the branch and open up a web page with a button to create pull request. I was tempted to automate submitting the pull request, but I find that reading the diff beforehand often helps me find any issues.
  6. Let Slack find the pull request and automatically post it. If I have to use something that's not Slack again I'm definitely making [Hubot][] do it.

And of course, when I get clobbered by someone else's merge, I just type [`git upm`][git upm], which runs [`git up`][git update-master] and then merges the changes into my current branch. Then I fix the conflicts and push again. The pull request is automatically updated.

---

All these commands have been in my Git configuration since 2014 or so, and they've become more and more sophisticated and stable as time has progressed. But I don't advise you use them. They're set up to work just the way I want them, and you deserve something just as fitting for you. Think about the commands you find hard to type or that require multiple steps, and go from there. Start by creating simple git aliases using the command `git config --global alias.my-alias-name command`. For example, this lets you type [`git a`][git add-all] to stage everything, including deleted files:

    git config --global alias.a 'add --all'

You can also run scripts from aliases. I use [`git p`][git pull-everything] to pull down changes with the `--ff-only` flag to ensure that I don't get an unexpected merge and then update all submodules:

    git config --global alias.p '! git pull --ff-only --prune && git submodule update --init --recursive'

And there are plenty more examples in my own [.gitconfig][].

[autojump]: https://github.com/wting/autojump
[Hubot]: https://hubot.github.com/
[.gitconfig]: https://github.com/SamirTalwar/fygm/blob/master/dotfiles/gitconfig
[git add-all]: https://github.com/SamirTalwar/fygm/blob/master/dotfiles/gitconfig#L42
[git pull-everything]: https://github.com/SamirTalwar/fygm/blob/master/dotfiles/gitconfig#L23
[git pull-request]: https://github.com/SamirTalwar/fygm/blob/master/bin/git/pull-request
[git switch-to]: https://github.com/SamirTalwar/fygm/blob/master/bin/git/switch-to
[git update-master]: https://github.com/SamirTalwar/fygm/blob/master/bin/git/update-master
[git upm]: https://github.com/SamirTalwar/fygm/blob/master/dotfiles/gitconfig#L42

Git is a tool I use hundreds of times a day. You might have a different one. Whatever you're spending your time doing, if it feels like waste, script it. And tell me about it! Either in the comments below, or [on Twitter][@SamirTalwar].

[@SamirTalwar]: https://twitter.com/SamirTalwar
