---
title: "Querying the web with ScraperWiki"
slug: querying-the-web-with-scraperwiki
date: 2012-11-26T22:31:52Z
aliases:
  - /post/36617913577/querying-the-web-with-scraperwiki
---

A few weeks ago, a friend of mine, [Michael
Cook](https://twitter.com/mtrc), retweeted a request for up-to-date
discounts on the Steam store:

> I want to pay someone to help me automatically scrape steam for all
> the data here, and then format it correctly.
> [bit.ly/dSvuvx](http://t.co/yENcBatX "http://bit.ly/dSvuvx")
>
> — Lewie Procter (@LewieP) [November 8,
> 2012](https://twitter.com/LewieP/status/266607012534693888)

I was interested, so I tweeted back. As part of the deal, though, I
asked Lewie if I could open source both the code and the data using
[ScraperWiki](https://scraperwiki.com/). He was all for it.

<!--more-->

Let me tell you a bit about ScraperWiki. It's a simple idea: you write a
script that scrapes something (usually a web site), and they run it
every day for you. You then have a database you can query using SQL, as
well as all sorts of meta-information like how long the last run took
and how many pages it hit. It's not perfect, but it does do the job
pretty well.

So [I wrote a scraper in
Ruby](https://scraperwiki.com/scrapers/steam_sale/). It's not the best
code I've ever written, and it has no tests. You use the web browser to
write your script, and testing is mostly resigned to just running it
once in a while to see if it works. I'm actually quite partial to this
approach, as web sites can easily change from underneath you, and so
unit tests would be pointless for data extraction. For manipulation and
storage, they'd be fairly useful. I could write the code separately and
run the tests on my own continuous integration server, but I couldn't
see an easy way to hook ScraperWiki up to a GitHub repository or
something. Unless I tell it to scrape GitHub and execute the code that
it finds, but that's way too meta, even for me.

I ended up scraping all prices for all games, not just the discounted
ones. I was hitting the pages anyway, and I figured it'd be more useful
for someone, even if we didn't actually need the data. This means we're
pulling in approximately 1800 games in three different countries—5400
price records per day. ScraperWiki handles this pretty well. Hopefully
it'll keep it up over time as this database grows to a massive scale.
The code runs pretty quickly, partially because the Ruby installation
that ScraperWiki provides has Typhoeus and Nokogiri installed (for
downloading web pages and parsing HTML respectively). These libraries
are ridiculously fast compared to most of their peers, and they're two
of the many tools that make Ruby excellent for any software development
pertaining to the web.

Once you've got the data into a database, the next step is to turn it
into something useful. For Lewie, that was [a list of all the discounted
games with their latest
prices](https://scraperwiki.com/views/steam_sale_latest/) so he could
post it up on [SavyGamer](http://savygamer.co.uk/). I wrote this in Ruby
too, querying my database and spitting out HTML. It was pretty simple to
do—you're given a single function, `ScraperWiki::select`, and you just
trade SQL for rows. You don't have to just spit out HTML either. Give it
your own content type, and dump whatever you like to standard output.

I'm writing this post mostly because Michael had never heard of
ScraperWiki before, and I was shocked. It's an excellent tool for
scraping something, and by default, the code and data is all public. If
you take a look at the scraper I wrote, you can use their API to query
all Steam prices for the last four days, and over time, that database
will grow. Perhaps in 2013, this will be a really useful data source,
and I'm really glad to have been a part of building it.
