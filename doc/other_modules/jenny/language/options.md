# Options

**Options** are special lines that display a menu of choices for the player, and the player must
select one of them in order to continue. The options are indicated with an arrow `->` at the start
of the line:

```yarn
title: Adventure
---
You arrive at the edge of the forest. The road dives in, but there is another \
one going around the edge.
-> Go straight ahead, on the beaten path (x)
-> Take the road along the forest's edge
-> Turn back
===
```

An option is typically followed by an indented list of statements (which may, again, be lines,
options, or commands). These statements indicate how the dialogue should proceed if the player
chooses that particular option. After the control flow finishes running through the block
corresponding to the selected option, the dialogue resumes after the option set.

Other than the arrow indicator, an option follows the same syntax as the [line]. Thus, it can have
a character name, the main text, interpolated expressions, markup, and hashtags. One additional
feature that an option can have is the **conditional**. A conditional is a short-form `<<if>>`
command after the text of an option (but before the hashtags):

```yarn
title: Bridge
---
Guard: 50 coins and you can cross the bridge.
-> Alright, take the money  <<if $gold >= 50>>
   <<take gold 50>>
   <<grant bridge_pass>>
-> I have so much money, here, take a 100  <<if $gold >= 10000>>
   <<take gold 100>>
   <<grant bridge_pass>>
   Guard: Wow, so generous!
   Guard: But I wouldn't recommend going around telling everyone that you \
          have "so much money"
-> That's too expensive!
   Guard: Is it? My condolences
-> How about I [s]kick your butt[/s] instead?
   <<if $power < 1000>>
      <<fight>>
   <<else>>
      You make a very reasonable point, sir, my apologies.
      <<grant bridge_pass>>
   <<endif>>
===
```

When the conditional evaluates to `true`, the option is delivered to the game normally. If the
conditional turns out to be false, the option is still delivered, but is marked as `unavailable`.
It is up to the game whether to display such option as greyed out, or crossed, or not show it at
all; however, such option cannot be selected.

As you have noticed, options always come in groups: after all, the player must select among several
possible choices. Thus, any sequence of options that are adjacent to each other in the dialogue,
will always be delivered as a single bundle to the frontend. This is called the **choice set**.

[line]: lines.md
