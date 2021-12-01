---
title: "Docker, Part Sixteen: Logging"
slug: docker-part-sixteen--logging
date: 2016-05-31T07:00:20Z
aliases:
  - /post/145195626992/docker-part-sixteen-logging
---

This post isn't really about Docker, except that it is.

---

It's generally considered good practice to log everything in your application that might be useful. When you've separated parts of the application into different processes, or even worse, distributed it across several computers, logging becomes even more important, as tracing an event through multiple systems isn't easy by default.

The first thing to remember is that if it's important, log it. Treat your log as an event stream. Ideally, you'll be able to reconstruct your database just by replaying your logs.

<!--more-->

The next most important thing is that if it might fail, log it. Events of this type include:

- long-running computations,
- asynchronous behaviour,
- network I/O,
- disk I/O,
- database access,
- user input,
- and lots more.

In the toy application I'm building, [_bemorerandom.com_][bemorerandom.com], the interesting parts here are HTTP requests, which can go wrong in a million different ways, and access to the database, which can often be the cause of failures and slowdown. Because I'm using the [Finatra][] and [Slick][] libraries to handle these kinds of events, I need to configure them to log them appropriately. Fortunately, they both use [SLF4J][], which unifies Java logging libraries, so its just a matter of configuring Logback, my logging library, to pick up on the logging events.

[bemorerandom.com]: https://github.com/SamirTalwar/bemorerandom.com
[finatra]: https://twitter.github.io/finatra/
[logback]: http://logback.qos.ch/
[slf4j]: http://www.slf4j.org/
[slick]: http://slick.lightbend.com/

## Log All The Things

SLF4J standarises two things: a mechanism for naming various log output (usually after the class that's logging), and a list of _log levels_: _trace_ (the least serious), _debug_, _info_, _warn_, _error_, and _fatal_ (the most serious).

The various libraries already log at vaguely-appropriate levels, so I'll configure Logback by creating a _logback.xml_ resource file:

    <?xml version="1.0" encoding="UTF-8"?>
    <configuration>
        <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
            <encoder>
                <pattern>%d{HH:mm:ss.SSS} %-16X{traceId} %-5level %logger{36} - %msg%n</pattern>
            </encoder>
        </appender>

        <logger name="com.bemorerandom" level="DEBUG"/>

        <logger name="slick.jdbc.JdbcBackend" level="DEBUG"/>

        <root level="INFO">
            <appender-ref ref="STDOUT"/>
        </root>
    </configuration>

This says that I want to log everything at info level to the console (not a file; [I can route logs to files later if I like][docker, part thirteen: the twelve-factor app]). Requests are logged at the info level (unless they fail, in which case we get an error instead), so no further customisation is necessary. Anything custom that I want to log (i.e. in the "com.bemorerandom" package) is logged at the debug level. And because I want to see _some_ output, I've selected a specific part of Slick to log at the debug level—this allows me to see the actual SQL queries as they execute.

[docker, part thirteen: the twelve-factor app]: /post/141886562802/docker-part-thirteen-the-twelve-factor-app

When making a request that hits the database:

    $ http docker:8080/dnd/npc/female/dragonborn

The logs look like this:

    21:40:30.028                  DEBUG slick.jdbc.JdbcBackend.statement - Preparing statement: select x2."name", (case when (x3."id" is not null) then x3."name" else null end) from "dnd_npc_first_names" x2 left outer join "dnd_npc_last_names" x3 on x2."race" = x3."race" where (x2."sex" = 'female') and (x2."race" = 'dragonborn') order by RANDOM() limit 1
    21:40:30.055                  DEBUG slick.jdbc.JdbcBackend.benchmark - Execution of prepared statement took 11ms
    21:40:30.394 c9777ffdbd357930 INFO  c.t.f.h.filters.AccessLoggingFilter - 192.168.99.1 - - [27/May/2016:21:40:30 +0000] "GET /dnd/npc/female/dragonborn HTTP/1.1" 200 202 1084 "HTTPie/0.9.3"

There's a lot there for one request, but I'd rather err on the side of caution and get more logs out than less. Debugging is hard enough when you have all the information.

However, once we've got a lot of log lines, filtering them down becomes necessary. And when you need to post-process the logs, a text format such as this one is pretty unhelpful. In order to have a machine handle things for us, we need machine-readable output.

## JSON Logging

The Logstash folks have written an alternative "encoder" for Logback that logs in JSON format. Reconfiguring our appender to use the Logstash encoder:

    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
    </appender>

This is what a similar request looks like in the logs now:

    {"@timestamp":"2016-05-27T22:17:13.940+00:00","@version":1,"message":"Preparing statement: select x2.\"name\", (case when (x3.\"id\" is not null) then x3.\"name\" else null end) from \"dnd_npc_first_names\" x2 left outer join \"dnd_npc_last_names\" x3 on x2.\"race\" = x3.\"race\" where (x2.\"sex\" = 'male') and (x2.\"race\" = 'dwarf') order by RANDOM() limit 1","logger_name":"slick.jdbc.JdbcBackend.statement","thread_name":"AsyncExecutor.default-1","level":"DEBUG","level_value":10000,"HOSTNAME":"debcaddffc6f"}
    {"@timestamp":"2016-05-27T22:17:13.966+00:00","@version":1,"message":"Execution of prepared statement took 6ms","logger_name":"slick.jdbc.JdbcBackend.benchmark","thread_name":"AsyncExecutor.default-1","level":"DEBUG","level_value":10000,"HOSTNAME":"debcaddffc6f"}
    {"@timestamp":"2016-05-27T22:17:14.109+00:00","@version":1,"message":"192.168.99.1 - - [27/May/2016:22:17:14 +0000] \"GET /dnd/npc/male/dwarf HTTP/1.1\" 200 208 1208 \"HTTPie/0.9.3\"","logger_name":"com.twitter.finatra.http.filters.AccessLoggingFilter","thread_name":"ForkJoinPool-1-worker-1","level":"INFO","level_value":20000,"HOSTNAME":"debcaddffc6f","traceId":"5fa7101b85f2a8bb"}

Unfortunately, the main body of the log line isn't broken down further, as Logback is very much tied to strings, but it's still a lot more workable. For example, to find just the HTTP request information of all requests, we can use `jq` with a bit of regular expression magic:

    $ docker logs bemorerandomcom_api_1 2>/dev/null | \
      jq -r '
        select(.logger_name == "com.twitter.finatra.http.filters.AccessLoggingFilter")
        | .message
        | capture("^[^ ]+ - - \\[[^\\]]+\\] \\\"(?<request>[^\\\"]+)\\\"")
        | .request'

Please don't ask how that works. Anyway, the output:

    GET /xkcd HTTP/1.1
    GET /dnd/npc/male/dwarf HTTP/1.1

We could probably do this with a much funkier regex match, but ideally we'd pull all the various parts of the log line into JSON object fields instead, then use simple JSON manipulation to find, correlate and discover information about our application.

I haven't figured out how to do this yet (and I expect I'll one day be writing my own logging library to do so… joy), but let's imagine our log line looked closer to this:

    {"@timestamp":"2016-05-27T22:17:14.109+00:00","@version":1,"ip":"192.168.99.1","request":"GET /dnd/npc/male/dwarf HTTP/1.1","response":{"status":200,"size":208,"time":1208},"user_agent":"HTTPie/0.9.3","logger_name":"com.twitter.finatra.http.filters.AccessLoggingFilter","thread_name":"ForkJoinPool-1-worker-1","level":"INFO","level_value":20000,"HOSTNAME":"debcaddffc6f","traceId":"5fa7101b85f2a8bb"}

Which, prettified, looks like this:

    {
      "@timestamp": "2016-05-27T22:17:14.109+00:00",
      "@version": 1,
      "ip": "192.168.99.1",
      "request": "GET /dnd/npc/male/dwarf HTTP/1.1",
      "response": {
        "status": 200,
        "size": 208,
        "time": 1208
      },
      "user_agent": "HTTPie/0.9.3",
      "logger_name": "com.twitter.finatra.http.filters.AccessLoggingFilter",
      "thread_name": "ForkJoinPool-1-worker-1",
      "level": "INFO",
      "level_value": 20000,
      "HOSTNAME": "debcaddffc6f",
      "traceId": "5fa7101b85f2a8bb"
    }

We could then just pull out the request.

    $ docker logs bemorerandomcom_api_1 2>/dev/null | \
      jq -r 'select(.logger_name == "com.twitter.finatra.http.filters.AccessLoggingFilter") | .request'

You could do the same sort of processing to find only errors and fatal events, or maybe all the requests that took over a second. You could even pipe them into [Logstash][] or [Fluentd][] and use [Kibana][] to visualise the data, or search them in a much more advanced fashion.

[fluentd]: http://www.fluentd.org/
[kibana]: https://www.elastic.co/products/kibana
[logstash]: https://www.elastic.co/products/logstash

When logging in this fashion, your logs become useful even for routine operations. For example, I'm working on a booking system for a client, and I can just search the logs for `.event_type == "booking"` to get an array of all bookings, then group by date and count them to find out how many bookings we've made each day. One day this'll make its way onto a dashboard, but I like to explore my data, and so it's really useful to have an event stream that's easy to control.
