---
title: "Running Agda with Nix"
slug: running-agda-with-nix
date: 2021-05-06T16:00:00Z
---

I like to keep even traditionally system-level dependencies isolated and pinned per-project, so I use [Nix][] for that.

I have been playing with [Agda][] for a while now, and it has been a joy to work with a theorem proof assistant for the first time. (I am hoping to write some more on the topic when I am more familiar with it, but for now, I'll just recommend Wadler, Kokke, and Siek's excellent and free book, [Programming Language Foundations in Agda][].)

I found it a bit of a pain to configure Agda with Nix, and I haven't found this advice anywhere else, so I thought I'd document it so someone else searching for the same thing doesn't struggle quite so much.

I am assuming, for the sake of this guide, that you are using Agda with Emacs, which is the only real way to use it due to its heavy editor integration.

So, follow along to set up this combination of incredibly niche tools that you almost certainly have zero interest in. 😜

<!--more-->

## Global Agda

First of all, you need to install Agda in a manner that's available to your Emacs installation at startup (i.e. it's on the path). This means that if you run Emacs as a GUI program, as opposed to launching in a terminal, Agda needs to be available on your PATH. This is unfortunate, but seems to be a problem with the Emacs mode, in that it initializes and finds the path to the `agda-mode` binary on startup, not when the first Agda file is opened.

So, you need to install Agda globally. If you use [Home Manager][], just add `agda` to your `home.packages` list. Otherwise, you can install it using `nix-env --install agda`.

This means that the version of Agda you're pinning needs to align with the version of Agda installed globally. If this is a problem for you, consider finding a way of running Emacs so that it picks up the Nix PATH for your project.

## Local Agda

Next up, configure your local project environment to pull in Agda and all the packages you need (which will probably be at least the standard library). You can do this in your _shell.nix_ file, which at a minimum, will look something like this:

```nix
{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  buildInputs = [
    (agda.withPackages (ps: [
      ps.standard-library
    ]))
  ];
}
```

This snippet initializes `pkgs` to use whatever copy of `nixpkgs` you have in your Nix channels, and then grabs Agda with its standard library. You can add more libraries to the list.

Once you have that, configure your project with the same libraries, by creating a file named _<project-name>.agda-lib_ that looks something like this:o

```
name: <project name>
include:
  src
depend:
  standard-library
```

The `include:` section here specifies that all source files will live in the _src_ directory, which you can change. You can also add new source directories.

The `depend:` section should mirror the dependencies specified in _shell.nix_.

## Emacs mode

You'll need the Emacs mode loaded. If you're using [Spacemacs][] (at least the `develop` branch… trunk is woefully behind), add the `agda` layer. If it's vanilla Emacs, run `agda-mode setup`.

## Automatic initialization with direnv

This is not completely necessary, but I find it easier than loading the Nix paths myself.

First of all, install [direnv][], [nix-direnv][], and [emacs-direnv][], which allow for automatic project initialization when you `cd` into a project directory. (Don't worry, you have to type `direnv allow` before it will do anything.)

Then create a file named _.envrc_, that looks like this:

```bash
#!/usr/bin/env bash

use nix
```

When you type `direnv allow`, this will load the Nix environment from _shell.nix_, just like `nix-shell` would, except you don't need to enter a shell. Similarly, when you open a file in this directory in Emacs, it will now load your Nix environment.

## Create your first Agda file

OK, we're ready to go.

Make a file named _src/Hello.agda_ and open it in Emacs. The Emacs mode should load. The first thing you might see is an error that looks like this:

```
Library 'standard-library' not found.
Add the path to its .agda-lib file to
  '<some path>'
to install.
Installed libraries:
  (none)
```

This is because while you have Agda installed globally, that installation doesn't know about the standard library. If you reload Agda mode using `C-c C-x C-r` (or `, x r` in Spacemacs), it will reload using the new PATH and find the standard library.

Next, let's write a little program.

```agda
module Hello where

open import Agda.Builtin.IO using (IO)
open import Data.String using (String)
open import Data.Unit using (⊤)

-- Pull in `putStrLn` from Haskell
postulate putStrLn : String → IO ⊤
{-# FOREIGN GHC import qualified Data.Text as T #-}
{-# COMPILE GHC putStrLn = putStrLn . T.unpack #-}

main : IO ⊤
main = putStrLn "Hello world!"
```

Load the file using `C-c C-l` (`, l`) in Emacs. You should see some colours show up. This means the file was loaded correctly and everything checks out.

If this all worked out, you have Agda working with Nix in Emacs. (If not, please comment so I can help you figure out what's wrong and update this post.)

Because this file has a `main : IO _` function, you can compile it with `agda -c src/Hello.agda` (which will take a while) and then run it with `./src/Hello`. However, you probably won't want to _run_ your Agda module most of the time, so `C-C C-l` / `, l` will be your main companion when verifying your proofs.

Happy proving!

[agda]: https://agda.readthedocs.io/en/latest/
[direnv]: https://direnv.net/
[emacs-direnv]: https://github.com/wbolster/emacs-direnv
[home manager]: https://github.com/nix-community/home-manager
[nix]: https://nixos.org/
[nix-direnv]: https://github.com/nix-community/nix-direnv
[programming language foundations in agda]: https://plfa.github.io/
[spacemacs]: https://develop.spacemacs.org/
