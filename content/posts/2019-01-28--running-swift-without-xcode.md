---
title: "Running Swift without Xcode"
slug: running-swift-without-xcode
date: 2019-01-28T17:00:00Z
---

On Saturday, I finally finished [Advent of Code 2018][] (and pushed [my solutions][samirtalwar/advent-of-code] to GitHub). I did the whole thing in Swift (except for a couple parts which I did by hand), but I tried to avoid Xcode as much as possible, knowing that it would make automating things a whole lot harder. Instead, I ran everything directly in the command line. It took a while to figure out how to do this, with little official documentation on the subject, so I thought I'd explain how I did this so that anyone searching for it would find the information in one place.

I'm going to focus on command-line applications, though I expect the tips will also be useful for those of you looking to make macOS GUI applications.

[advent of code 2018]: https://adventofcode.com/2018
[samirtalwar/advent-of-code]: https://github.com/SamirTalwar/advent-of-code

<!--more-->

## Prerequisites

Obviously, you'll need Swift installed. On macOS, run `xcode-select --install` to install the command-line tools. And I recommend installing Xcode too. Linux users can follow the instructions on the [download][] page.

As you won't have access to the Swift documentation embedded in Xcode from the command line, it's useful to know where to look. The official guide is [The Swift Programming Language][], and the auto-generated documentation hosted at [SwiftDoc.org][] is also very helpful. I have the latter downloaded and installed into [Dash][] so that it's really fast to search.

The instructions below assume you're on macOS or Linux. If you're on another platform, you might end up with slightly different results, but hopefully things won't change too much.

[download]: https://swift.org/download/
[the swift programming language]: https://docs.swift.org/swift-book/
[swiftdoc.org]: https://swiftdoc.org/
[dash]: https://kapeli.com/dash

## Running a single script file, interpreted

If you're just running a single script file, that's pretty easy. `swift` is your interpreter, and will happily run a single file.

For example, given the following file, _Sum.swift_, which sums the numbers from 1 to 100:

```swift
let numbers = (1 ... 100)
let result = numbers.reduce(0, +)
print(result)
```

You can run it directly with `swift Sum.swift`:

```sh
$ swift Sum.swift
5050
```

You can even add a [_shebang_][shebang] line at the top to make it runnable.

If you add the following line to the top of the file:

```swift
#!/usr/bin/env swift

let numbers = (1 ... 100)
...
```

Then make it executable:

```sh
$ chmod +x Sum.swift
```

It's now runnable:

```sh
$ ./Sum.swift
5050
```

[shebang]: https://en.wikipedia.org/wiki/Shebang_(Unix)

## Running a script file with arguments

Let's say we adapted our program so it summed the numbers from 1 to _N_, where _N_ is provided on the command line:

```swift
#!/usr/bin/env swift

// unsafe code; please use guards and print an error instead
let numbers = (1 ... Int(CommandLine.arguments[1])!)
let result = numbers.reduce(0, +)
print(result)
```

We can run this in the same way, just by providing the argument:

```
./Sum.swift 10
55
```

## Running a single script file, compiled

To compile Swift code on the command line, use the `swiftc` program. You can compile the program we wrote above just by running `swiftc Sum.swift`. This will produce an executable program with the same name as the Swift file, except it won't have the extension. Try it:

```sh
$ swiftc Sum.swift
$ ls
Sum
Sum.swift
$ ./Sum 10
55
```

If you'd like to change the name, you can use the `-o` flag. For example, let's say we're looking to call it "SumFromOneTo", so you can run `./SumFromOneTo 20`:

```sh
$ swiftc -o SumFromOneTo Sum.swift
$ ls
SumFromOneTo
Sum.swift
$ ./SumFromOneTo 20
210
```

### Compiler optimisations

One advantage of compiling a single file is that you can tell the Swift compiler to _optimise_ it. Turning on optimisations makes the compilation process take longer, but can significantly decrease the amount of time it takes the program to run. For example, summing the numbers from 1 to 100,000,000 takes about 30 seconds on my computer:

```sh
$ time ./Sum 100000000
5000000050000000
./Sum 100000000  27.83s user 0.06s system 99% cpu 28.001 total
```

When optimisations are on, it takes no time at all—just under 0.1 seconds on my computer:

```sh
$ swiftc -O Sum.swift
$ time ./Sum 100000000
5000000050000000
./Sum 100000000  0.07s user 0.01s system 95% cpu 0.077 total
```

## Running multiple files, compiled

Our program's getting bigger, and it'd be nice to split it into two files. Let's move all the I/O into a file called _Program.swift_:

```swift
#!/usr/bin/env swift

// unsafe code; please use guards instead
let upper = Int(CommandLine.arguments[1])!
print(sum(to: upper))
```

This means _Sum.swift_ needs to provide a pure function named `sum`:

```swift
func sum(to upper: Int) -> Int {
    let numbers = (1 ... upper)
    let result = numbers.reduce(0, +)
    return result
}
```

To compile multiple files, we just add them all to the command line:

```sh
$ swiftc -o Sum Program.swift Sum.swift
Program.swift:1:1: error: hashbang line is allowed only in the main file
#!/usr/bin/env swift
^
Program.swift:5:1: error: expressions are not allowed at the top level
print(sum(to: upper))
^
```

Uh oh. We get errors. They have the same root cause: we can't write expressions at the top level, so we can't actually _do_ anything. There's one exception, though, and there's a clue in the first error message: you can have a "main file" which provides the entry point to your program.

Let's rename _Program.swift_ to _main.swift_, and try again:

```sh
$ mv Program.swift main.swift
$ swiftc -o Sum main.swift Sum.swift
$ ./Sum 10
55
```

It works! _main.swift_ is special—that's where you can kick off your program. If your program gets larger than one file, I highly suggest putting all the I/O in _main.swift_ and keeping the rest of your program as pure as possible. This way, you can just look in one place to see how it's all wired together, and for the rest, the function and `struct`/`class` signatures will hopefully tell the story.

### Naming your entry point something other than _main.swift_

Sometimes you can't name the file _main.swift_. For example, for Advent of Code, I had almost 50 different programs this year (typically 2 per day), and I didn't want each to have its own directory. So I leveraged a trick.

It turns out that _main.swift_ doesn't need to be in the root of your repository. So I created a file, _2018/Helpers/main.swift_, which contained one line:

```swift
main()
```

Then, in my program's real entry point (e.g. _2018/AOC\_19\_2.swift_), I declared a _main_ function and did all the work in there:

```swift
func main() {
    while let line = readLine() {
        ...
    }
    ...
}
```

When running the program, I include the entry point and everything in the _Helpers_ directory:

```sh
$ swiftc -o build/2018/AOC_19_2 2018/AOC_19_2.swift 2018/Helpers/*.swift
$ ./build/2018/AOC_19_2 < 2018/AOC_19.input
<answer redacted>
```

This means that only one `func main() { … }` declaration is included at a time, so there's no ambiguity.

If you'd like to see how this is automated, check out [my `run` script][samirtalwar/advent-of-code: run].

[samirtalwar/advent-of-code: run]: https://github.com/SamirTalwar/advent-of-code/blob/master/run

## Creating a package (with dependencies)

I'm gonna be honest: I didn't bother. I just used the Swift standard library and my own code. If you'd like to set up the build system with dependencies, I'm led to believe you can check out the [Swift Package Manager][]. Enjoy!

[swift package manager]: https://swift.org/package-manager/
