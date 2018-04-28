Yesterday I posted on avoiding [Getters, Setters and Properties][], and how to bring the behaviour of your system closer to your data. The more functionally astute of you might have realised that this is, of course, a form of coupling. By making state private, and only allowing access via methods, we need to *open* up the class each time we want to modify the behaviour. This makes it look like proper object-oriented programming *must* violate the [open-closed principle][Open-Closed Principle]:

> Software entities (classes, modules, functions, etc.) should be open for extension, but closed for modification.
>
> <cite>Bertrand Meyer, in <em><a href="http://www.amazon.co.uk/gp/product/0136291554/ref=as_li_tl?ie=UTF8&camp=1634&creative=19450&creativeASIN=0136291554&linkCode=as2&tag=monospamonolo-21">Object-Oriented Software Construction</a></em>, 1988.</cite>

Let's take the example from yesterday:

    public class Account {
        private Money balance;
        private List<Transaction> transactions;

        public Money getBalance() {
            return balance;
        }

        ...
    }

    public class ATM {
        public void withdraw(Account account, Money amount, LocalDate date) {
            Money newBalance = account.getBalance().minus(amount);
            account.setBalance(newBalance); // could throw if we can't withdraw enough
            account.getTransactions().add(new Withdrawal(amount, time));
        }
    }

We would consider this [a partially anaemic domain model][Anemic Domain Model], as one of the core concepts of the domain, the `Account`, is a simple data structure with no understanding of how it should behave. Refactoring brings the data and the behaviour together, but it doesn't allow us to change behaviour easily without modifying the `Account` class.

    public class Account {
        ...

        public void withdraw(Money amount, LocalDate date) {
            balance = balance.minus(amount);
            transactions.add(new Withdrawal(amount, date));
        }
    }

So, let's imagine that our fictional bank has just started supporting overdrafts. Most people won't have one, as it's opt-in, but we expect more and more to do so as time goes on. So we add a `Money overdraftLimit` field and default it to £0, then add the logic to handle the overdraft. This is a small change from the point of view of the account, but expand it out a little to support daily caps on cash withdrawals, warning SMS messages when you're nearing your limit, flexible overdrafts that charge you a fee after 24 hours rather than enforcing a hard limit, and much more, no matter the approach, our `withdrawal` method is going to get *huge*.

Fortunately, we don't just have classes. We also have interfaces. Let's try pulling one out:

    public interface Account {
        void deposit(Money amount, LocalDate date);

        void withdraw(Money amount, LocalDate date);
    }

(Dynamic language programmers, just put this in a comment or something. It'll fly.)

This means we can have two implementations of the account, and only the functionality that takes care of constructing the object needs to care which one.

    public class SimpleAccount {
        ...

        @Override
        public void withdraw(Money amount, LocalDate date) {
            balance = balance.minus(amount);
            transactions.add(new Withdrawal(amount, date));
        }
    }

    public class AccountWithOverdraft {
        private Money balance;
        private List<Transaction> transactions;
        private Money overdraftLimit;
        ...

        @Override
        public void withdraw(Money amount, LocalDate date) {
            Money newBalance = balance.minus(amount);
            if (balance.isBelow(overdraftLimit)) {
                throw new OverdraftExceededException(balance, overdraftLimit);
            }
            balance = newBalance;
            transactions.add(new Withdrawal(amount, date));
        }
    }

Wonderful. Except for the duplication between the two classes. I can personally see two ways of solving this one: we can push the fields into a commonly-shared class, but then we're back to a simple record class that encapsulates the money in the account, which has all the problems we've previously discussed. But what if we were to pull the overdraft logic out into its own object?

    public class Account {
        private Money balance;
        private List<Transaction> transactions;
        private AccountRule accountRule;

        ...

        @Override
        public void withdraw(Money amount, LocalDate date) {
            Money newBalance = balance.minus(amount);
            ValidationResult result = accountRule.validate(newBalance);
            if (result.failed()) {
                throw result.asException();
            }
            balance = balance.minus(amount);
            transactions.add(new Withdrawal(amount, date));
        }
    }

    public interface AccountRule {
        ValidationResult validate(Money balance);

        AccountRule ANYTHING_GOES = balance -> ValidationResult.SUCCESS;
    }

    public class OverdraftLimit implements AccountRule {
        private final Money limit;

        public OverdraftLimit(Money limit) {
            this.limit = limit;
        }

        @Override
        public ValidationResult validate(Money balance) {
            if (balance.isBelow(overdraftLimit)) {
                return new OverdraftExceeded(balance, overdraftLimit);
            }
            return ValidationResult.SUCCESS;
        }
    }

Now we can just use an `Account` with the rule `ANYTHING_GOES` instead of a `SimpleAccount`, and one with a rule that's an instance of `OverdraftLimit` if we need an overdraft. If we need to handle multiple rules, we can turn it into a list or create a composite type.

It turns out the account probably didn't need the interface, but we've managed to close it for modification by opening it for extension in the form of *account rules*, which are more than flexible enough for now.

## This Has A Name

We call this behaviour [*subtype polymorphism*][Subtyping]. In this example, the account rule is not a single thing, but one of many possibilities, all of which conform to the contract set out by the interface or supertype. This style of flexibility relies on the standard object-oriented practice of coupling the behaviour to the data—we couldn't have done it without doing so. If we'd tried and implemented this kind of behaviour directly on the `ATM` class, we'd end up reimplementing half of Java's object system before we were done.

Increasing coupling in one area allows us to reduce coupling in another. Programming is really a set of trade-offs in this regard, and by being aware of the ramifications of your choices, you can make the right trade-off for your software.

[Getters, Setters and Properties]: http://monospacedmonologues.com/post/138009972532/getters-setters-and-properties
[Open-Closed Principle]: http://c2.com/cgi/wiki?OpenClosedPrinciple
[Anemic Domain Model]: http://www.martinfowler.com/bliki/AnemicDomainModel.html
[Subtyping]: https://en.wikipedia.org/wiki/Subtyping
