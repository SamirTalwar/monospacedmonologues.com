I hear a lot of arguments against Java's checked exceptions. Normally, they run along these lines:

> You have to propagate the exceptions everywhere. Too much noise, not enough signal.

And they're right. It can be very noisy. Personally, I think the noise is worth it so that exceptions are adequately handled, but it's a bit ridiculous.

If you want to write your code so that exceptions are only surfaced at run-time, go for it. I won't stop you. However, I take issue with this when it comes to *interfaces*. If your interfaces aren't able to throw exceptions, even in environments where that would be reasonable, it can be really unpleasant for your implementors.

Let's take `java.lang.Runnable` as an example. Here's the full source code, without the comments:

    package java.lang;

    @FunctionalInterface
    public interface Runnable {
        public abstract void run();
    }

My issue there is that `run` doesn't allow for any checked exceptions. However, we use this interface a lot with multithreaded code, for example with an `ExecutorService`, and exceptions, especially `IOException`, are common in these scenarios. This means we end up writing a lot of code like this:

    executor.submit(() -> {
        try {
            doTheThing();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    });

The Sun/Oracle folks fixed this somewhat by allowing us to use `Callable<V>` instead. The `call` method *does* allow for exceptions, and so makes our lives easier.

    package java.util.concurrent;

    @FunctionalInterface
    public interface Callable<V> {
        V call() throws Exception;
    }

As the `ExecutorService` returns a `Future<V>` which will throw an `ExecutionException` on `get` if anything did go wrong, this is moot anyway. You have to handle that one, and that *is* checked.

When designing our own interfaces, we have a third option. Rather than throwing a checked or an unchecked exception, we can let the implementor decide.

Take a look at my [`Serializer`][com.noodlesandwich.rekord.serialization.Serializer] interface from my [*Rekord*][Rekord] library.

    public interface Serializer<R, E extends Exception> {
        <T> R serialize(String name, FixedRekord<T> rekord) throws E;
    }

This takes a `FixedRekord` and serializes it to an `R`. `R` can be an XML document, a JSON document, or maybe just a `java.util.Map` or a string. Now, serializing to JSON can cause exceptions, but converting a `Rekord` into a `Map` definitely won't throw an exception. If I had declared `serialize` as throwing `Exception`, you'd have to handle an exception in both cases, even when I could guarantee that one wouldn't be thrown in the latter case. Conversely, if I'd declared it without an exception, the JSON serialiser would have to wrap its exceptions in `RuntimeException`, which would mean the caller would be unaware of potential failure. Neither scenario is great.

Here's the [JSON serializer][com.noodlesandwich.rekord.serialization.JacksonSerializer], which uses Jackson:

    public final class JacksonSerializer implements Serializer<Void, IOException> {
        private final Writer writer;

        private JacksonSerializer(Writer writer) {
            this.writer = writer;
        }

        @Override
        public <T> Void serialize(String name, FixedRekord<T> rekord) throws IOException {
            ...
        }

        ...
    }

`JacksonSerializer` will throw an `IOException` on failure, and the caller will have to make sure they can handle this, either by propagating it or doing something about it.

Now let's look at my [`MapSerializer`][com.noodlesandwich.rekord.serialization.MapSerializer]:

    public final class MapSerializer implements SafeSerializer<Map<String, Object>> {
        @Override
        public <T> Map<String, Object> serialize(String name, FixedRekord<T> rekord) {
            ...
        }

        ...
    }

No exception. But that's a different interface, right? Of *course* the [`SafeSerializer`][com.noodlesandwich.rekord.serialization.SafeSerializer] wouldn't throw an exception. Well, here it is:

    public interface SafeSerializer<R> extends Serializer<R, ImpossibleException> {
        @Override
        <T> S serialize(String name, FixedRekord<T> rekord);
    }

    public final class ImpossibleException extends RuntimeException {
        private ImpossibleException() { }
    }

The `SafeSerializer` *is* a `Serializer`, but parameterised with an exception that's impossible to construct, and so can never be thrown. That exception is a form of `RuntimeException`, and so isn't checked, and doesn't need to be handled by the caller. This means that when you invoke the `serialize` method on the `MapSerializer`, the compiler knows you don't need to handle the exception and won't force you to.

So there we have it. By parameterising the exception type, we can define an interface that is flexible enough to declare exceptional behaviour when it's present, but not force you to handle it when it's absent. The best of both worlds.

[Rekord]: https://github.com/SamirTalwar/Rekord
[com.noodlesandwich.rekord.serialization.Serializer]: https://github.com/SamirTalwar/Rekord/blob/master/core/src/main/java/com/noodlesandwich/rekord/serialization/Serializer.java
[com.noodlesandwich.rekord.serialization.SafeSerializer]: https://github.com/SamirTalwar/Rekord/blob/master/core/src/main/java/com/noodlesandwich/rekord/serialization/SafeSerializer.java
[com.noodlesandwich.rekord.serialization.JacksonSerializer]: https://github.com/SamirTalwar/Rekord/blob/master/jackson/src/main/java/com/noodlesandwich/rekord/serialization/JacksonSerializer.java
[com.noodlesandwich.rekord.serialization.MapSerializer]: https://github.com/SamirTalwar/Rekord/blob/master/core/src/main/java/com/noodlesandwich/rekord/serialization/MapSerializer.java
