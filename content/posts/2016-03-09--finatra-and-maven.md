---
title: "Finatra and Maven"
date: 2016-03-09T08:00:40Z
---

I was ranting about Finatra's Maven dependencies last week, and today I figured out why they're broken.

<!--more-->

After looking more closely into things, it appears that the dependency trees for the Finatra production JARs are perfectly valid. `finatra-http` depends on `finatra-jackson`, which depends on `finatra-utils`, which depends on `inject-utils`… you get the idea. I asked Maven to generate the tree for me.

    $ mvn dependency:resolve -Dverbose
    ...
    [INFO] +- com.twitter.finatra:finatra-http_2.11:jar:2.1.4:compile
    [INFO] |  +- (org.scala-lang:scala-library:jar:2.11.7:compile - omitted for duplicate)
    [INFO] |  +- com.twitter.finatra:finatra-jackson_2.11:jar:2.1.4:compile
    [INFO] |  |  +- (org.scala-lang:scala-library:jar:2.11.7:compile - omitted for duplicate)
    [INFO] |  |  +- com.twitter.finatra:finatra-utils_2.11:jar:2.1.4:compile
    [INFO] |  |  |  +- (org.scala-lang:scala-library:jar:2.11.7:compile - omitted for duplicate)
    [INFO] |  |  |  +- (com.twitter.inject:inject-utils_2.11:jar:2.1.4:compile - omitted for duplicate)
    [INFO] |  |  |  +- com.fasterxml.jackson.core:jackson-annotations:jar:2.4.4:compile
    [INFO] |  |  |  +- com.github.nscala-time:nscala-time_2.11:jar:1.6.0:compile
    [INFO] |  |  |  |  +- (org.scala-lang:scala-library:jar:2.11.4:compile - omitted for conflict with 2.11.7)
    [INFO] |  |  |  |  +- (joda-time:joda-time:jar:2.5:compile - omitted for duplicate)
    [INFO] |  |  |  |  \- (org.joda:joda-convert:jar:1.2:compile - omitted for duplicate)
    ...

However, when it comes to running tests, they're absolutely broken. The dependencies for `finatra-http` with a classifier of `tests` look like this, taken from the same output:

    [INFO] +- com.twitter.finatra:finatra-http_2.11:jar:tests:2.1.4:test
    [INFO] |  +- (org.scala-lang:scala-library:jar:2.11.7:test - omitted for duplicate)
    [INFO] |  +- (com.twitter.finatra:finatra-jackson_2.11:jar:2.1.4:test - omitted for duplicate)
    [INFO] |  +- (com.twitter.inject:inject-request-scope_2.11:jar:2.1.4:test - omitted for duplicate)
    [INFO] |  +- (com.twitter.inject:inject-server_2.11:jar:2.1.4:test - omitted for duplicate)
    [INFO] |  +- (com.twitter.finatra:finatra-slf4j_2.11:jar:2.1.4:test - omitted for duplicate)
    [INFO] |  +- (com.github.spullara.mustache.java:compiler:jar:0.8.18:test - omitted for duplicate)
    [INFO] |  +- (commons-fileupload:commons-fileupload:jar:1.3.1:test - omitted for duplicate)
    [INFO] |  \- (javax.servlet:servlet-api:jar:2.5:test - omitted for duplicate)

That's it. No mention of `finatra-jackson`, `inject-core`, `inject-app`, `inject-modules` or `inject-server`, all with a classifier of `tests`. It has the same dependencies as the non-test version. This is by design—at least the design of Maven.

Classifiers, in Maven, are a mechanism for publishing alternate artifacts that correspond to the same project. These all share the same POM, as they're part of the same project, but the actual contents are different. We can use this, along with a naming convention, to publish more than one artifact at a time, and often we do—the source code and the Javadoc are commonly published alongside, using the `sources` and `javadoc` classifiers respectively.

Twitter have done the same, but published one further: `tests`. (Oh, and `tests-sources` and `tests-javadoc`.) The `tests` JAR contains the compiled contents of the *src/test/java* directory—essentially, Twitter are publishing their test cases. This is fine for posterity, but it's not just tests in there—it's test utilities too. A lot of these are referred to in the documentation, and you're expected to depend on these test JARs to write your own test cases.

However, there's a snag. Because these are simply secondary artifacts in the same project, they share a dependency tree, and nowhere does the dependency tree specify that `finatra-http` with the `tests` classifier have a different set of dependencies to the version without. It can't—one project, one tree. This could be seen as a limitation of Maven, but regardless of the reason, the tooling simply doesn't allow for this.

The result? When testing code that uses Finatra, you have to bring in all the dependencies yourself, whether you're using Maven, SBT, Gradle or something else I've never even considered. Maven is much more verbose than the other two, but any solution that requires duplication of dependencies in this fashion has got something funny going on.

The solution? Stop publishing the test cases—no one needs them—and publish the test utilities as a separate project entirely. My own project, [Rekord][], publishes a set of projects, [including `rekord-test-support`][Rekord on Maven Central] which is depended upon by the tests of other subprojects. This works very well, and it's not too difficult to scale it up to one per project—just add "-testing" to the artifact name or something. This way, they don't share dependency trees and the burden of maintaining the dependency tree for testing doesn't fall on Finatra's users.

So come on, Twitter. Let's get this sorted. If any of the maintainers of [Twitter's Maven repository][] are reading this and want some help, [drop me a line][@SamirTalwar].

[Rekord]: https://github.com/SamirTalwar/Rekord
[Rekord on Maven Central]: https://search.maven.org/#search|ga|1|g%3A%22com.noodlesandwich%22%20rekord
[Twitter's Maven repository]: https://maven.twttr.com/
[@SamirTalwar]: https://twitter.com/SamirTalwar
