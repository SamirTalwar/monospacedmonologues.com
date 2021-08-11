---
title: "Truly great CI/CD"
slug: truly-great-ci-cd
date: 2021-08-11T17:00:00Z
---

Either my standards are too high, or I've never seen an _excellent_ CI/CD pipeline. Which got me wondering: what would a truly great continuous deployment (or continuous integration) pipeline look like?

So here's some ideas.

1.  Software developers (programmers, QA, designers, ops, customer liaisons, etc.) can build your entire application (and yes, that includes microservices) in under a minute on their work computers. Offline.

    It's OK if the first run takes a while, but the second time shouldn't.

    Bonus points if attempting to build something with no code changes just grabs a pre-built version from a cache somewhere (when you're online).

2.  All programming work goes through at least two people. I don't care if it's pair programming, ensemble programming, or some kind of code review, but I do care that it's fast. If your review process is your bottleneck, your pipeline is not continuous.

3.  All unit tests run in under a minute. This includes the centralized build pipeline, but also my (and your) development machine. I should be able to run these from the editor, and get best-in-class output. This means I shouldn't have to trawl through terminal logs to get the test results unless that's the status quo for the language I'm using.

4.  Similarly, integrated tests take only a few minutes, and can be run from anywhere (not just a CI box). The integrated tests are there to catch edge cases that can't be tested otherwise; they're not likely to fail during day-to-day development, and so there are only a few of them.

5.  On push, CI builds everything in the exact same way that a developer would, and gets the exact same artifact, byte for byte.

6.  We can trust that builds are completely reproducible, so if we try and build the same thing twice, we get it from a cache instead.

7.  Building and testing is parallelised to the point that it's basically instant on CI.

8.  Any end-to-end tests are run using production-ready artifacts (built locally or by CI). Nothing is built after the build phase. If you ship Docker images, you test your Docker images, not something else.

9.  Tests are trusted, so everyone knows that if the tests pass, the application is almost certainly going to work.

10. Tests are reliable, so a failure is considered a problem, and investigated accordingly. "Flaky" tests are fixed or purged with extreme prejudice.

11. On a successful verification run (i.e. all automated tests pass), artifacts are deployed to production with zero downtime (e.g. using [blue-green deployment][]). This is a non-event and takes less than a few minutes.

12. Developers can easily grab the production artifacts deployed right now or any point in history and deploy them locally.

13. A subset of the end-to-end tests (call them "smoke tests") are run in production shortly after deployment to validate the application.

14. Business metrics are in place to ensure that the application is working as intended (i.e. fulfilling its purpose, which can usually be correlated with making or saving money). These metrics track as close to real-time as possible.

15. A deployment failure, smoke test failure, or a decline in critical metrics immediately triggers the software to roll back (again, without downtime) and alert the developers. Alerts are always taken seriously, and the developers work hard to make sure they very rarely see the same failure twice.

16. Data is always backwards-compatible to at least a few deployed versions, so rolling forward and backward is always safe.

This isn't everything, of course, but I think it's the start of something decent to aim for.

[blue-green deployment]: https://martinfowler.com/bliki/BlueGreenDeployment.html
