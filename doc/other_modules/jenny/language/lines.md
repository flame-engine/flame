# Lines

A **line** is the most common element of the Yarn dialogue. It's just a single phrase that a
character in the game says. A line may contain the following elements:

- Character id followed by a `:`, at the start of the line. This serves as an indicator of which
  character is talking, although it is up to the game how to interpret that information. Lines
  without a character id are allowed too, and it is again up to the game how to interpret that (for
  example, this could mean narration, or indicate some surrounding sounds).

- The text of the line, possibly with interpolated [Expressions](#expressions). Certain special
  characters may need to be escaped if you want to include them on the line. These include: `#`,
  `[`, `<`, `{`.

- Hashtags at the end of the line. These are not shown to the player, but rather passed along with
  the line as an extra information. It is up to the game how to interpret these tags. A hashtag is
  a string of characters starting with `#` without any whitespace.

For example :

```yarn
Prosser: You want me to come and lie there...
Ford: Yes
Prosser: In front of the bulldozer?  #perplexed:1
Ford: Yes
Prosser: In the mud.   #perplexed:2
Ford: In, as you say, the mud.
(low rumbling noise...)
```
