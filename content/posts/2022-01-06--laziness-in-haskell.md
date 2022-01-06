---
title: "Laziness in Haskell"
slug: laziness-in-haskell
date: 2022-01-06T17:00:00Z
---

_A precursor, so that I never have to explain this again._

Haskell is often called a “lazy” language. This means that it doesn’t compute anything until it has to.

This allows for a host of interesting behaviour. One of the simplest is infinite sequences. Lists in Haskell are lazy (like anything else, by default). This means that the head of the list can be inspected without computing the tail, or vice versa.

For example, I can define a sequence that is just the value `7` over and over again:

```haskell
sevens = 7 : sevens

λ sevens
[7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7^CInterrupted.
λ take 10 sevens
[7,7,7,7,7,7,7,7,7,7]
```

(I had to hit _Ctrl+C_ to cancel the generation of sevens the first time, because it would just go on forever.)

Or we can generate a list of incrementing numbers:

```haskell
numbers = [0..]

λ head numbers
0

λ numbers !! 5
5

λ take 20 numbers
[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]
```

This works because In Haskell, a list is a pair of `(head, tail)`. In memory, `numbers` will look something like this:

```haskell
List { head = <thunk>, tail = <thunk> }
```

A “thunk” is an unevaluated value; once we read it, it’ll compute and resolve to the expected value, after which it will be saved (until the entire data structure is thrown away).

<!--more-->

Once we ask for the head, it will be partially evaluated to something like this:

```haskell
List { head = 0, tail = <thunk> }
```

After retrieving the element at index 5, it will be something like this:

```haskell
List {
  head = 0,
  tail = List {
    head = <thunk>,
	  tail = List {
	    head = <thunk>,
		  tail = List {
		    head = <thunk>,
			  tail = List {
			    head = <thunk>,
				  tail = List {
				    head = 5,
				    tail = <thunk>
				  }
			  }
		  }
	  }
  }
}
```

And once we compute the first 20 elements, we’ll have 20 nested lists, with evaluated heads, after which we’ll have a thunk as a tail.

### Laziness and performance

Now, let’s take the classic Fibonacci sequence as an example. As a reminder, this sequence is a sequence of numbers starting with `0, 1`, in which each subsequent number is computed by adding the two previous numbers. It goes like this:

```
0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55 ...
```

We can generate this in Haskell by defining a function, and then creating a list that calls that function. Here’s a naive implementation which is very slow for large enough values of `n` (e.g. `n` > 20):

```haskell
fib 0 = 0
fib 1 = 1
fib n = fib (n - 2) + fib (n - 1)

fibs = map fib [0..]
```

Nothing is actually evaluated. It’s only when we try and do something with a specific value in the list (e.g. print it) that it’s computed. For example, on my machine, the 31st Fibonacci number (index 30, because it’s zero-based) takes 2.5s to compute, and about a gigabyte of memory:

```haskell
-- This switch turns on timing information for simple REPL benchmarking
λ :set +s
λ fibs !! 30
832040
it :: Integer
(2.66 secs, 921,594,184 bytes)
```

We didn’t need to compute the whole list to get that value, which is good, because it’s infinite, and so computing the whole list would take infinite time and space.

Usually this is unnoticeable, but you might spot it if you try and do something long-running twice. The first time will take a while. The second time, it’ll be instant.

```haskell
λ fibs !! 30
1346269
it :: Integer
(0.01 secs, 71,184 bytes)
```

Only the head at index 30 has been computed, but it’s saved as long as there is a live reference to `fibs`.

(Note that if you define the `fibs` value in the REPL, it won’t be cached. I’m not entirely sure why, but remember to write your code in a file, and load it into the REPL.)

### Laziness as computation

That implementation of the Fibonacci sequence above is slow. We can probably do better. A linear solution might count upwards, instead of recursing downwards:

```haskell
fibLinear n = fibLinear' n 0 1
  where
  fibLinear' 0 result _ = result
  fibLinear' n a b = fibLinear' (n - 1) b (a + b)
```

However, it’s a lot more verbose, and we’ve lost some of the essence of the previous implementation, which mapped pretty well onto the definition of the sequence. By contrast, this version is iterative, not declarative; it describes how to get the value at `n`, not what it _is_.

I’d like to show you a trick. We can use the nature of lazy lists so that we compute the Fibonacci sequence and cache intermediate values, all in one go.

We start with the first two values:

```haskell
fibs = 0 : 1 : ...
```

Now, the nature of the Fibonacci sequence is as follows: given the two previous values, we know the next one. This can be seen as the sum of two sequences:

```
      0   1   1   2   3   5   8  13  21  34  55 ...
 +    1   1   2   3   5   8  13  21  34  55 ...
 =    1   2   3   5   8  13  21  34  55
```

That is, the Fibonacci sequence is the zipped sum of two sequences: the Fibonacci sequence, and the Fibonacci sequence.

What?

Well, we’re not working with the exact same sequence here. It would be more correct to say that the Fibonacci sequence starting from index 2 is the zipped sum of the Fibonacci sequence starting from index 1 and the Fibonacci sequence starting from index 0.

i.e.

```haskell
-- not valid code
tail (tail fibs) = zipWith (+) fibs (tail fibs)
```

Or, if we add the first two values back in, we get something that again, aligns pretty closely to the mathematical definition:

```haskell
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)
```

It turns out this is a completely legitimate definition of the Fibonacci sequence, thanks to laziness. We don’t need the whole list, just the parts that we need to access. By the time we need to access the value at index 2, indices 0 and 1 have already been computed. And likewise for each subsequent value in the list.

```haskell
λ take 50 fibs
[0,1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597,2584,4181,6765,10946,17711,28657,46368,75025,121393,196418,317811,514229,832040,1346269,2178309,3524578,5702887,9227465,14930352,24157817,39088169,63245986,102334155,165580141,267914296,433494437,701408733,1134903170,1836311903,2971215073,4807526976,7778742049]
it :: [Integer]
(0.01 secs, 310,248 bytes)
```

Finally, we can define `fib` in terms of `fibs`, instead of the other way around:

```haskell
fib n = fibs !! n

-- or, point-free:
fib = (fibs !!)
```

With this new implementation, we only ever compute each Fibonacci number once, after which it’s cached and retained for subsequent calls. This is not only available to the caller as a (somewhat) free implementation of caching, but is also used internally in the very definition of the sequence.

Next time, I hope to show you how you can generalise this principle for caching and memoisation.
