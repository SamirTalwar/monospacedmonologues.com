---
title: "Complicit Implicits"
slug: complicit-implicits
date: 2014-01-09T14:41:34Z
aliases:
  - /post/72767422233/complicit-implicits
---

Imagine we have a calculator, written in Scala.

    class Calculator {
      def run() {
        val printer = new Printer
        printer.print("The answer is always ")
        printer.print(7)
        printer.newLine()
      }
    }

    object Calculator extends App {
      new Calculator().run()
    }

It does one thing and it does it well. (Not the thing it says on the tin, but we'll get there.) It makes use of a `Printer`, which is a type of object that knows how to print things.

    import java.io.PrintStream

    class Printer {
      def print(value: Int)(implicit out: PrintStream) = out.print(value)
      def print(value: Double)(implicit out: PrintStream) = out.print(value)
      def print(value: String)(implicit out: PrintStream) = out.print(value)
      def newLine()(implicit out: PrintStream) = out.println()
    }

<!--more-->

Together, they make music. Or would, if we made one small change:

    class Calculator {
      implicit val output = System.out
      ...
    }

That's more like it. Compiling, running, doing something useless. It's a good starting point. So let's take it up a notch and fake out some actual calculation:

    class Calculator {
      private implicit val input = System.in
      private implicit val output = System.out

      private val scanner = new Scanner
      private val printer = new Printer
      private val tokenizer = new Tokenizer
      private val calculationParser = new CalculationParser

      def run() {
        val line = scanner.readLine()
        val tokens = tokenizer.tokenize(line)
        val calculation = calculationParser.formExpression(tokens)
        val result = calculation.evaluate()
        printer.print(result)
        printer.newLine()
      }
    }

Magnificent, isn't it? Sure, it doesn't actually _do_ anything yet, because all those other classes haven't been implemented, but we now have a structure in place.

My only issue with it is that it doesn't fully follow [SOLID principles][solid (object-oriented design)]. It depends upon concrete objects, not abstractions, and it's not open for extension; changes will require modification. We can fix both of these issues by asking for the dependencies, rather than constructing them upon initialisation:

    class Calculator(scanner: Scanner, printer: Printer, tokenizer: Tokenizer, calculationParser: CalculationParser) {
      ...
    }

For this to work, we need to adjust the application object to match:

    object Calculator extends App {
      private implicit val input = System.in
      private implicit val output = System.out

      private val scanner = new Scanner
      private val printer = new Printer
      private val tokenizer = new Tokenizer
      private val calculationParser = new CalculationParser
      new Calculator(scanner, printer, tokenizer, calculationParser).run()
    }

Magnificent. Our new version is easy to test as a unit, rather than having to write an [integrated test][integrated tests are a scam]. In addition, because it depends upon abstractions, I can easily change the behaviour without having to change the class itself. For example, if I wanted to use [Reverse Polish notation][] instead, I could just substitute in a different `CalculationParser`.

All we need to do now is hit compile and enjoy the magic.

    Calculator.scala:32: error: could not find implicit value for parameter in: java.io.InputStream
        val line = scanner.readLine()
                                   ^
    Calculator.scala:36: error: could not find implicit value for parameter out: java.io.PrintStream
        printer.print(result)
                     ^
    Calculator.scala:37: error: could not find implicit value for parameter out: java.io.PrintStream
        printer.newLine()
                       ^
    three errors found

What.

It's obvious in hindsight: the `Calculator` invokes methods on the scanner and printer that require knowledge of the implicit `InputStream` and `PrintStream`. We could pass them in to the `Calculator` constructor, but that's pretty ugly. The `Printer` and `Scanner` classes exist to provide a useful abstraction on top of these types; if we also pass in their dependencies, what's the point of them existing in the first place? There must be a better way.

Well, you guessed it. There is. The clue is in the word "dependency"; if the `Printer` depends on `PrintStream`, can't we make that explicit?

Of course we can:

    class Printer(out: PrintStream) {
      def print(value: Int) = out.print(value)
      def print(value: Double) = out.print(value)
      def print(value: String) = out.print(value)
      def newLine() = out.println()
    }

That was easy, right? And we've managed to reduce duplication, which is lovely.

Some of you may, at this point, be shaking your heads, wondering why I wrote this code in the first place. It might seem alien to you, but this approach is the default taken in most Scala projects, including those we all depend upon. The specific example that provoked this article was the [`WebBrowser` trait in ScalaTest][org.scalatest.selenium.webbrowser], in which pretty much all the methods rely on an implicit `WebDriver` object being present and in scope. This seems fine initially, but then I wanted to create a [page object][pageobject]. Extracting out the code that depended on `WebBrowser` was a nightmare; because of the implicit dependency on the `WebDriver` object, I had to pass it around everywhere, rather than just constructing it once and encapsulating it.

In Scala, `implicit`s are the bane of my existence. Please stop.

Next week, I want to talk about traits and the Cake pattern. Assuming I don't shoot myself first.

[solid (object-oriented design)]: https://en.wikipedia.org/wiki/SOLID_%28object-oriented_design%29
[integrated tests are a scam]: http://blog.thecodewhisperer.com/2010/10/16/integrated-tests-are-a-scam/
[reverse polish notation]: https://en.wikipedia.org/wiki/Reverse_Polish_notation
[org.scalatest.selenium.webbrowser]: http://doc.scalatest.org/2.0/index.html#org.scalatest.selenium.WebBrowser
[pageobject]: http://martinfowler.com/bliki/PageObject.html
