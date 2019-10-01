---
title: "Smoke v2.1 is out!"
slug: smoke-v2-1-is-out
date: 2019-10-01T16:00:00Z
---

I've just released version 2.1.0 of [_Smoke_][smoke], my integration test framework for command-line applications.

The major feature: if your command-line application produces files, you can now test their contents.

The [release notes][smoke release v2.1.0] explain all:

<!--more-->

> Smoke v2.1.0 is out! It's actually been in the works for months now—I kind of forgot about it.
>
> ### Notable features:
>
> - you can now compare files to their expected contents with `files:`
>   - works just like `stdout` and `stderr`
>   - you can compare against inline text or another file
>   - use filters too
>   - revert directories afterwards to clean up with `revert:`
>   - the [_files_ fixture](https://github.com/SamirTalwar/Smoke/tree/v2.1.0/fixtures/files) has more examples
> - set the working directory with `working-directory:`
>   - check out the different usages in the [_working-directory_ fixture](https://github.com/SamirTalwar/Smoke/tree/v2.1.0/fixtures/working-directory)
> - use a shell command rather than a list of arguments
>   - much easier
>   - uses `sh` on Linux/macOS, and `cmd` on Windows (by default)
>   - you can override the shell with `shell:`
>   - check out the [_shell_ fixture](https://github.com/SamirTalwar/Smoke/tree/v2.1.0/fixtures/shell) for more possibilities
>
> ### UX improvements:
>
> - output comes per test now, not all at once (sorry about breaking that in v2.0)
> - nomenclature is consistent between the test files and the output
>
> ### Bug fixes:
>
> - absolute paths are now properly supported

Please try it out and let me know what you think! You can download the binaries from [the release page][smoke release v2.1.0].

[smoke]: https://github.com/SamirTalwar/Smoke
[smoke release v2.1.0]: https://github.com/SamirTalwar/Smoke/releases/tag/v2.1.0
