---
title: "Getters, Setters and Properties"
slug: getters-setters-and-properties
date: 2016-01-25T08:30:21Z
---

The last rule of [Object Calisthenics][] is:

> No getters, setters or properties.

Last week, I was at [eXtreme Tuesday Club][] (a.k.a. *XTC*) for a beer and a conversation, and something happened that hasn't happened there in a while. Someone new to the industry came along. (I can't remember their name, but if it was you, post a comment!) For ages, XTC has been dying because no new blood, but due to stellar leadership and [fantastic marketing][Extreme all the Tuesdays!], things are starting to pick up again.

In our discussion, something came up. Some people will tell you that current wisdom in programming preaches no getters, setters or properties. But why? Often, no explanation is given.

[Object Calisthenics]: https://www.cs.helsinki.fi/u/luontola/tdd-2009/ext/ObjectCalisthenics.pdf
[eXtreme Tuesday Club]: http://www.meetup.com/eXtreme-Tuesday-Club-XTC/
[Extreme all the Tuesdays!]: https://twitter.com/extremetuesday/status/689467737698099200

<!--more-->

## First off… what are those things?

OK, terminology. If you know what these things are, skip ahead to the next bit.

Let's say we have a Java class. Proponents of other languages, you should be able to translate fairly easily.

    class Account {
        private Money balance;
        private List<Transaction> transactions;
    }

**A getter** is a method on that class that provides access to private data. For example:

        public Money getBalance() {
            return balance;
        }

Similarly, **a setter** is a method that allows the caller to modify private data:

        public void setBalance(Money balance) {
            this.balance = balance;
        }

You may at this point, especially if you're not used to Java or C#, be wondering why you'd bother and not just make the field public. The answer is that by encapsulating this behaviour, changing it, for example to add validation code, is trivial, whereas introducing additional behaviour is very difficult if other objects are accessing the field directly. For example, we might want to verify that the balance doesn't drop below the account owner's overdraft limit:

        public void setBalance(Money balance) {
            if (balance.isBelow(overdraftLimit)) {
                throw new IllegalArgumentException(
                    balance + " cannot go below " + overdraftLimit + ".");
            }
            this.balance = balance;
        }

In other languages such as Ruby or Python, this is not a problem, as fields and methods are interchangeable and we can overload access and assignment, so we can add extra functionality without having to change syntax.

Finally, **a property** is a combination of the two, and is usually a language feature. For example, in C#, we can create a property that has the same behaviour as the getter and setter above.

        private Money balance;

        public Money Balance
        {
            get
            {
                return balance;
            }
            set
            {
                if (Balance.isBelow(OverdraftLimit)) {
                    throw new ArgumentException(
                        balance + " cannot go below " + overdraftLimit + ".");
                }
                balance = value;
            }
        }

## So Why Can't I Use Them?

Damn good question.

At their heart, getters, setters and properties are mechanisms to provide a layer of indirection between data and *unrelated* behaviour. As *related* behaviour would be in the same class and have access to the fields of that class, they only really apply to external callers, and so only make sense when we differentiate between external behaviour and internal behaviour.

Let's take a look at a piece of logic *calling* the setter.

    class ATM {
        public void withdraw(Account account, Money amount, Instant time) {
            Money newBalance = account.getBalance().minus(amount);
            account.setBalance(newBalance); // could throw if we can't withdraw enough
            account.getTransactions().add(new Withdrawal(amount, time));
        }

        ...
    }

Simple, right? I just have one problem: what happens if someone implements the caller wrongly? What if they forget to add a transaction? What if they add the transaction *after* modifying the balance, and that throws an exception, leaving the object in an inconsistent state?

In this example, the refactoring is simple. Let's move the code into the `Account` class.

    class Account {
        ...

        public void withdraw(Money amount, Instant time) {
            Money newBalance = balance.minus(amount);
            setBalance(newBalance); // could throw if we can't withdraw enough
            transactions.Add(new Withdrawal(amount, time));
        }

        ...

        private void setBalance(Money balance) {
            ...
        }
    }

The beauty of this is that we don't use the getters any more, and the setter now private. The behaviour is now *internal* to the class, and so we don't need to break encapsulation by exposing the internal state. Calling a method on this object is now guaranteed to leave it in a consistent state.

Turns out we didn't need getters or setters at all.
