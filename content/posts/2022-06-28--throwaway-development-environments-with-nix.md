---
title: "Throwaway development environments with Nix"
slug: throwaway-development-environments-with-nix
date: 2022-06-28T10:00:00+02:00
---

I use [Nix][] a lot.

Nix is a bunch of different things. It’s a programming language, designed for expressing a build pipeline. It’s a package manager. It (well, _NixOS_) is an operating system based on that package manager.

Today I’d like to talk about the package manager. Specifically, a lovely gateway into the rest of the ecosystem, `nix-shell`.

People will tell you that the point of Nix is to set up your software so it can be built with Nix, which allows you to tightly control all dependencies and emit something that is as close to reproducible as possible. I am all for this, but if we can tightly control the dependencies _without_ actually building inside a Nix environment, we’ve still improved the reproducibility a lot, and it’s not that hard.

To follow along, you’ll need to first [install Nix][].

## Running an arbitrary program with `nix-shell`

`nix-shell` does two things. It will read an environment specification from a file named _shell.nix_ and load up a bash shell (which you can override) with that environment present. _Or_ it will do the same thing with a list of packages supplied on the command line.

For example, if I want to run the `cowsay` program, I don’t have to install it: I can load a shell with that program.

```
$ nix-shell -p cowsay
this path will be fetched (0.01 MiB download, 0.05 MiB unpacked):
  /nix/store/x87xaaad225x5x9gv15mn01mf204kycv-cowsay-3.04
copying path '/nix/store/x87xaaad225x5x9gv15mn01mf204kycv-cowsay-3.04' from 'https://cache.nixos.org'...

[nix-shell:~]$ cowsay hello
 _______
< hello >
 -------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

Running `nix-shell -p cowsay` will download `cowsay` from the [nixpkgs][] package repository, and then launch a `bash` shell with that program available, by adding it to the `PATH`.

We can verify that:

```
[nix-shell:~]$ echo $PATH
...:/nix/store/x87xaaad225x5x9gv15mn01mf204kycv-cowsay-3.04/bin:...
```

There it is: `cowsay`, downloaded to the Nix store.

(You’ll see more than just that in the PATH, and you may see `nix-shell` download a lot of extra packages the first time you use it. Just sit tight.)

You may be wondering what that long string of letters and numbers is in the package directory name. It’s a hash of all the inputs, which means that if one of the dependencies change, the hash will change too. The source of the program is also considered an input, so if we upgrade `cowsay` to a new version (I find it awesome that there are so many versions of this program), the hash will also change.

This means that we can have various different versions all available in our local store at once, and they won’t collide with each other. Perhaps not so important for `cowsay`, but when we start dealing with programming languages, this gets interesting.

<!--more-->

## Isolated programming language environments

Let’s say you’re writing some Python code.

```python
import sys
print(sys.argv[1].removeprefix('Hello').strip())
```

You run it with your system-provided `python`:

```
$ python --version
Python 3.9.13
$ python unhello.py 'Hello Eric'
Eric
```

However, that’s not enough. You want to verify that this works for older versions of Python.

So let’s go get one from nixpkgs. How about Python 3.8?

First, we need to find the correct name for the package. I typically use the `nix repl` for this:

```
$ nix repl '<nixpkgs>'
Welcome to Nix 2.9.1. Type :? for help.

Loading '<nixpkgs>'...
Added 16602 variables.
```

I then type `python<TAB>` and see what I get:

```
nix-repl> python<TAB>
python                   python2Full              python37Packages         pythonCondaPackages
python-cosmopolitan      python2Packages          python38                 pythonDocs
python-language-server   python2nix               python38Full             pythonFull
python-qt                python3                  python38Packages         pythonInterpreters
python-setup-hook        python310                python39                 pythonManylinuxPackages
python-swiftclient       python310Packages        python39Full             pythonPackages
python2                  python311                python39Packages
python27                 python311Packages        python3Full
python27Full             python37                 python3Minimal
python27Packages         python37Full             python3Packages
```

Aha, I see `python37` and `python38`. No `python36`, which is a shame if I want to support that, but as it’s no longer supported by the Python maintainers, it’s not much of a surprise.

(FYI, you can always check out an older nixpkgs version if you want older packages, and fix your dependencies to a specific version. We’ll discuss this later.)

So let’s run it:

```
$ nix-shell -p python38 --run 'python unhello.py "Hello Eric"'
this path will be fetched (25.64 MiB download, 76.73 MiB unpacked):
  /nix/store/r6xsd9jlzxv2n4vs9dvgdx5hqr12hpbg-python3-3.8.13
copying path '/nix/store/r6xsd9jlzxv2n4vs9dvgdx5hqr12hpbg-python3-3.8.13' from 'https://cache.nixos.org'...
Traceback (most recent call last):
  File "unhello.py", line 2, in <module>
    print(sys.argv[1].removeprefix('Hello').strip())
AttributeError: 'str' object has no attribute 'removeprefix'
```

Looks like `removeprefix` was added in Python 3.9. Probably a good thing we checked it.

Unlike other package managers, Nix allows me to use a different version of my toolchain for every project. If one project relies on Python 3.8 and one on Python 3.9, I am easily able to switch.

## Package management, all the way down

Of course, I _never_ just use raw Python. I use libraries alongside it. For example, I might want to use `numpy` to try something out.

So let’s go get it from nixpkgs. We can do this by calling the `withPackages` function on the relevant Python package, which takes a function that, given all the available packages, returns a list of the packages we want.

```
$ nix-shell -p 'python3.withPackages(ps: [ps.numpy])' --run python
this derivation will be built:
  /nix/store/v0y0ig25633knjaw421hwbbxgcapp8gj-python3-3.9.13-env.drv
this path will be fetched (4.72 MiB download, 26.21 MiB unpacked):
  /nix/store/8wblrfzkpfqfhzman9pq3imfvllpdqix-python3.9-numpy-1.21.5
copying path '/nix/store/8wblrfzkpfqfhzman9pq3imfvllpdqix-python3.9-numpy-1.21.5' from 'https://cache.nixos.org'...
building '/nix/store/v0y0ig25633knjaw421hwbbxgcapp8gj-python3-3.9.13-env.drv'...
created 239 symlinks in user environment
Python 3.9.13 (main, May 17 2022, 14:19:07)
[GCC 11.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import numpy as np
>>> np.arange(15, dtype=np.int64).reshape(3, 5)
array([[ 0,  1,  2,  3,  4],
       [ 5,  6,  7,  8,  9],
       [10, 11, 12, 13, 14]])
```

There we go. Instant numpy.

_nixpkgs_ provides this functionality for a lot of languages. For example, we might want to load up GHC, with a package or two:

```
$ nix-shell -p 'ghc.withPackages(ps: [ps.unordered-containers])' --run ghci
this derivation will be built:
  /nix/store/nrc3y54yrihm007y9hsjswmaahycvgdw-ghc-9.0.2-with-packages.drv
building '/nix/store/nrc3y54yrihm007y9hsjswmaahycvgdw-ghc-9.0.2-with-packages.drv'...
/nix/store/7y9561zfi62w53b6ilyrcah8djarph7g-unordered-containers-0.2.17.0/nix-support:
propagated-build-inputs: /nix/store/krpbr2bp35cykm7hnjx1w28g97nmbwbm-hashable-1.3.5.0/nix-support/propagated-build-inputs
GHCi, version 9.0.2: https://www.haskell.org/ghc/  :? for help
ghci> import Data.Set as Set
ghci> Set.fromList [1, 2, 3, 2, 1]
fromList [1,2,3]
```

## Preserving our environment

Once we’ve got things working the way we like, we might want to preserve it so we can easily access it again. We can do this by creating a _shell.nix_ file. For our numpy program earlier, this might look like this:

```nix
{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "experiment";

  buildInputs = [
    (pkgs.python3.withPackages (ps: [
      ps.numpy
    ]))
  ];
}
```

(You really will need to learn the intricacies of the Nix language if you want to go much further than this.)

This file allows us to run `nix-shell` without specifying the packages; it’ll load _shell.nix_ to find them out.

```
$ nix-shell

[nix-shell:~]$ python -c 'import numpy as np; print(np.arange(15, dtype=np.int64).reshape(3, 5))'
[[ 0  1  2  3  4]
 [ 5  6  7  8  9]
 [10 11 12 13 14]]
```

(We could also pass the whole invocation in as an argument to `nix-shell --run`.)

You can then check this _shell.nix_ file in and everyone will get the same shell… except they’ll probably be running with a different version of nixpkgs, so _python3_ or one of its dependencies might change, causing variations across computers. We can remedy this by importing an explicit version:

```
{ pkgs ? import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/e0a42267f73ea52adc061a64650fddc59906fc99.tar.gz") { } }:
pkgs.mkShell {
  ...
}
```

This works because every revision of nixpkgs is just a commit to a Git repository living on GitHub. If you pull the archive of a specific commit, everything will be pinned to the specific version at the time of that commit. And if you pick an old commit, you'll get older packages, which might be very helpful for your purposes.

With this new _shell.nix_ file, everyone is running the same dependencies.

## Discoverability… or not

So var I have been seriously extolling the virtues of Nix and nixpkgs. I think there’s one thing worth pointing out that makes it very difficult to get started: knowing what’s available.

While nixpkgs does have [documentation][nixpkgs], it’s far from complete, and it often presumes a level of knowledge lacking in anyone who needs to read the documentation. I have found that I’m most lucky when I’m browsing in the `nix repl` and using tab-completion to suss out what I’m looking for. This is, of course, not ideal; it’s very easy to miss the “correct” way to do things. Sometimes you can trawl through [the nixpkgs code][nixpkgs on github] to find a package that does something similar to what you want, but again, it requires a level of knowledge it’s unreasonable to expect in a beginner.

Part of the reason I’m writing this post is to try and improve the situation, by providing patterns which can be used even if you have no idea what you’re doing. This post only scratches the surface, but it may be enough for you for now.

## Addendum: new tooling

At the time of writing, there are two new tools designed to replace `nix-shell`.

The first is called `nix run`. This does something similar to `nix-shell -p`, in that it downloads a program and runs it. However, it’s much simplified; it doesn’t spawn a shell, it just runs that program, along with any arguments you pass it.

```
$ nix run nixpkgs#cowsay oh look new shiny thing
 _________________________
< oh look new shiny thing >
 -------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

I use it a lot, but it has two big downsides:

1. it doesn’t support arbitrary expressions, so you can’t use `withPackages`, and
2. it always tries to download the latest nixpkgs, rather than using your cached copy, which is mostly useless and takes a few extra seconds.

The second tool is called `nix develop`. This is a bit like `nix-shell` loading _shell.nix_, except it tries to load your shell from a “flake”. Flakes are quite new, more complicated, and even less documented than the rest of Nix, and so while they seem pretty useful, I have mostly avoided them until now.

`nix develop` is mostly designed around spawning a shell so that you can build your program in the same way that Nix would build it, so it also makes some trade-offs that I find quite unfriendly to a beginner.

I’m really hoping Nix flakes mature to the point where they’re easy to use, but currently, I suggest avoiding them at first. Go play with `nix-shell` instead and discover a universe where you don’t have to globally install tools just to try them out.

## Q: I am very lazy and `nix-shell` seems like effort.

That’s not a question, but I will endeavour to answer it anyway.

If you have a _shell.nix_ file, but don’t want to type `nix-shell` (and I don’t):

1. Install [direnv][].
2. Install and configure [nix-direnv][].
3. Create a file called _.envrc_ in your project file that says `use nix`.
4. There is no step 4. That was it.

Now when you `cd` into the appropriate directory, your Nix environment will be loaded, in your favourite shell. This also has a massive advantage in that many editors have direnv plugins, which means that they can also load your Nix environment, pulling all your tools and dependencies into your editing environment to give you that wonderful IDE experience.

[nix]: https://nixos.org/
[install nix]: https://nixos.org/download.html
[nixpkgs]: https://nixos.org/manual/nixpkgs/
[nixpkgs on github]: https://github.com/NixOS/nixpkgs
[direnv]: https://direnv.net/
[nix-direnv]: https://github.com/nix-community/nix-direnv
