---
title: "Pointless work"
slug: pointless-work
date: 2023-02-02T09:30:00+01:00
---

We leave our mess everywhere.

## The demise of LastPass, or at least the beginning of the end

In August, LastPass notified its customers, including me, that there had been a breach in it systems, and some data was leaked. I didn’t worry. After all, “We have no evidence that this incident involved any access to customer data or encrypted password vaults.” The keys to the kingdom were safe.

On 1st December, it got a little murkier. It turns out someone "was able to gain access to certain elements of our customers’ information”. Still, I didn’t worry.

Then, on 22nd December, we were notified that “an unauthorized party gained access to a third-party cloud-based storage service”. Specifically:

> The threat actor was also able to copy a backup of customer vault data from the encrypted storage container which is stored in a proprietary binary format that contains both unencrypted data, such as website URLs, as well as fully-encrypted sensitive fields such as website usernames and passwords, secure notes, and form-filled data.

Well, this was a surprise.

I was furious. And I wasn’t the only one. Not because the vaults had been stolen—after all, LastPass is a very high-profile target—but because they were apparently not treated with the care that any of its customers expected. (There have been those in the security industry blowing the whistle on LastPass for a while, but I hadn’t seen anything close to this damning.)

Specifically, website URLs were not encrypted. This meant that:

1. Without any password cracking, the attacker had a decent profile of _whose_ password was more valuable to crack.
2. As LastPass often stores the full URL of where you set your password, it could include sensitive data such as a reset token. A poorly-designed password reset workflow might mean that all the attacker would need to do is visit that URL and set a new password.

Long story short, a URL _is_ sensitive data and LastPass haven’t done their job. Later, some more information came to light regarding their mishandling of password iteration strength, which I won’t go into. If you’re interested, [Steve Gibson dedicated a podcast to the topic](https://twit.tv/shows/security-now/episodes/905).

Shortly afterwards, I (and many, many of their other customers) decided to jump ship. I went for 1Password, based mostly on their reputation among security-savvy friends of mine, but also because of their decent UX. I have no particular affinity to them, and would probably be just as happy (or unhappy) with another provider. But still, so far, so good, and I love the integration with Fastmail’s “masked email” service, which means I can quickly generate a new email per service. (I decided to take the opportunity to move away from Gmail at the same time; gotta get myself disconnected from the big bad Goog.)

And so, I began the long, long process of changing my password (and email address) on every single website.

## The long, slow migration

I really wish I’d kept detailed statistics on this, but rough guesses from memory will have to do.

When I started, I had over 600 passwords stored in LastPass.

I’m now pretty much done, with the exceptions of some shared passwords, and I have 170 passwords in 1Password—roughly 25% of what I had saved a month and a bit ago.

This was virtual spring cleaning, for me. I hadn’t seriously looked at my LastPass vault in years. Some of the passwords there were saved in 2010, or perhaps even earlier. A lot of the sites were completely defunct; some had been gone for so long that the domain had been snapped up and repurposed, leaving me very confused about why I would have ever signed up for a place that delivers sandwiches to my New York apartment. Fortunately, the password simply didn’t work, and I moved on.

In other places, it worked, but I had zero interest in preserving the account. I would hunt for a “delete my account” button. Sometimes it was easy, sometimes it was hard, sometimes it required arcane incantations and a trip to my favourite search engine to figure out. I was pleasantly surprised at the number of websites that provided an easy way to delete my account. If I had to guess from memory, I’d say that around 50% of the sites I was registered made it automatic. Some made it _too_ easy—I felt like I’d cheated, but most required me to re-enter my password or at least my username.

I can only imagine I have the GDPR to thank for this. 10 years ago, I expect most websites provided no option to delete your data, or at least your account credentials, and no one would even think of asking. Alas, we do not live in such innocent times, and our privacy is something we must all consider. Even the expectation of no privacy (for example, if you _still_ have a Facebook account for some reason) is a choice, and a conscious one for many of us.

Many other sites weren’t quite so helpful. That said, there’s a magic trick: again, due to the GDPR, every website now has a privacy policy that actually means something. This means that it includes an email address or other contact mechanism which goes not to customer support, but (typically) directly to a privacy officer, who will take your request to delete your data seriously. Now, most of the time, I just wanted to close my account, and didn’t particularly care about my “right to be forgotten”, but those are the magic words that make sure your account definitely gets closed.

Technically, they’re only the magic words if you live in Europe, but most of the time, they don’t seem to care—it’s easier not to bother asking and just process the request.

And so, I have sent approximately a hundred emails asking various website owners to delete my account, sometimes with the magic words attached so they take it seriously. Of those, about half have actually dealt with my request; at the time of writing, I still have 40-odd websites in my “not deleted yet” folder. I’ve had some contact from some of them, but I don’t really understand why it takes a month of emails back and forth to make it clear that yes, I really really really don’t want the account I haven’t used since 2014.

And here, I guess, lies the flaw in GDPR: if they never, ever reply, will I bother making a formal complaint to whatever authority I need to complain to? I don’t even know who that _is_, so no, I will not bother. The website owners know this. I’m surprised half of them actually did process the request manually—it seems like such a lot of work.

## So what’s your point?

Oh, are articles supposed to have a point now? I’m just rambling.

Perhaps I’m just bitter at spending so much time on an endeavour which was, quite possibly, totally pointless. No one is hacking my passwords, no one cares about my defunct account with a shop in the UK that only sells coffee equipment and doesn’t have my credit card stored anyway. I’m a little paranoid, and I guess I was looking for an excuse to do some early spring cleaning.

You could, if you were so inclined, piece together enough of my life from the various websites to perform some low-level identity theft, I guess, but that’d be a lot of effort. I am small fry, in the grand scheme of things. I know this, and yet I still went through the exercise, sending far too many emails for no good reason.

I think I may be feeling guilty about not writing. This process took up my attention, and I didn’t feel like I had enough juice to both change a lot of passwords _and_ produce anything creatively. This combined with the fact that I tend to write more in January, probably due to some inner monologue telling me that even if I didn’t make a New Year’s resolution to write more, I _should_, and so skipping the whole month feels like I did something wrong.

I didn’t, of course. I promise nothing, and often deliver it.

If you made it this far, I am pleasantly surprised. I highly recommend pruning your list of random accounts in random places once in a while. Don’t let it get to 75% utter crap, like I did.
