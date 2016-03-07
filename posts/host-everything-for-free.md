# Host Everything For Free

*Or very very cheap, at least.*

---

I run a few websites. The one that gets the most traffic right now is [communitycodeofconduct.com][], which is used by a number of software communities to as a place to start thinking about how their community behaves to each other.

I host that site at zero charge.

[communitycodeofconduct.com]: https://communitycodeofconduct.com/

## GitHub Pages, and the decline of the server

I'm sure you know of GitHub already. It's where people host their source code, both for their open-source projects and for private stuff. You may also have realised that many open-source software teams host their website on GitHub too. For example, the website of my favourite command-line tool, [*jq*][jq], is hosted on GitHub Pages, among many others.

![jq website](jq-website.png)

Now, in general, GitHub Pages is intended to host websites that are associated with open-source software, keeping both the source code and the website in one place. However, nothing's stopping you from simply pushing up a website with no associated source code (aside from the source of the website itself, of course). All you need is a repository with a `gh_pages` branch and their servers will take care of the rest.

Your domain name will be *[username].github.io*. We'll talk about custom domains later. You can also host websites at *[username].github.io/[repository]*, but that should generally be reserved for websites tied to a source code repository.

[jq]: https://stedolan.github.io/jq/

### Getting used to client-side coding

For a number of a reasons, GitHub Pages don't allow server-side code, so you're limited to HTML, CSS and JavaScript. However, it's based on [Jekyll][], a website pre-processor, so you have a few more options. Jeykll allows you to use languages such as [Markdown][] or [Textile][] so you don't have to think about HTML when you're worrying about content. In addition, it allows for more advanced templating than HTML gives you on its own, using [Liquid][] for pre-processing. This means that you can create a layout file called *_layouts/default.html*, like this:

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

And then a content file in Markdown, named *index.md*, like this:

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

The block at the top is called "[YAML][] front matter", and is used both by the Jekyll pre-processor *and* by your own templates. In this example, the `layout` property specifies the layout file to include the contents in, and the `title` property is used by that layout to set the page title. Remember that even if you don't have any properties to include, Jekyll will *only* convert Markdown into HTML if you include a block, so just create an empty one:

    ---
    ---

    # Here goes the Markdown.

Jekyll has much more functionality than this. For example, it can generate a blog index from a series of files representing your blog posts. To explore these and more, [check out the documentation][Jekyll].

[Jekyll]: https://jekyllrb.com/
[Liquid]: https://github.com/Shopify/liquid/wiki
[Markdown]: https://daringfireball.net/projects/markdown/
[Textile]: http://redcloth.org/textile

### Let's see what it looks like

In order to see your site, you'll need to run Jekyll locally. The simplest way to do this is to install the [*github-pages*][github-pages] gem. This gem doesn't provide any functionality on its own, but simply depends on the same version of Jekyll as GitHub do, as well as include the extra functionality they bundle on top of it, such as [*jekyll-feed*][jekyll-less], a plugin for Jekyll that generates an Atom feed of your blog posts.

Install the latest version of Ruby if you don't have it already (I recommend using [RVM][]), then install the [github-pages][] gem:

    $ gem install github-pages

If you have installed RVM, I'd recommend segregating your GitHub Pages gemset from others beforehand so that you don't get gem collisions, and marking the directory as such:

    $ rvm use --create --ruby-version ruby@github-pages

This will create two files, *.ruby-version* and *.ruby-gemset*, that instruct RVM to always use this particular Ruby version and gemset in this directory. For example, at the time of writing, I'm running the latest version of Ruby (v2.3.0), so my *.ruby-version* is `ruby-2.3.0` and my *.ruby-gemset*, as specified, is `github-pages`. Then install your gems as normal.

Once you've done that, you can start a Jekyll server. The Jekyll server compiles your files *once*, when it starts, into a website and stores it in the *_site* directory.

    $ jekyll serve --watch

The `--watch` switch tells it to regenerate the files each time you change anything. This is only used during in development—when you publish your site, it will only be generated once, then served until you modify it and re-publish.

If everything went well, you should see something like this:

    Server address: http://127.0.0.1:4000/
    Server running... press ctrl-c to stop.

Your site is running at [http://127.0.0.1:4000/][], a.k.a. [http://localhost:4000/][]. Head over there and take a look!

![my first website](my-first-website.png)

Well, nobody said it was going to be *pretty*. Start throwing some CSS on top and spruce it up. As you modify the site, you should just be able to hit *Reload* in your browser and see the changes immediately.

Don't forget to `git commit` as you go! We'll be pushing this to GitHub soon, and that commit history is going to be useful when something (inevitably) breaks. This is the Internet, after all.

Oh, one more thing. You don't want to commit your *_site* directory, as it's just the generated form of your other files, so create a file called *.gitignore* and put the following into it:

    _site

That tells Git not to worry about it.

[github-pages]: https://rubygems.org/gems/github-pages
[jekyll-feed]: https://rubygems.org/gems/jekyll-feed
[RVM]: https://rvm.io/

### Time to publish it

Once you've got something shiny, get it online. The first step is to create a GitHub repository specifically for your project.

Head over to [GitHub][] and log in, then click the *New Repository* button.

Create a repository named *[your username].github.io*. Make sure you spell your username correctly, or it won't work.

![create a new repository](create-a-new-repository.png)

Next, run the commands provided to push your code up to your website. As you already have a repository, you want the second set of commands. Copy and paste them into your terminal.

![git push](git-push.png)

If you reload the GitHub page, you'll see your files are now up on GitHub. (If you see problems in your command line, you probably need to [set up your SSH keys][GitHub: Generating an SSH key] and try again.) Then head over to your new domain and check out your work of art.

![work of art](work-of-art.png)

When you want to make a change, just `git commit` and `git push`. Your changes will be online in seconds. Free hosting, sorted.

[GitHub]: https://github.com/
[GitHub: Generating an SSH key]: https://help.github.com/articles/generating-an-ssh-key/

## Your domain, because you're worth it

## cdnjs.com, because files are big and not your problem

## Heroku, for when you need that server back

## S3, if you have buckets of assets

## CloudFlare, and your 15 minutes of fame
