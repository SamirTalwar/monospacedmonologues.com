# I Promise I'll Call You Back

*This post stems from a discussion with Constantina and others on the [Codebar][] Slack team.*

In JavaScript, callbacks can be unpleasant to work with. [Callback Hell][] has a great explanation about how to make them work well, but it doesn't change the fact that a programming style that lends itself to misuse can be problematic, and callbacks are misused all over the place. Even in documentation.

One of the big problems with callbacks is remembering to handle the error. This is the `if (err) { … }` pattern you see a lot. If you find yourself copying and pasting error-handling code all over the place, you might want to use *promises* instead.

Promises can chain error-handling. So instead of:

```javascript
fs.readdir(source, (err, files) => {
  if (err) {
    console.log('Error finding files: ' + err)
  } else {
    files.forEach((filename, fileIndex) => {
      console.log(filename)
      gm(source + filename).size((err, values) => {
        if (err) {
          console.log('Error identifying file size: ' + err)
        } else {
          ...
        }
      })
    })
  }
})
```

*(This snippet was adapted from the first example Callback Hell gives us.)*

You can just handle the error once:

```javascript
fs.readdir(source)
  .then(files => files.forEach((filename, fileIndex) => {
    console.log(filename)
    return gm(source + filename).size()
  })).then(values => {
      ...
  }).catch(err => console.log(err))
```

The error-handling is now in one place, which reduces duplication throughout the code base, keeping it clean and easier to read, but more importantly, making sure we don't forget to handle the error when we add more behaviour or move code around.

[[MORE]]

## Screw Callbacks, Let's Use Promises

Er… not exactly. Sometimes promises can't do the job.

In general, a function run in the context of a promise is run either once, or never.

Here's an example:

```javascript
new Promise((resolve, reject) => {
  // this function is called once
  request.get('http://example.com/thing.json', (error, response, body) => {
    if (error) {
      reject(error)
      return
    }
    // insert more error handling
    resolve(JSON.parse(body))
  })
}).then(thing => {
  // this function is called *if and only if* the previous function succeeded
  document.querySelector("#thing .name").textContent = thing.name
}).catch(error => {
  // this function is called *if and only if* one of the previous functions failed
  const element = document.querySelector("#error")
  element.textContent = error.message
  element.style.display = 'block'
})
```

Sometimes, though, we want to run a function more than once. An obvious example is in the case of the `.map` or `.filter` methods on arrays, which both run the function passed once for each element in the array.

```javascript
[1, 2, 3, 4, 5].filter(value => value % 2 === 1) // run 5 times
```

In the context of asynchronous behaviour, it's still useful to run a function more than once. For example, we might want to retry on failure. For example, take a look at the function, [`async.retry`][async.retry], which tries a piece of behaviour more than once:

```javascript
async(
  {times: 3},
  callback => requestUserProfile(user, callback),
  (error, profile) => {
    // do something
  }
)
```

Callbacks, in general, are far more flexible than promises. While both make it easy to specify behaviour, only callbacks make it easy to wrap existing behaviour.

The [tmp][] library is a popular one for creating temporary files and directories. Here's how we use it:

```javascript
tmp.file({keep: true}, (error, path, fd, cleanup) => {
  if (error) {
    throw error
  }
  doThingsWith(path, error => {
    if (error) {
      handle(error)
    }
    cleanup()
  })
})
```

This is a really useful library, but I really dislike having to remember to call the `cleanup` function when I'm done. What if I'd forgotten and returned from the `if (error)` block, so `cleanup` wasn't called? Or added an extra level of callbacks but left the call to `cleanup` in the second one, so it was cleaned up before we were done? Or just forgot it in the first place?

This is a problem. But it's not a problem we can solve using promises.  If we tried to rewrite this using promises, we'd end up with something like this:

```javascript
tmp.file()
  .then(file => {
    return doThingsWith(file.path)
      .then(
        () => file.cleanup(),
        () => file.cleanup()) // handles the case in which there was an error
  })
  .catch(error => handle(error))
```

We still have to call `cleanup`, because we don't know when we're done.

However, if we combine the two techniques, something interesting happens:

```javascript
tmp.withFile(file => doThingsWith(file.path))
  // after `doThingsWith(file.path)` resolves, the file is cleaned up
  .catch(error => handle(error))
```

*(Both styles above are available in the [tmp-promise][] package.)*

By combining the flexibility of callbacks (to automatically clean up the file) with the simplicity of promises (so we know when we're done), we end up with some very terse code, with minimum boilerplate.

In general, you want to use the right tool for the job. In this context, sometimes it'll be callbacks, sometimes promises, sometimes the [async][] library… whatever [reduces duplication and increases clarity][Four Elements of Simple Design] is probably the right move.

---

If you want to read more about the different styles of asynchronous behaviour in JavaScript, I wrote an essay version of my talk, *[I've got 99 problems and asynchronous programming is 127 of them][]*, which I think you might like.

[Codebar]: https://codebar.io/
[Callback Hell]: http://callbackhell.com/
[async.retry]: https://caolan.github.io/async/docs.html#retry
[tmp]: https://www.npmjs.com/package/tmp
[tmp-promise]: https://www.npmjs.com/package/tmp-promise
[async]: https://caolan.github.io/async/
[Four Elements of Simple Design]: http://blog.jbrains.ca/permalink/the-four-elements-of-simple-design
[I've got 99 problems and asynchronous programming is 127 of them]: https://noodlesandwich.com/talks/99-problems/essay
