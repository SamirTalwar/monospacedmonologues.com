---
title: "You Don't Need To Rebase"
slug: you-dont-need-to-rebase
date: 2017-12-06T08:00:30Z
---

*This post is loosely based on a discussion with [Beverley Newing][@WebDevBev] and others on the [Codebar][] Slack team.*

---

You don't need to rebase.

I think branch-based development is now the most common workflow when using Git: everyone develops on a branch that belongs to them (for some definition of "belongs", depending on the team), then when they're done, they merge the branch into a shared branch (often called `master`, `latest` or `develop`), from which they release.

<!--more-->

Here's a common workflow:

1. I pull a new feature from the board. It's written on a sticky note, which I move into the correct column. (If you use JIRA, I seriously recommend trying sticky notes instead. They're way more flexible.)
2. I create a new branch, and I start working on the feature.
3. I commit.
4. I commit some more.
5. I run `git rebase master` to reset my commits on top of the latest changes.
6. I test it manually. (I already wrote automated tests, but I like to test manually too.)
7. I push the branch to our Git server.
8. Someone else reviews it and merges it into `master`.

Now, most of that is necessary. I could have merged it into `master` myself, given a different kind of team. But there's one part that isn't: rewriting history.

Instead of running `git rebase master`, I could have just pushed it. Assuming no merge conflicts, it could still have been merged.

Now, there's a couple of problems with this. First of all, there's often merge conflicts, and I don't want someone else to have to deal with them. And it could be that merging causes a bug, so I better test after merging, not before.

However, there's another solution: `git merge master` instead.

Merging instead of rebasing has its downsides: people often point to the ugliness of the commit graph, and how it's difficult to read the history. It's true, and I often use `git rebase` myself. But it's worth being aware of what you're doing when you use it: you're rewriting the history. `git rebase`, just like `git commit --amend` and `git reset`, is a *destructive* change: it doesn't just write new things to the branch, but changes the past.

Now, having a clean history is definitely useful. It means that going backwards to see the steps is a lot easier. However, it's pretty much impossible to undo, especially if you've pushed and pulled this branch a couple of times. One of the benefits of a version control system is you can always roll back… but you can't (easily) `revert` a `rebase`. You threw away the old commits; they're not there any more. (Except in the *reflog*… hopefully.)

This is a small problem when you're working locally; you usually don't need to roll back, and when you do there are often other ways of handling it. But it causes serious problems after you push. If someone else pulls down the branch and makes their own changes, they're going to have a hard time reconciling them. And if they comment on a commit on GitHub/GitLab/Bitbucket/whatevs (which is pretty likely if you use them for code review), those comments will be detached from the changes.

There are plenty of good reasons to `git rebase`. Just make sure you know what you're doing. Git's a very powerful tool, and rewriting history is a pretty dangerous endeavour. Put your steel-toed boots on first.

[@WebDevBev]: https://twitter.com/WebDevBev
[Codebar]: https://codebar.io/
