---
title: "Test-driven development in three easy steps"
slug: tdd-in-3-easy-steps
date: 2021-08-16T19:00:00Z
---

You might have heard that test-driven development, or "TDD", is as simple as three easy steps. So without further ado, I present them here.

1.  Write a failing test.
2.  Delete that test. It was nonsense.
3.  Write a much smaller test with just an assertion and a couple of extra lines.
4.  Run the test and observe that the failure message is completely useless.
5.  Rewrite the assertion for good failure messages.
6.  Run the test again. Rejoice in your helpful failure message.
7.  Try to make it pass by implementing a new function in your test code.
8.  Realise that in order to make it pass, you have to basically duplicate the test setup, because you're using stubs and mocks.
9.  Decide that this way lies madness. Rewrite the test a second time, without using mocks.
10. Recognise that by not using mocks, you can't inject an in-memory database, and so the test is going to be gargantuan and slow. You have to return a value that states the intent, and have some other thing actually do the database interaction.
11. Make lunch.
12. Eat lunch.
13. Spend some time sketching out what it means to have a value that says "insert this thing into a table".
14. Come up with representations of state changes like `InsertThisThing`.
15. Recognise that that's a bad name, and instead investigate your domain language.
16. Create structures to represent modifications to your application state in the language of your domain.
17. Realise you have no word for whatever this "thing" is, and go ask someone.
18. Have a long and fruitful discussion with your customer about what it really means when someone does this thing.
19. Agree on terminology, and write it down.
20. Add that terminology to your code.
21. Write that assertion.
22. Make it pass.
23. Move the logic out of the test code.
24. Tidy things up, move them around, generally let your brain relax as you clean things up.
25. Make some tea. It's been a long day.

---

You might already be familiar with a different set of steps. They look something like this:

1.  Write a failing test.
2.  Make the test pass.
3.  Refactor your code.

Also known as "red, green, refactor".

While these steps definitely capture the _method_ of TDD, they can make it sound easy. They explain the mechanics, but not the purpose. We use these steps to tease out misunderstandings, contradictions, and hidden complexity in our software and our (often informal) requirements. When they flow, and we can simply write the test, and make it pass, that's a wonderful feeling.

But it's when they _don't_ work that we've learned something useful about our software.
