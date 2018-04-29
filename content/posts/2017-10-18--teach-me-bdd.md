---
title: "Teach Me BDD"
slug: teach-me-bdd
date: 2017-10-18T07:00:18Z
---

> Sensei, teach me BDD.

OK, this whole programmer-fascination-with-Japanese-words thing has gone too far.

Also, OK.

Behaviour Driven Development, or BDD, is the idea that you write user stories that turn into executable test cases.

You've probably heard of Cucumber, or Gherkin. Gherkin is a format for doing just this. Cucumber runs the scenarios and tells you if they fail.

<!--more-->

> OK, with you so far.

Take this one:

    Given a customer with two items in their basket:
      Apple, 57p
      Banana, £1.04
    When I scan the items
    Then the checkout asks for £1.61 in payment
    When the customer pays by credit card
    Then the checkout emits a credit card receipt
    And the checkout emits a shopping receipt

Boom. User story, and then developers can run that as an acceptance test case.

There's a bit more to it but the point is that in order to write your test case, you actually have to talk to your customer, and ideally you write it together.

It's about having a conversation.

> Righto.
>
> So user stories sort of as `if` statements? Emphasis on "sort of".

As validation.

The test case doesn't pass until you implement the feature.

(BTW, a lot of people use "BDD" to mean "we have user stories" or "we have acceptance test cases", not necessarily the combination of the two. This is incorrect but common.)

> Oh, I figured. My customer wants to write the acceptance criteria using GWT. You know, the front-end framework in Java.

Bad idea.

> Yeah, tell me about it. Especially since over half the system won't have a front-end.

Ah, perfect! You've identified other users. Tell me, who's your customer?

> Y'know, Bank #3812. Such is life in London.

I suggest you go make friends with the people who want the software. Not the people making the software, though they're important too. Find out what they care about. Buy them breakfast. Then interrogate them and find out what needs they actually have.

> I'm going to have to. They don't trust the techies here. And it shows. The stories written by the previous BAs are implementation-speak. It's all "widget" this and "data pipeline" that.

This feels very familiar to me. I suggest looking up [Ubiquitous Language][]. You need your customer liaisons to speak the language of the customers. And then you need everyone else to do the same.

Fuck it, just go buy them breakfast.

> Booking it in now. So what's the key difference with unit tests?

Developers write unit tests. The customer writes scenarios (or someone very close to them… is it breakfast time yet?). So it's in the language of the customer. And it's a real requirement.

When you write BDD scenarios, they don't concern itself with implementation. If you see `When the customer logs in` then that's not a user story (though it is very common). No customer has ever asked to be able to log in.

`When the user clicks the 'Buy button`, or `Then the 'About Us' page is displayed`: also not anything to do with user stories. Technical detail.

It should be, `Then Dave finds out everything he wants to know about our corporate standards`. Poor Dave.

> That's pretty normal from what I've seen. `When the user clicks the Back button`…

Oh yes. Totally normal. Not very useful, but that's never stopped developers like me.

If I were you, I wouldn't mention that to the devs on your new team until you've gained their trust a little more. It's way too early right now. Programmers get upset when you tell them they're Doing it Wrong™.

> To be fair to them, they're pretty switched on. Not your usual mindless banking drones.

Then you shall have some fun with them. 😁

> So, tell me: the `Then` clauses have lines starting with `And`; what about `Or`? Or `Else`?

A conditional means you need two stories. Each one will have different `Given` or `When` clauses.

> Gotcha. So let's say I want a Thai meal…

Hey, me too!

> I'll buy you one later. Back to the story: one of the dishes is pad thai. Would pad thai be the feature and the various components the scenarios… or would the recipe itself be a scenario?

What do you mean by "components"?

> Pad thai needs noodles, sauce, meat or seafood, vegetables…

Yeah, but no customer would go into a restaurant and ask for those things. They'd ask for pad thai.

So the ingredients wouldn't be mentioned in the story at all.

    Given a customer is seated in my restaurant
    When they order pad thai
    Then they receive it within 15 minutes
    And it is delicious

You don't need to specify the ingredients. They're defined as part of your language. "Pad thai" has a definition. This is what "ubiquitous language" means. Your customers, broadly, know what it is, and if they don't, your menu explains it, and they learn the language too.

> Okay. And, conditionally, if they don't receive it in 15 minutes?

You need a separate story for when the food is late. It's not the same customer, after all.

Maybe they get complimentary prawn crackers. Of course, then you need another story for when you find out they're vegetarian and can't eat them.

Turns out BDD is pretty useful for exploring your edge cases!

Now, remember, these are examples. In fact, some people refer to this technique as [Specification By Example][], because, well, you're writing a specification by aggregating examples. You don't need to cover every single possible outcome, but you do want to cover every *class* of outcomes.

> So I don't need to worry about every dish, but I do need to worry about what happens when the restaurant opens, when it closes, when a customer runs out, when something inevitably catches fire…
>
> On that topic, I feel like we should add, `And they are charged £8.50`. Gotta look after the bottom line.

Well, in a restaurant, charging comes later. So that would be along these lines:

    Given a customer is seated in my restaurant
    And they have ordered and eaten pad thai
    When they ask for the bill
    Then they receive it, and it totals £8.50

> Right. So the `Given` line would need to cover that the customer is "still" seated.
>
> We'd need another payment story for when the food was late.

Yeah, maybe if it takes more than an hour you comp the meal.

> And slowly the various paths emerge…
>
> It's funny how they're broken up like that though. Isn't it hard to keep track of them?

Good question. The thing about test cases is that they can't branch. If they do, they're testing too much. And they're free. Just have more.

User stories are the same. If you start putting logic in your stories, then the logic stays out of the system. And you want the logic to be in the system. That's the whole point.

Often stories are grouped into "features". So you might have a feature which handles food showing up late, including all the different cases you'll need to worry about. Or you might slice it up by stage, in which case you'll need to make sure you handle edge cases another way. Often people "tag" stories for this purpose; you can add multiple tags to a story, which means you could then query for all the stories related to payment.

> This all reminds me of Prolog.

Yes, except understandable by human beings.

> So you, the story author, supply the conditions and validation… but not the actual logic?

Yeah, the programmers do that.

Typically writing stories like this requires lots of iteration.

Because you write them with the customer, then go to the programmer and they say, "I think that's about three weeks." And you go, "Wha?" So together you iterate on it to come up with something that does most of the work for much less cost. Then you go back to the customer and see if that would still be useful.

This doesn't stop when you nail down the story. Sometimes a developer will be half-way through implementation and discover it just can't work that way, or that an edge case no one considered makes it infeasible. Hopefully, if they're smart, they'll talk to you, you'll talk to the customer, and you'll figure out a solution together.

It's an expensive way to figure out requirements. However, it's still several orders of magnitude cheaper than *not* figuring out your requirements. And it turns out that Actually Talking To People is still the only solution that works.

This assumes your programmers are not drones. If they are, you're going to have problems.

Can't be agile if the people aren't.

> No, that's my one asset: great programmers. All polyglot, all passionate, all ready to do something meaningful.

Fantastic.

So, further reading. Go read [The Cucumber Book][].

> Already ordered. Now, I'm off to knock some heads together until we're all speaking the same language.

---

This was inspired by a conversation [Azfarul Islam][] and I had many, many moons ago. It's not the actual content, but it's not far off. (Finally, a use for chat logs.) We hope you enjoyed it.

[Ubiquitous Language]: https://martinfowler.com/bliki/UbiquitousLanguage.html
[Specification By Example]: https://blog.red-badger.com/blog/2012/07/31/what-is-specification-by-example
[The Cucumber Book]: https://pragprog.com/book/hwcuc2/the-cucumber-book-second-edition
[Azfarul Islam]: https://www.linkedin.com/in/azfarulislam/
