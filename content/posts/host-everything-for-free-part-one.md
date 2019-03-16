---
title: "Host Everything For Free, Part One"
draft: true
---

_Or very very cheap, at least._

---

I run a few websites. The one that gets the most traffic right now is [communitycodeofconduct.com][], which is used by a number of software communities to as a place to start thinking about how their community behaves to each other.

I host that site at zero charge.

[communitycodeofconduct.com]: https://communitycodeofconduct.com/

## GitHub Pages, and the decline of the server

I'm sure you know of GitHub already. It's where people host their source code, both for their open-source projects and for private stuff. You may also have realised that many open-source software teams host their website on GitHub too. For example, the website of my favourite command-line tool, [_jq_][jq], is hosted on GitHub Pages, among many others.

![jq website](jq-website.png)

Now, in general, GitHub Pages is intended to host websites that are associated with open-source software, keeping both the source code and the website in one place. However, nothing's stopping you from simply pushing up a website with no associated source code (aside from the source of the website itself, of course). All you need is a repository with a `gh_pages` branch and their servers will take care of the rest.

Your domain name will be _[username].github.io_. We'll talk about custom domains later. You can also host websites at _[username].github.io/[repository]_, but that should generally be reserved for websites tied to a source code repository.

[jq]: https://stedolan.github.io/jq/

### Getting used to client-side coding

For a number of a reasons, GitHub Pages don't allow server-side code, so you're limited to HTML, CSS and JavaScript. However, it's based on [Jekyll][], a website pre-processor, so you have a few more options. Jeykll allows you to use languages such as [Markdown][] or [Textile][] so you don't have to think about HTML when you're worrying about content. In addition, it allows for more advanced templating than HTML gives you on its own, using [Liquid][] for pre-processing. This means that you can create a layout file called _\_layouts/default.html_, like this:

    <!DOCTYPE html>
    <html>
        <head>
            <meta charset="utf-8"/>
            <title>{{ title | upcase }}</title>
        </head>
        <body>
            {{ content }}
        </body>
    </html>

And then a content file in Markdown, named _index.md_, like this:

    ---
    layout: default
    title: Example
    ---

    # This is a heading

    And here is some *emphasised* and _strong_ text.

      1. Lists are great in [Markdown](https://daringfireball.net/projects/markdown/).
      2. You just start typing and they appear.
      3. Your code looks just like the output.
      4. Nested lists work too:
        * This one's unordered.
        * Just like you would when you're hashing out notes.
        * Very little thinking required.

The block at the top is called "[YAML][] front matter", and is used both by the Jekyll pre-processor _and_ by your own templates. In this example, the `layout` property specifies the layout file to include the contents in, and the `title` property is used by that layout to set the page title. Remember that even if you don't have any properties to include, Jekyll will _only_ convert Markdown into HTML if you include a block, so just create an empty one:

    ---
    ---

    # Here goes the Markdown.

Jekyll has much more functionality than this. For example, it can generate a blog index from a series of files representing your blog posts. To explore these and more, [check out the documentation][jekyll].

[jekyll]: https://jekyllrb.com/
[liquid]: https://github.com/Shopify/liquid/wiki
[markdown]: https://daringfireball.net/projects/markdown/
[textile]: http://redcloth.org/textile
[yaml]: http://yaml.org/

### Let's see what it looks like

In order to see your site, you'll need to run Jekyll locally. The simplest way to do this is to install the [_github-pages_][github-pages] gem. This gem doesn't provide any functionality on its own, but simply depends on the same version of Jekyll as GitHub do, as well as include the extra functionality they bundle on top of it, such as [_jekyll-feed_][jekyll-less], a plugin for Jekyll that generates an Atom feed of your blog posts.

Install the latest version of Ruby if you don't have it already (I recommend using [RVM][]), then install the [github-pages][] gem:

    $ gem install github-pages

If you have installed RVM, I'd recommend segregating your GitHub Pages "gemset" from others beforehand so that you don't get gem collisions, and marking the directory as such:

    $ rvm use --create --ruby-version ruby@github-pages

This will create a special directory for your GitHub Pages gems, and switch your `GEM_HOME` environment variable so that you only use the gems in that directory. It will also create two files, _.ruby-version_ and _.ruby-gemset_, that instruct RVM to always use this particular Ruby version and gemset in this directory. For example, at the time of writing, I'm running the latest version of Ruby (v2.3.0), so my _.ruby-version_ is `ruby-2.3.0` and my _.ruby-gemset_, as specified, is `github-pages`. Then install your gems as normal.

Once you've done that, you can start a Jekyll server. The Jekyll server compiles your files _once_, when it starts, into a website and stores it in the _\_site_ directory.

    $ jekyll serve --watch

The `--watch` switch tells it to regenerate the files each time you change anything. This is only used during in development—when you publish your site, it will only be generated once, then served until you modify it and re-publish.

If everything went well, you should see something like this:

    Server address: http://127.0.0.1:4000/
    Server running... press ctrl-c to stop.

Your site is running at [http://127.0.0.1:4000/][], a.k.a. [http://localhost:4000/][]. Head over there and take a look!

![my first website](my-first-website.png)

Well, nobody said it was going to be _pretty_. Start throwing some CSS on top and spruce it up. As you modify the site, you should just be able to hit _Reload_ in your browser and see the changes immediately.

Don't forget to `git commit` as you go! We'll be pushing this to GitHub soon, and that commit history is going to be useful when something (inevitably) breaks. This is the Internet, after all.

Oh, one more thing. You don't want to commit your _\_site_ directory, as it's just the generated form of your other files, so create a file called _.gitignore_ and put the following into it:

    _site

That tells Git not to worry about it.

[github-pages]: https://rubygems.org/gems/github-pages
[jekyll-feed]: https://rubygems.org/gems/jekyll-feed
[rvm]: https://rvm.io/

### Time to publish it

Once you've got something shiny, get it online. The first step is to create a GitHub repository specifically for your project.

Head over to [GitHub][] and log in, then click the _New Repository_ button.

Create a repository named _[your username].github.io_. Make sure you spell your username correctly, or it won't work.

![create a new repository](create-a-new-repository.png)

Next, run the commands provided to push your code up to your website. As you already have a repository, you want the second set of commands. Copy and paste them into your terminal.

![git push](git-push.png)

If you reload the GitHub page, you'll see your files are now up on GitHub. (If you see problems in your command line, you probably need to [set up your SSH keys][github: generating an ssh key] and try again.) Then head over to your new domain and check out your work of art.

![work of art](work-of-art.png)

When you want to make a change, just `git commit` and `git push`. Your changes will be online in seconds. Free hosting, sorted.

[github]: https://github.com/
[github: generating an ssh key]: https://help.github.com/articles/generating-an-ssh-key/

## Your domain, because you're worth it

Once you have your website up and running, you might want to register it with a custom domain name. For example, I don't use [samirtalwar.github.io](), I use [noodlesandwich.com]().

The first step towards this is to register a domain name. There are countless domain name registrars out there, and you're welcome to pick any of them as long as they allow you to just buy a domain name without hosting. I'm a fan of [Hover][], which has average pricing, a very usable control panel and great customer support, but it's by no means the only one. Just stay away from the really big names such as GoDaddy and 123-reg and you'll be fine.

Once you've got your domain, you'll need to point it to GitHub. If you want to use a subdomain (which I use for [talks.samirtalwar.com]()), this is easier. Head over to your domain name registrar and opt to customise the DNS settings for your new domain. If you're not sure how to do this, Googling "DNS [name of your registrar]" usually finds a useful tutorial.

Once you're there, you'll need to set the appropriate records. If you're looking to set up a subdomain, create a `CNAME` record with the name of your subdomain ("talks", in my case) and your GitHub domain as the target. If you're looking to point your entire "apex" domain to GitHub Pages, then you'll need to set up two `A` records with no name (or sometimes "@"), and the two GitHub IP addresses as the values. You can find the IP addresses on GitHub's own instructions for [setting up an apex domain][github: setting up an apex domain].

![DNS set-up][dns-set-up.png]

Finally, you just need to create a file in the root of your website source repository called _CNAME_. It should have one line, which contains the domain you're looking to point to it. Nothing more, nothing less. For example, if you owned _example.com_, the contents of _CNAME_ would be:

    example.com

Easy.

![GitHub CNAME][github-cname.png]

It can take up to 72 hours for your registrar's DNS servers to propagate the new DNS settings all over the world. That said, it's usually closer to 24 for an existing domain, and can take as little as 15 minutes for a brand new domain. Keep checking your new domain, and hopefully you'll have your website up and running on a custom domain name before long.

[hover]: https://www.hover.com/
[github: setting up an apex domain]: https://help.github.com/articles/setting-up-an-apex-domain/

---

Next time, we'll look at hosting images and other files, as well as third-party assets such as CSS and JavaScript.
