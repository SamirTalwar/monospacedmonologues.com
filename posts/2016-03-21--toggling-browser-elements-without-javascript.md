---
title: "Toggling browser elements without JavaScript"
date: 2016-03-21T08:00:29Z
---

I'm having a sleepy weekend, and I feel like the rhythm of one week on Docker, one off is about as much as I can handle. (Those posts take work!) So we're going to have a week of random stuff before I get back to it. Hope you don't mind the wait. :-)

---

Last week, I was working on a website at work, and I used a useful trick that I came up with a few years ago. I'm sure I'm not the first person to figure this one out, but I think it's cool and not everyone had heard of it before, so I thought I'd write about it.

It's a fairly common thing in UIs for something to be toggled on or off. For example, we might be showing and hiding a navigation menu, or booking a table at a restaurant online.

On the web, it's pretty typical to use JavaScript for this. Here's a restaurant booking example that uses jQuery to change CSS classes as we change our minds about the time. In practice, we'd also store the selected time in a variable or hidden form element so that we can submit the selected option to the server later.

Click on the options and watch the `.selected` style apply to the selected item.

<p data-height="268" data-theme-id="0" data-slug-hash="jqBZvO" data-default-tab="result" data-user="SamirTalwar" class="codepen">See the Pen <a href="http://codepen.io/SamirTalwar/pen/jqBZvO/">toggles with JavaScript</a> by Samir Talwar (<a href="http://codepen.io/SamirTalwar">@SamirTalwar</a>) on <a href="http://codepen.io">CodePen</a>.</p>

Now, there's two problems here. One is that we're not using semantic HTML. The second is that we're using JavaScript, and I'd rather avoid it.

JavaScript does one thing here that CSS can't: it stores the state of the world so that it can look it up next time. Because we can use CSS classes in the DOM, as well as variables in the JavaScript execution context, to store state, we can make decisions based on past events. You can't do that with pure styling.

However, there's other ways to store things in the DOM.

This is really a form, and as such, should have `<input>` elements. As they're options, we probably want radio buttons. Something like this:

    <input id="time-1900" type="radio" name="time" value="19:00"/>

We can set those up… but they look pretty boring.

<p data-height="268" data-theme-id="0" data-slug-hash="dMvdqm" data-default-tab="result" data-user="SamirTalwar" class="codepen">See the Pen <a href="http://codepen.io/SamirTalwar/pen/dMvdqm/">toggles with boring radio buttons</a> by Samir Talwar (<a href="http://codepen.io/SamirTalwar">@SamirTalwar</a>) on <a href="http://codepen.io">CodePen</a>.</p>

However, now we have state. Those radio buttons are checked and unchecked, and we can detect this in CSS with the `:checked` pseudo-class selector. We can use that to trigger a style change to a sibling with the `+` or `~` sibling selectors.

    .time input:checked ~ label {
      background: #4caf50;
      color: #000;
    }

As the `<label>` triggers the radio button, we can hide the button and just keep the label. A bit more styling and voila: we have an example that looks exactly like the first one, but uses semantic HTML and CSS instead of JavaScript.

<p data-height="268" data-theme-id="0" data-slug-hash="mPWXzz" data-default-tab="result" data-user="SamirTalwar" class="codepen">See the Pen <a href="http://codepen.io/SamirTalwar/pen/mPWXzz/">toggles with CSS</a> by Samir Talwar (<a href="http://codepen.io/SamirTalwar">@SamirTalwar</a>) on <a href="http://codepen.io">CodePen</a>.</p>

As much as I like instructing the computer what to do, I prefer to declare the state of things and have my environment—in this case, my browser—figure it out. My procedural code needs testing, maintaining and debugging. HTML and CSS need none of that.

<script async src="//assets.codepen.io/assets/embed/ei.js"></script>
