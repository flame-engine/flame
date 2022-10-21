# Yarn language

The dialogue is written in Yarn language and stored in `.yarn` files, which can later be added to
a `YarnProject`. From the `YarnProject`'s perspective it doesn't matter how many source files there
are, it will treat them as if they all were parts of a single large file.


## Nodes

Each `.yarn` file may contain one or more **nodes**. A *node* is a small fragment of text that
approximately equal to a single conversation. For example, if you have a node named "Barn", then
you can request `YarnProject` to *run* this node -- that is, display its dialogue lines in turns,
until we reach the end of the node, at which point the dialogue stops.

If you have a conversation that is too large to comfortably fit within a single node (or where
parts are reused), then such conversation can be split into multiple nodes, and then you can use
`<<jump>>` commands to transition between them.

Each node has the following format:

```text
title: NODE_TITLE
NODE_TAGS?
---
NODE_BODY
===
```

Here `NODE_TITLE` is the name of the node. Preferably this should be an ID (that is, contain only
latin letters, digits, or underscores). All nodes within the project must have unique titles.

Optional `NODE_TAGS` allow you to attach arbitrary information to the node, which will be visible
to the game but not to the player. These tags come in the form `tag_name: tag text`.

The `NODE_BODY` is where the dialogue itself is located. There are three main types of content
within the body: [Lines](#lines), [Options](#options), and [Commands](#commands).

For example:

```text
title: Gloomy_Morning
CameraZoom: 2
---
You: Good morning!
Guard: You call this good? 'Tis as crappy as could be
You: Why, what happened?
Guard: Don't you see the fog? Chills me through to my very bones
You: Sorry to hear that... So, can I pass?
Guard: Can I get some exercise cutting you into pieces? Maybe that'll cheer me up!
You: Ok, I think I'll be going. Hope you feel better soon!
===
```


## Lines

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

For example:

```text
Prosser: You want me to come and lie there...
Ford: Yes
Prosser: In front of the bulldozer?  #perplexed:1
Ford: Yes
Prosser: In the mud.   #perplexed:2
Ford: In, as you say, the mud.
(low rumbling noise...)
```


## Options

**Options** are special lines that display a menu of choices for the player, and the player must
select one of them in order to continue. The options are indicated with an arrow `->` at the start
of the line:

```text
You arrive at the edge of the forest. The road dives in, but there is another \
one going around the edge.
-> Go straight ahead, on the beaten path
-> Take the road along the forest's edge
-> Turn back
```

An option is typically followed by an indented list of statements (which may, again, be lines,
options, or commands). These statements indicate how the dialogue should proceed if the player
chooses that particular option. After the control flow finishes running through the block
corresponding to the selected option, the dialogue resumes after the option set.

Other than the arrow indicator, an option follows the same syntax as the line. Thus, it can have a
character name, the main text, interpolated expressions inside, and hashtags. One additional
feature that an option can have is the **conditional**. A conditional is a short-form `<<if>>`
command after the text of an option (but before the hashtags):

```text
Guard: 50 coins and you can cross the bridge.
-> Alright, take the money  <<if $gold >= 50>>
   <<take gold:50>>
   <<grant bridge_pass>>
-> I have so much money, here, take a 100  <<if $gold >= 10000>>
   <<take gold:100>>
   <<grant bridge_pass>>
   Guard: Wow, so generous!
   Guard: But I wouldn't recommend going around telling everyone that you \
          have "so much money"
-> That's too expensive!
   Guard: Is it? My condolences
-> How about I kick your butt instead?
   <<fight>>
```

When the conditional evaluates to `true`, the option is delivered to the game normally. If the
conditional turns out to be false, the option is still delivered, but is marked as `unavailable`.
It is up to the game whether to display such option as greyed out, or crossed, or not show it at
all; however, such option cannot be selected.

As you have noticed, options always come in groups: after all, the player must select among several
possible choices. Thus, any sequence of options that are adjacent to each other in the dialogue,
will always be delivered as a single bundle to the frontend.


## Commands

The **commands** are special instructions surrounded with double angle-brackets: `<<stop>>`. There
are both built-in and user-defined commands.


### `<<if>>`

The **\<\<if\>\>** command evaluates its condition, and based on that decides which statements to
execute next. This command may have multiple parts, which look as following:

```text
<<if condition1>>
  statements1...
<<elseif condition2>>
  statements2...
...
<<else>>
  statementsN...
<<endif>>
```

The `<<elseif>>`s and the `<<else>>` are optional, whereas the final `<<endif>>` is mandatory. Also,
notice that the statements within each block are indented.

During the runtime, the conditions within each `<<if>>` and `<<elseif>>` blocks will be evaluated
in turn, and the first one which evaluates to `true` will have its statements executed next. These
conditions must be boolean.


### `<<jump>>`

The **\<\<jump\>\>** command unconditionally moves the execution pointer to the start of the target
node. The target node will now become "current":

```text
<<jump FarewellScene>>
```

The argument of this command is the id of the node to jump to. It can be given in plain text if the
name of the node is a valid ID. If not, you can use the text interpolation syntax to supply an
arbitrary node id (which includes dynamically defined node ids):

```text
<<jump {"Farewell Scene"}>>
```


### `<<stop>>`

The **\<\<stop\>\>** command is very simple: it immediately stops evaluating the current node, as if
we reached the end of the dialogue. This command takes no arguments.


### `<<wait>>`

The **\<\<wait\>\>** command forces the engine to wait the provided number of seconds before
proceeding with the dialogue.

```text
<<wait 1.5>>
```


### `<<declare>>`


### `<<set>>`


### User-defined commands


## Expressions


### Functions


### User-defined functions
