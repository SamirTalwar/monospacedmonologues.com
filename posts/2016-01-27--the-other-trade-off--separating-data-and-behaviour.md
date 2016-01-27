# The Other Trade-off: Separating Data and Behaviour

True object-oriented programming brings with it a set of trade-offs: while you [couple data to behaviour][Why Couple Data to Behaviour?], you get a large number of advantages as well. Now let's look at it from the other side.

Yesterday, in our `Account` class, we had a `Transaction` type, one of the implementations being `Withdrawal`. Let's take a look at that in broader detail.

    class Withdrawal implements Transaction {
        private final Money amount;
        private final LocalDate date;

        // constructor, getters (no setters), equals, hashCode and toString.
    }

Now, that's not very useful in our object-oriented world, as it has no behaviour—it's just a holder of some data. One useful behaviour of withdrawals might be to be treated as a transformation on a balance—that is, they might apply themselves to a balance to create a balance that had the amount deducted.

    interface Transaction {
        Money apply(Money balance);
    }

    class Withdrawal implements Transaction {
        private final Money amount;
        private final LocalDate date;

        // constructor

        @Override
        public Money apply(Money balance) {
            return balance.minus(amount);
        }
    }

Of course, the `Deposit` class would look pretty similar. Great, job done. No [exposed getters][Getters, Setters and Properties], and it does the right thing. And we can add more transaction types trivially, just by implementing the `apply` method!

Wait. Are there more transaction types?

So far, there are `Deposit` and `Withdrawal` objects. We could also name them `Debit` and `Credit`. Are there any others? I can't think of any in this circumstance. When I try to think of extended functionality related to transactions, I think of new *behaviours*. For example, what if we wanted to view all transactions for a given date, or a given month? Perhaps we might like to see only withdrawals, so we can get a feel for how much spending there is? Maybe we want to tie together a withdrawal in a customer's current account with a deposit in their savings account so we can understand how they're saving money?

Lots of potential behaviours, but the types of data are few. This means that adding a new feature probably requires requires changing three different files, which [breaks the open-closed principle][Why Couple Data to Behaviour?]… not exactly great.

Now let's look at an alternative implementation. I'll be using Scala for these examples, but I will try and explain them for people who are not so familiar with the language or functional concepts.

Here's our original classes, but in Scala this time:

    sealed trait Transaction

    case class Deposit(amount: Money, date: LocalDate) extends Transaction

    case class Withdrawal(amount: Money, date: LocalDate) extends Transaction

This is simply a much terser version of the same thing (Scala's good at terse). We have a `trait` (which you can pretend is an `interface`), `Transaction`, and two implementations, each of which have two immutable properties, `amount` and `date`. In Scala, mutability is the exception, and so they have no setters.

All of that is fairly routine. The important part is the keyword `sealed`. What this means is that this `trait` can only be extended by classes in the same file. We can't extend it anywhere else. As we only have two types of transaction and aren't planning on adding any more, this isn't a problem.

Now, of course, that behaviour needs to go somewhere, so let's create a function that loops through a sequence of transactions and applies each one to a balance:

    class Transactions(transactions: Seq[Transaction]) {
      def applyTransactions(balance: Money): Money = {
        var currentBalance = balance
        transactions.foreach {
          case Deposit(amount, _) =>
            currentBalance += amount
          case Withdrawal(amount, _) =>
            currentBalance -= amount
        }
        currentBalance
      }
    }

A few things. First of all, `case` is much more powerful in Scala than in Java, allowing us to deconstruct objects according to their construction. Secondly, that block passed to `foreach` is really a function; you can think of it as a lambda without an arrow. Thirdly, Scala has operator overloading, so `+=` and `-=` are really calling methods named `+` and `-`.

In case you're curious about the functional equivalent, you can do the same thing with `foldRight`:

    class Transactions(transactions: Seq[Transaction]) {
      def applyTransactions(balance: Money): Money = {
        transactions.foldRight(balance) { (currentBalance, transaction) =>
          transaction match {
            case Deposit(amount, _) => currentBalance + amount
            case Withdrawal(amount, _) => currentBalance - amount
          }
        }
      }
    }

Either way, this function applies each transaction in turn to the original balance to calculate the new balance.

Now, let's add a new feature. Perhaps we want to know all the transactions on a given date:

      def transactionsOn(date: LocalDate): Seq[Transaction] =
        transactions.filter {
          case Deposit(_, transactionDate) => date == transactionDate
          case Withdrawal(_, transactionDate) => date == transactionDate
        }

Because the date is not part of the interface, even though both the `Deposit` and the `Withdrawal` types have dates, we need to decompose them. We could add the date to the `Transaction` trait to make this easier, but doing the same thing with `amount` would be a bad idea, because the amount really does mean a different thing for each implementation.

Or maybe we'd like to know about just the amount being spent:

      def amountWithdrawn: Money =
        transactions
          .collect { case withdrawal: Withdrawal => withdrawal }
          .map(_.amount)
          .sum

This function filters for withdrawals, extracts the amounts from the withdrawals, and then sums them to get the total amount withdrawn.

Notice that these functions are independent of any `Transaction` object. They generally operate on sequences of transactions, and so it makes sense that they exist on the `Transactions` class. Each cares about a different facet of the two implementations of `Transaction`. What's more, it was easy to add each one: we just had to add more code, not change existing code and potentially break existing functionality. This is something that an object-oriented design would have made *harder*. By contrast, adding a new implementation of `Transaction` would be quite difficult, as every function would need to be changed to add a new case to the pattern-match.

Just like object-oriented programming, structured (and therefore imperative or functional) programming has a set of trade-offs. Structured programming allows us to quickly add behaviour to fixed data representations, but adding new data representations is much trickier. Often, this is what we need, and it would be a misuse of object-oriented design to push the behaviour too deep into classes. Good software development includes designing for maintainability, and this means we need to make predictions about what might change in the future, then design accordingly.

[Why Couple Data to Behaviour?]: http://monospacedmonologues.com/post/138076164433/why-couple-data-to-behaviour
[Getters, Setters and Properties]: http://monospacedmonologues.com/post/138009972532/getters-setters-and-properties
