<!-- cSpell:ignore lorem ipsum dolor sit amet, consectetur adipiscing elit -->
<!-- cSpell:ignore Malfoy -->

# Markup

**Markup** is a mechanism for annotating fragments of a dialogue line. They are somewhat similar to
HTML tags, or you can imagine them as comments in a google document. Importantly, markup tags
only annotate the text, but do not alter its content or display in the game. It is up to the
developer to actually use the markup information in their game.


## Syntax

Markup tags are denoted with the name of the tag, placed in square brackets: `[tag_name]`. The
corresponding closing tag would be `[/tag_name]`. Every markup tag must have a corresponding
closing tag:

```yarn
Hello, [wavy]world[/wavy]!
```

Markup tags may nest within each other, though they must nest properly, in the sense that one
markup range must be fully inside or fully outside another:

```yarn
Lorem [S]ipsum dolor [A]sit[/A] amet[/S], consectetur [B]adipiscing[/B] elit
```

The special **close-all** markup tag `[/]` closes all currently opened markup ranges. It is also
handy in situations where the name of the markup tag is long and you don't want to repeat it:

```yarn
Lorem ipsum dolor sit amet, [bold]consectetur adipiscing elit[/]
```

The **self-closing** markup tags have the form `[tag_name/]`. These tags mark a single location
within the text. In addition, if such tag is surrounded by spaces on both sides, then a single
space after the tag will be removed from the resulting text. If this is undesired, then simply
add an extra space after the markup tag:

```yarn
Lorem ipsum dolor sit amet, [wave/] consectetur adipiscing elit.
```

Markup tags also accept parameters, which are similar to HTML tag attributes. The names of these
parameters can be arbitrary IDs, and the values are expressions that will be evaluated each time
the line is executed. Thus, the values of attributes can be dynamic:

```yarn
Lorem ipsum [color name=$color]dolor sit amet[/color]
```

Markup tags can surround dynamic text (interpolated expressions), which will cause the length of
the marked up span to be different every time the line is run. At the same time, markup cannot be
generated dynamically -- in the sense that the interpolated expressions will always be inserted
as-is, even if they contain some text in square brackets.

```yarn
Hello, [b]{$player}[/b]!
```

Lastly, it should be noted that if you want to have an actual text in square brackets within a
line, then in order to prevent it from being parsed as markup you can escape the square brackets
with a backslash `\`:

```yarn
Hello, \[world\]!
```

```{seealso}
- [MarkupAttribute](../runtime/markup_attribute.md): the runtime representation
  of a markup attribute within a line.
```


## Examples


### Mark a piece of text with a different style

In this example the word "Voldemort" is rendered with a special "cursed" markup, indicating that
the word itself is cursed (it is up to you how to actually render this in a game). Similarly, the
word "stupid" in the second line has an emphasis, which may be rendered as italic text.

```yarn
title: Scene117_Harry_MrMalfoy
---
Harry: I'm not afraid of [cursed]Voldemort[/cursed]!
MrMalfoy: You must be really brave... or really [i]stupid[/i]?
===
```


### Provide additional information about a text fragment

In this example the word "Llewellyn" has a tooltip information associated with it. A game might
render this with a special style suggesting that the user may hover over that word to see a
tooltip with a minimap for where to find this NPC.

```yarn
title: MonkDialogue
---
Monk: Visit [tooltip place="TS" x=23 y=-74]Llewellyn[/] in Thunderstorm, \
      he will be able to help you.
===
```


### Indicate where special non-text tokens may be inserted

The `[item/]` markup tag will be replaced by the item's name, which will also be interactive:
tapping this name would bring up the item's description card.

```yarn
title: BlacksmithQuest
---
<<local $reward = if($chapter==1, "A0325", "A1018")>>
Smith: Find me my lost ring, and I'll give you this [item id=$reward/].
===
```
