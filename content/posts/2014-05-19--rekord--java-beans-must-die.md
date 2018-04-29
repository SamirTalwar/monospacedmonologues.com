---
title: "Rekord: Java Beans must die"
slug: rekord--java-beans-must-die
date: 2014-05-19T16:52:00Z
aliases:
  - /post/86221882520/rekord-java-beans-must-die
---

In programming, duplication is the enemy.

We see it everywhere. Code, copied and pasted because "we have no time". Entire pieces of infrastructure lifted from one project to the next, rather than extracted and shared. Domain objects scattered through applications, every one slightly different. API connection layers written again and again, each one in a different style, doing the same, exact thing with new and interesting bugs.

<!--more-->

## Meanwhile, in Javaland…

These are all serious problems, but Java has one more. We can't get away from it. No language really helps with duplication of behaviour, but in Java, we also duplicate concepts. It looks something like this:

    public class Person {
        private final String firstName;
        private final String lastName;
        private final LocalDate dateOfBirth;
        private final Address address;

        public Person(String firstName, String lastName,
                      LocalDate dateOfBirth, Address address) {
            this.firstName = firstName;
            this.lastName = lastName;
            this.dateOfBirth = dateOfBirth;
            this.address = address;
        }

        public String getFirstName() {
            return firstName;
        }

        // I can't go on. You know the rest.
    }

But wait. There's more.

    public class PersonBuilder {
        private String firstName;
        private String lastName;
        private LocalDate dateOfBirth;
        private Address address;

        public static PersonBuilder aPerson() {
            return new PersonBuilder();
        }

        public PersonBuilder withFirstName(String firstName) {
            this.firstName = firstName;
            return this;
        }

        // So many more methods.

        public Person build() {
            return new Person(firstName, lastName, dateOfBirth, address);
        }
    }

That's right, we need a builder too.

Oh, and we like tests. Especially clear, readable tests. So let's make a matcher.

    public class PersonMatcher extends TypeSafeDiagnosingMatcher<Person> {
        private Matcher<String> firstName = any(String.class);
        private Matcher<String> lastName = any(String.class);
        private Matcher<LocalDate> dateOfBirth = any(LocalDate.class);
        private Matcher<Address> address = any(Address.class);

        public static PersonMatcher aPerson() {
            return new PersonMatcher();
        }

        public PersonMatcher withFirstName(Matcher<String> firstName) {
            this.firstName = firstName;
            return this;
        }

        // Keep writing methods.

        @Override
        public void describeTo(Description description) {
            // Very important.
        }

        @Override
        protected boolean matchesSafely(Person actualPerson,
                                        Description mismatchDescription) {
            // Match against the fields.
        }
    }

OK, now we can use our `Person` type. It's beautiful, right? It just needs some annotations to serialize to JSON, then some [JPA][Java Persistence API] annotations for persistence to the database, and…

**WRONG. SO WRONG.**

Ugh. So much code for so little behaviour. And not just once. *EVERYWHERE.* Can we stop this?

Fuck yes.

[Java Persistence API]: http://www.oracle.com/technetwork/java/javaee/tech/persistence-jsp-140049.html

## Rekord to the Rescue

Code like the above makes me angry. It's such a waste of space. The same thing, over and over again. So last year, I built something that does all this for you. Now I'm on a Java project again, the features are coming in fast as a result.

On Thursday, I released v0.2 of [Rekord][]. With it, the above suddenly becomes a lot smaller.

    public interface Person {
        Key<Person, String> firstName = SimpleKey.named("first name");
        Key<Person, String> lastName = SimpleKey.named("last name");
        Key<Person, LocalDate> dateOfBirth = SimpleKey.named("date of birth");
        Key<Person, FixedRekord<Address>> address = RekordKey.named("address");

        Rekord<Person> rekord = Rekord.of(Person.class)
            .accepting(firstName, lastName, dateOfBirth, address);
    }

## Umm, what?

That `Rekord<Person>` object is a *rekord builder*. You can construct new people with it.[^1] Like so:

    Rekord<Person> woz = Person.rekord
        .with(Person.firstName, "Steve")
        .with(Person.lastName, "Wozniak")
        .with(Person.dateOfBirth, LocalDate.of(1950, 8, 11))
        .with(Person.address, Address.rekord
            .with(Address.city, "Cupertino"));

`woz` has the type `Rekord<Person>`, but you can treat it basically as if it were a `Person` as shown above. There's only one real difference. Instead of:

    woz.getFirstName()

You call:

    woz.get(Person.firstName)

Simple, right?

[^1]: Not real people. For that, you need C++.

## Builders and Matchers for free

It gets better. Every rekord is a builder; those `with` calls make it pretty readable. Don't worry about mutating other rekords though; they're immutable, every one returning a new object.

Because it's just one type, you only need one matcher.

    assertThat(woz, is(aRekordOf(Person.class)
        .with(Person.firstName, equalToIgnoringCase("steve"))
        .with(Person.lastName, containsString("Woz"))
        // You get it.
        ));

It also has matchers available for individual properties.

## It's still not Ruby.

Not quite. But we do have some advantages that you can't get over in Ruby land. Like **type safety**. Those key objects are typed, as you might have noticed. That means that the following won't compile.

    Person.rekord.with(Person.firstName, 3);

The value has to match the type specified by the key. The next line won't work either:

    Person.rekord.with(Address.street, "Acacia Avenue");

The key's of the wrong type, y'see.

If you do need to use keys of another type, for example when dealing with *is-a* relationships, you can use interface inheritance to handle that.

    interface Employee extends Person {
        Key<Employee, FixedRekord<Employee>> manager = RekordKey.named("manager");

        Rekord<Employee> rekord = Rekord.of(Employee.class)
            .accepting(Person.firstName, Person.lastName, Person.dateOfBirth, Person.address,
                       Employee.manager);
    }

I want to make it a bit easier to add all the `Person` keys at once—expect that in version 0.3.

## Data goes in

User input is a tricky beast. It's almost never entirely correct, and we need ways to make sure it doesn't mess with the state of our carefully-built applications. The standard solution in Java is to build validators—classes that process your value objects. This has the benefit of decoupling your validation logic from your domain, but at the cost of again, duplicating the behaviour everywhere.

So let's use a `ValidatingRekord` instead.

    interface Person {
        // All the keys.

        ValidatingRekord<Person> rekord = ValidatingRekord.of(Person.class)
            .accepting(firstName, lastName, dateOfBirth, address)
            .expecting(allOf(
                allProperties(),
                hasProperty(Person.dateOfBirth, lessThan(eighteenYearsAgo()))));
    }

Now, when we construct our `Person`, we can't just `get` values out. We need to call `fix` first to create a `ValidRekord`. The following code will throw an `InvalidRekordException` because it's missing a couple of properties.

    ValidRekord<Person> larry = Person.rekord
        .with(Person.firstName, "Larry")
        .fix(); // throws InvalidRekordException

`InvalidRekordException` is a checked exception, because you should handle it at the validation layer and not let it proceed any further. If you're skeptical, pause for a moment, and go and read [my post on `IOException`][Check your I/O] which explains more about why checked exceptions are a good thing.

`ValidatingRekord` takes a Hamcrest matcher, which means you can use all of the built-in functionality of Hamcrest, plus and custom matchers you may have already made. And because our keys are objects in their own right, the `hasProperty` matcher (in the `RekordMatchers` class) is completely type-safe.

[Check your I/O]: http://monospacedmonologues.com/post/75704273387/check-your-i-o

## And data goes out

We don't just pump information into software; sometimes, we spit it out as well. While your friend `get` is useful here, sometimes we need something more special.

So, of course, rekords are serializable. Not Java `Serializable` (with a capital *S*), but something a bit more controllable. Because we expose the keys of a rekord, no reflection is required to transform one straight into a form of your choosing.

So, `woz.serialize(JacksonSerializer.writingToString())` returns this:

    {"first name":"Steve","last name":"Wozniak","date of birth":"1950-08-11","address":{"city":"Cupertino"}}

And `woz.serialize(new DomXmlSerializer())` returns a `Document` object containing this:

    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <person>
        <first-name>Steve</first-name>
        <last-name>Wozniak</last-name>
        <date-of-birth>1950-08-11</date-of-birth>
        <address>
            <city>Cupertino</city>
        </address>
    </person>

Not bad, right? There's a few serializers out of the box. If you can't find one for your purpose, you can write your own, so if you need your `Rekord` in another format, just implement the right interfaces and away you go.

## On the Horizon

I've got a few more things I want to build before I declare this library finished. And there'll probably be a few more by the time those are done. I'm hoping I get to work on it for a while—it's incredibly fun.

Coming up:

  * lenses over keys, so we can stick them together, and ask a `Person` for their `city` directly
  * views of rekords (or rekord transformers), allowing us to keep our domain separate from the data structures used at integration points
  * deserialization, for obvious reasons

Expect the first two in v0.3, and deserialization in v0.4.

## Caveats

There are a few things, aside from the missing features listed above, that might stop you from using Rekord.

  * You value insane levels of performance. Rekords are backed by persistent, immutable maps, which are fast enough for 99% of use cases, but there are certain developers who need that extra *oomph*. If Ruby was ever an option for your project, you shouldn't be worried.
  * You don't like the syntax. Can't really help you there, unfortunately. It's a bit nuts, and not very Java-like. I would recommend giving it a try, though.
  * You prefer [Octarine][]. I can't fault you for that. It's a great library. Dominic (the author, and a friend of mine) wrote [a very interesting comparison][Octarine vs Rekord: Design Comparison] which plan on responding to soon.
  * You need stability. I plan on changing Rekord a lot in the coming weeks and months. Your code will not necessarily work with new versions. Come v1.0, I promise to keep a stable API (well, until v2.0), but while we're in the zero-dots, all bets are off.

[Octarine]: https://github.com/poetix/octarine
[Octarine vs Rekord: Design Comparison]: http://www.codepoetics.com/blog/2014/05/18/octarine-vs-rekord-design-comparison/

## So get to it

You can download [Rekord][] from GitHub. It's also on Maven Central, so throw this into your POM and away you go:

    <dependency>
        <groupId>com.noodlesandwich</groupId>
        <artifactId>rekord</artifactId>
        <version>0.2</version>
    </dependency>

If you do use it, please [drop me an email][email] and tell me how. I'd be very interested. If you find any issues, [let me know][Issues], or even better, raise a [pull request][Pull Requests]. Contributions are very welcome.

I hope you like it.

[Rekord]: https://github.com/SamirTalwar/Rekord
[Issues]: https://github.com/SamirTalwar/Rekord/issues
[Pull Requests]: https://github.com/SamirTalwar/Rekord/pulls
[email]: mailto:samir@noodlesandwich.com
