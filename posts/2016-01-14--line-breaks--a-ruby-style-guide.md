# Line Breaks: A Ruby Style Guide

I don't mean "style guide" as in a full guidebook, but rather a guide to styling Ruby with regard to two very specific circumstances: when to use **parentheses** on function and method invocation, and whether to use **braces or `do … end`** for blocks.

This is my personal recommendation and the style I try to follow. I couldn't really care less what you use as long as you're consistent inside a single project.

## Blocks

When passing a block to a method that returns a new value, with no side effects, use braces. This allows for easy chaining.

    (1..10)
      .collect { |n| n + 10 }
      .select(&:even?)
    #=> [12, 14, 16, 18, 20]

However, if the method does have side effects, use `do` and `end`. This makes it very clear that something is happening, and makes chaining very ugly.

    (0...10)
      .collect { |n| (n + 'a'.ord).chr }
      .each do |letter|
        puts letter
      end

When possible, avoid entirely methods that look like the former but are actually the latter.

    numbers = (1..10).to_a
    numbers.collect! { |n| n + 10 } # AVOID!

If they must be used, prefer the form with braces, as the `!` character makes it quite clear that the operation is destructive anyway, and these methods are often more useful when chained.

## Calling Functions

When calling functions or methods that take input and return output, with no side effects, use parentheses.

    (1..1000).take(5)
    #=> [1, 2, 3, 4, 5]

When calling a method on an object that takes no arguments and returns information on the object state, do not use parentheses, as this should look like property access:

    numbers = [1, 2, 3, 4, 5]
    numbers.length #=> 5

When calling a method that has side effects, avoid parentheses. This shows that the method makes a change to the outside world, and also prevents us from using multiple methods with effects on a single line.

    puts numbers

    describe 'number' do
      it 'can be added to another number' do
        expect(5 + 2).to eq(7)
      end
    end

In the RSpec example above, `describe` and `it` have side effects. `expect` and `eq` do not, but `to` does.

When calling a method that takes a block, avoid parentheses.

    numbers.collect { |n| n * 2 }
    #=> [2, 4, 6, 8, 10]

## Bonus: Declaring Functions

Always use parentheses.

    def dance(count = 3)
      count.times do
        puts <<-EOS
          ALL THE SINGLE LADIES
                (•_•)
                <) )╯
                / \\
          ALL THE SINGLE LADIES
                (•_•)
                \\( (>
                  / \\
        EOS
      end
    end
