When someone asks me how to design and build a system full of
interlocking, moving parts, I just point them at SOLID. These bad boys
don’t just apply to your code. They should be an integral part of your
architecture too.

Here’s how.

Single Responsibility Principle
-------------------------------

The SRP isn’t just a guide to code. It explains a lot about life. It’s
the reason [your favourite coffee house](http://www.taylor-st.com/)
produces far better coffee than your local Chinese restaurant. It tells
you why Wal\*Mart’s bicycles are awful. And it’s the answer to building
good modules.

Solve one problem.

Let’s put it this way: at all levels of your application, components
should be expressive and easily named. They should do one thing and tell
you what it is. For example, you might have a method called
`renderProduct` in a view named `ProductView`, on a web page called
*Products*, on a site named *Buy My Freakin’ Stuff*. It’s a bit
contrived, but you can see how at each level, we’re solving a single
problem. This extends well into a service-oriented architecture too,
where each service has a single responsibility, albeit larger than the
modules inside it.

Open-Closed Principle
---------------------

I’ve started rephrasing the OCP as “don’t change, replace”. When
changing the behaviour of existing interfaces, wrap them, don’t modify
them directly until you’re sure everything using the interface can
handle it. This is actually far more important at the design level. Your
interfaces aren’t just code, y’know. You have UIs (user interfaces) and
APIs (application programming interfaces) too. You need to ensure that
the behaviour doesn’t change, not just for third parties but also for
internal services. If you want to change it, that’s great, but do it in
a few steps: wrap it, change the callers, delegate the old to the new,
change them all back and finally remove the wrapper. Even better, make
versioning explicit, and let clients access either version, removing the
need for a temporary endpoint. Simples, right?

Liskov Substitution Principle
-----------------------------

This one’s fairly easy: if you change the implementation of an endpoint,
keep the behaviour. Just as I should be able to swap out an array list
for a linked list with no change to my end result (though the
performance characteristics may change), Twitter reimplementing their
public timeline API should never require third-party application
developers (or their own in-house devs) to change their apps. This also
applies to user interfaces: experience changes should ideally never be
made as a result of technical changes, but should be judged on their own
merits. This might, of course, provoke a technical modification as part
of the work.

Interface Segregation Principle
-------------------------------

Quite often, and especially in business-focused applications, software
is built for many different *kinds* of customers. In the financial
domain in which I currently work, we have the “buy side” and the “sell
side”, as well as our in-house support team, who administer the product.
And yet the software is delivered as a single web site with different
pages and an entirely different look and feel depending upon your
account credentials. Why?

This entire model is insane. We want four or five applications: the buy
side, the sell side, administration, a login page and maybe even some
kind of API which the different applications can use as a common meeting
point.

Dependency Inversion Principle
------------------------------

When applied to applications or components, DI simply means defining and
exposing a public interface (like an API), and then using specifically
that and only that to interact. This means you should not be
communicating informally using, for example, a database. If you really
want your individual modules to be black boxes, no other module should
even be aware that they use a database, let alone how to access it. By
extension, sharing a data store at all is a terrible idea, as it creates
a high degree of coupling between two things, going against the entire
concept of modularisation.

That’s all, folks.
------------------

That’s all five. There’s obviously more that plays into building a
maintainable architecture, but hopefully this will be helpful. The
realisation has definitely improved the way I think about software
design.
