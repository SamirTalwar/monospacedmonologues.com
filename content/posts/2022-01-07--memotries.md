---
title: "Transparent memoisation in Haskell with MemoTries"
slug: memotries
date: 2022-01-07T16:30:00Z
---

Last month I participated in [Advent of Code][], along with a bunch of friends and colleagues. Typically I prefer to use Advent of Code as a mechanism to learn a new programming language, but after not finishing the last couple of years, I wanted to make life easier for myself, so I decided to use Haskell and give myself a little break.

Haskell is a language designed to effectively express computations. As such, functions are “pure”: they may have no side effects. Even I/O is handled by returning a sequence of instructions which are then actually enacted by the VM. This is incredibly useful when solving logic puzzles such as Advent of Code; you never have to worry about accidentally modifying something, because you _can’t_.

However, it makes memoisation very difficult.

This article is based on the paper, [“Memo functions, polytypically!”, by Spenser Jannsen][memo functions, polytypically!], and the Haskell project [MemoTrie][]. Almost none of the ideas are mine; if you’re interested in going deeper, I recommend starting with those.

### A brief primer on memoisation

_Memoisation_ (or “memoization”, if you’re American) is the act of invisibly recording inputs to functions and caching the outputs, so that a second call to the same function responds instantly with the cached value. This needs to be done without exposing the details of the memoisation outside; it should be a drop-in replacement. This is really helpful in certain algorithms, because it allows us to avoid explicit caching for performance.

<!--more-->

Typically, we _memoise_ a function by wrapping it in another function that caches the results. It might look like this in Python:

```python
def fib(n):
    if n == 0:
        return 0
    elif n == 1:
        return 1
    else:
        return memoisedFib(n - 2) + memoisedFib(n - 1)

def memoise(f):
    computed = {}
    def memoisedF(x):
        if x in computed:
            return computed[x]
        else:
            computed[x] = f(x)
            return computed[x]
    return memoisedF

memoisedFib = memoise(fib)
```

Here we have a naive, slow, Python function that computes a Fibonacci number recursively. Running `fib(40)` without memoisation takes a few seconds on my computer, because it recomputes the same value many times. However, with memoisation, it’s instant, as it remembers the result for each input and only computes it once.

We can use this technique to cheaply speed up a function we know we will be calling many times with the same input. Often, there is another solution that doesn’t require this, but sometimes it can be harder to read or require a rewrite; memoisation can be a lot cheaper.

### And why this doesn’t work

However, you can’t do that in Haskell. The code above mutates a dictionary, and mutation is a side effect. In order to perform a mutation, we would need to represent that in the type. So while the function itself would look like this:

```haskell
fib 0 = 0
fib 1 = 1
fib n = fib (n - 2) + fib (n - 1)
```

The memoised version might look like this:

```haskell
memoize :: (Eq a, Ord a) => (a -> State (Map a b) b) -> a -> State (Map a b) b
memoize f x = do
  computed <- get
  case Map.lookup x computed of
    Just result ->
      return result
    Nothing -> do
      result <- f x
      modify $ Map.insert x result
      return result

fib :: Integer -> State (Map Integer Integer) Integer
fib 0 = return 0
fib 1 = return 1
fib n = do
  a <- memoisedFib (n - 2)
  b <- memoisedFib (n - 1)
  return $ a + b

memoisedFib = memoise fib
```

Note the change in the type signature. This function needs to carry around state, and so that’s reflected in the signature. This means we can’t simply swap out our old `fib` for this faster version. If we were to use this, the rest of the code would have to change accordingly to accommodate the new type. And, because it’s recursive and therefore needs to call `memoisedFib`, even the original implementation needs to be modified to carry around the state.

And we need to call it in a strange way, to pass an initial state in, and then discard it later:

```haskell
λ evalState (fib 40) Map.empty
102334155
```

However, there’s a trick we can use to get the same benefits of memoisation, without having to change the type signature of the function. This relies on laziness.

If you’re not familiar with laziness in Haskell, you’re in luck: [I wrote an article just for you][laziness in haskell]. Please go read it. And when you’re done, come back.

### Tries, or general-purpose lazy data structures

A _trie_ (confusingly pronounced “tree”, and sometimes referred to as a “prefix tree” or “digital tree”), is a way of representing data in a more compact space.

For example, let’s say we have a set of strings:

```haskell
["apple", "avocado", "banana", "cabbage", "cherry", "chive", "lemon", "lettuce"]
```

We can represent this in a little less space by creating a tree of common prefixes:

```haskell
{
  "a" -> {"pple" -> {}, "vocado" -> {}}
  "banana" -> {}
  "c" -> {
    "abbage" -> {}
    "h" -> {"erry" -> {}, "ive" -> {}}
  }
  "le" -> {"mon" -> {}, "ttuce" -> {}}
}
```

This won’t always be more space-efficient, but sometimes it can really help. However, it also has another upside: it allows us to be lazy about each node.

In a Haskell list, the head and tail are individually evaluated on demand; if you never want to see the tail, it’s never computed. This is true for any data structure. For example, we can create a data structure representing an `if`/`else` construction, and look them up based on a boolean value.

```haskell
data If a = If a a

select True  (If ifTrue _)  = ifTrue
select False (If _ ifFalse) = ifFalse

if' condition ifTrue ifFalse = select condition (If ifTrue ifFalse)

-- example:
λ let things = If 3 5
λ select True things
3
λ select False things
5
λ if' True 7 2
7
```

We can prove this is lazy by causing a failure if one of the branches is reached, but not the other:

```haskell
λ let broken = If (error "Whoops.") "Hi!"
λ select False broken
"Hi!"
λ select True broken
"*** Exception: Whoops.
CallStack (from HasCallStack):
  error, called at <interactive>:1:1 in interactive:Ghci4
```

The data structure was constructed with an exception, but we only triggered the exception when we evaluated that path of the data structure; if we hadn’t gone there, it would never have been evaluated.

And just like the list of Fibonacci numbers from that laziness article, we can put values in these data structures that are expensive to compute, and only ask for what we need.

### Memoising booleans

If you can express a computation operationally, you can also express it as a data structure. We already saw this for Fibonacci numbers in the last post, and `if`/`else` above. In general, a function, `input -> output`, can be modelled as a data structure that maps inputs to outputs. In the case of the Fibonacci sequence, the most obvious mapping was a list (which could be thought of as a mapping from integers to integers); with `if`/`else`, it was a data structure with two values, `a` and `b`.

We can do this more generically.

```haskell
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

class HasTrie input where
  -- Yes, the name of the data type here is ":->:"; just roll with it
  data input :->: output

instance HasTrie Bool where
  data Bool :->: output = BoolTrie output output

select :: Bool -> (Bool :->: output) -> output
select True  (BoolTrie _ ifTrue)  = ifTrue
select False (BoolTrie ifFalse _) = ifFalse

if' :: Bool -> output -> output -> output
if' condition ifTrue ifFalse = select condition (BoolTrie ifTrue ifFalse)
```

Once we have that structure, we can add conversion functions back and forth between functions and tries.

```haskell
class HasTrie input where
  infixr 2 :->:  -- sets the precedence
  data input :->: output
  trie :: (input -> output) -> input :->: output
  unTrie :: (input :->: output) -> input -> output

instance HasTrie Bool where
  data Bool :->: output = BoolTrie output output
  trie f = BoolTrie (f False) (f True)
  unTrie (BoolTrie ifFalse _) False = ifFalse
  unTrie (BoolTrie _ ifTrue)  True  = ifTrue
```

We can see here that `select` is just `unTrie` with the arguments flipped. And so we can define `if'` as such:

```haskell
if' :: Bool -> output -> output -> output
if' condition ifTrue ifFalse = unTrie (trie f) condition
  where
    f True  = ifTrue
    f False = ifFalse
```

This is exactly the same as the standard `if` structure in Haskell… except it constructs a data structure in the middle. Right now it’s not very useful, but if we flip the arguments, suddenly everything changes.

There is a function in the Haskell standard library, `bool`, which is effectively a reversed form of `if'`:

```haskell
bool :: a -> a -> Bool -> a
bool x y p = if p then y else x
```

If we redefine this using our `trie` and `unTrie` functions above, a really wonderful property falls out:

```haskell
bool' :: a -> a -> Bool -> a
bool' ifFalse ifTrue = unTrie (trie f)
  where
    f False = ifFalse
    f True = ifTrue
```

It's very important that `bool'` does not receive the `condition` parameter, because we don't want to evaluate `unTrie (trie f)` once for each `condition` argument; we want to evaluate it once for all conditions.

We can use this to construct a function of type `Bool -> output`:

```haskell
someFibs :: Bool -> Integer
someFibs = bool' (fib 30) (fib 40)
```

And once we’ve done that, we can call it:

```haskell
λ :set +s
λ someFibs False
832040
(2.52 secs, 921,589,872 bytes)
λ someFibs False
832040
(0.01 secs, 70,472 bytes)
```

You see what happened there? Calling `fib 30` the first time took around 2.5s and a gigabyte of memory. The second time, it was instant, because the result was cached in the `BoolTrie`.

Our `trie` and `unTrie` functions effectively memoised the function, `f`. This is totally generalisable:

```haskell
memo :: (a -> b) -> a -> b
memo f = unTrie (trie f)

-- or, point-free:
memo :: (a -> b) -> a -> b
memo = unTrie . trie
```

### Everything is a trie

This works for booleans. Can we do this for other values too?

It turns out, yes. Haskell data types are modelled as _sums of products_, and it turns out there’s a mechanical transformation from a data type to the corresponding trie type.

Booleans are defined as a sum type: `data Bool = False | True`, which becomes a trie with two values. This works for all sum types. For example, `Maybe a` becomes a trie as follows:

```haskell
instance HasTrie a => HasTrie (Maybe a) where
  data Maybe a :->: output = MaybeTrie output (a :->: output)
  trie f = MaybeTrie (f Nothing) (trie (f . Just))
  unTrie (MaybeTrie ifNothing ifJust) = maybe ifNothing (unTrie ifJust)
```

`MaybeTrie` is a data structure with a value that corresponds to `Nothing`, and a trie that corresponds to `Just a`.

We can transform `Either a b` to a trie in a similar fashion.

```haskell
instance (HasTrie a, HasTrie b) => HasTrie (Either a b) where
  data Either a b :->: output = EitherTrie (a :->: output) (b :->: output)
  trie f = EitherTrie (trie (f . Left)) (trie (f . Right))
  unTrie (EitherTrie ifLeft ifRight) = either (unTrie ifLeft) (unTrie ifRight)
```

So, we can see that sum types of the form `a | b | c` become tries of the form `Trie a b c`.

There’s also a mechanical transformation for products. Let’s take the tuple type:

```haskell
instance (HasTrie a, HasTrie b) => HasTrie (a, b) where
  newtype (a, b) :->: output = Tuple2Trie (a :->: b :->: output)
  trie f = Tuple2Trie $ trie $ \a -> trie $ \b -> f (a, b)
  unTrie (Tuple2Trie f) (a, b) = unTrie (unTrie f a) b
```

Tuples become nested tries, which kind of makes sense: the prefix of `(a, b)` is `a`. This holds for all product types, too.

Now that we can handle sum and product types, we can turn a list into a trie. Lists are defined in Haskell something like this:

```haskell
data [a] = [] | a : [a]
```

There’s a lot of operators in there, so think of it like this if it’s easier:

```haskell
data List a = Nil | Cons a (List a)
```

That is, it’s the sum type of `[]` (or `Nil`) and the product `a : [a]` (or `Cons a (List a)`). So we can transform this like a combination of `Maybe` and tuples.

```haskell
instance HasTrie a => HasTrie [a] where
  data [a] :->: output = ListTrie output (a :->: [a] :->: output)
  trie f = ListTrie (f []) (trie $ \x -> trie $ \xs -> f (x : xs))
  unTrie (ListTrie ifNil _) [] = ifNil
  unTrie (ListTrie _ ifCons) (x : xs) = unTrie (unTrie ifCons x) xs
```

We can check if this works, for example, by memoising the Fibonacci number function _after_ we have converted a list of booleans representing little-endian bits to a number. Let’s define some conversion functions:

```haskell
-- these won't work for negative numbers
bits :: Integral a => a -> [Bool]
bits 0 = []
bits n = (n `mod` 2 == 1) : bits (n `div` 2)

unBits :: Integral a => [Bool] -> a
unBits [] = 0
unBits (False : bits) = 2 * unBits bits
unBits (True  : bits) = 2 * unBits bits + 1

λ bits 10
[False,True,False,True]
λ bits 99
[True,True,False,False,False,True,True]
λ unBits (bits 99)
99
```

Now we’ve done that, we can create a slow Fibonacci function that works on bits:

```haskell
fibBits :: [Bool] -> [Bool]
fibBits = bits . fib . unBits
```

But the real power here is that `[Bool] -> output` can be converted to a trie, and therefore we can memoise it. Let’s do that:

```haskell
memoFib :: Integer -> Integer
memoFib = unBits . memo (bits . memoFib' . unBits) . bits
  where
    memoFib' 0 = 0
    memoFib' 1 = 1
    memoFib' n = memoFib (n - 2) + memoFib (n - 1)

λ memoFib 30
832040
(0.01 secs, 811,520 bytes)
```

We’ve gone from `fib 30` taking 2.5s to almost no time at all, just like the Python version, because we recurse over the memoised function. And unlike our first attempt, there is no change to the type signature; we get the caching “for free”. (Of course, if your trie becomes huge, you will pay the price, but let’s pretend that won’t happen.)

This is a little clunky. Fortunately, we have all the building blocks to define a trie over integers; after all, aren’t they just lists of bits? So let’s define it as such:

```haskell
instance HasTrie Integer where
  newtype Integer :->: output = IntegerTrie ([Bool] :->: output)
  trie f = IntegerTrie $ trie (f . unBits)
  unTrie (IntegerTrie bitTrie) = unTrie bitTrie . bits
```

And now we can simplify the definition of `memoFib`:

```haskell
memoFib :: Integer -> Integer
memoFib = memo memoFib'
  where
    memoFib' 0 = 0
    memoFib' 1 = 1
    memoFib' n = memoFib (n - 2) + memoFib (n - 1)
```

### Odds and ends

There’s a library for all that, of course. You don’t have to write it yourself. It’s called [MemoTrie][], and you can find it on Hackage. That said, it’s pretty easy to implement this if you want to, or if you want slightly different semantics.

I ended up copying the library in parts, just so I could actually understand what was going on. In doing so, I found a couple of cool tricks. The main one I wanted to share with you here is that if you’re going to memoise a function that takes multiple parameters, of the form:

```haskell
f :: a -> b -> c -> d
```

I recommend uncurrying it first, and writing the appropriate tuple trie if it doesn’t already exist:

```haskell
f' :: (a, b, c) -> d
f' = uncurry3 f
```

If you use the `memo3` function from the package (which recursively applies `memo`), you may end up discarding tries which could be handy later, because they only exist in the scope defined by the nested function. By converting to a tuple first, you ensure that you keep all data around for as long as you need it.

Aside from this small quirk, it’s a wonderful library, and I hope it serves you well.

[advent of code]: https://adventofcode.com/
[laziness in haskell]: /2022/01/laziness-in-haskell/
[memo functions, polytypically!]: http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.43.3272
[memotrie]: https://hackage.haskell.org/package/MemoTrie
