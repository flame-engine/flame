# Lines

A **line** is the most common element of the Yarn dialogue. It's just a single phrase that a
character in the game says. In a `.yarn` file, a **line** is represented by a single line of text
in a [node body]. A line may contain the following elements:

- A character ID;
- Normal text;
- Escaped text;
- Interpolated expressions;
- Markup;
- Hashtags;
- A comment at the end of the line;
- (a line, however, cannot contain commands).

A **line** is represented with the [DialogueLine] class in Jenny runtime.


## Character ID

If a line starts with a single word followed by a `:`, then that word is presumed to be the name
of the character who is speaking that line. In the following example there are two characters
talking to each other: Prosser and Ford, and the last line has no character ID.

```yarn
title: Bulldozer_Conversation
---
Prosser: You want me to come and lie there...
Ford: Yes
Prosser: In front of the bulldozer?
Ford: Yes
Prosser: In the mud.
Ford: In, as you say, the mud.
(low rumbling noise...)
===
```

It is worth emphasizing that a character ID must be a valid ID -- that is, it cannot contain
spaces or other special characters. In the example below "Harry Potter" is not a valid character ID,
while all other alternatives are ok.

```yarn
title: Hello
---
Harry Potter: Hello, Hermione!
Harry_Potter: Hello, Hermione!
HarryPotter: Hello, Hermione!
Harry: Hello, Hermione!
===
```

If you want to have a line that starts with a `WORD + ':'`, but you don't want that word to be
interpreted as a character name, then the colon can be [escaped](#escaped-text):

```yarn
title: Warning
---
Attention\: The cake is NOT a lie
===
```

```{note}
All characters must be **declared** using the [\<\<character\>\>] command
before they can be used in a script.
```


## Interpolated expressions

You can insert dynamic text into a line with the help of **interpolated expression**s. These
expressions are surrounded with curly braces `{}`, and everything inside the braces will be
evaluated, and then the result of the evaluation will be inserted into the text.

```yarn
title: Greeting
---
Trader: Hello, {$player_name}! Would you like to see my wares?
Player: I have only {plural($money, "% coin")}, do you have anything I can afford?
===
```

The expressions will be evaluated at runtime when the line is delivered, which means it can produce
different text during different runs of the line.

```yarn
title: Exam_Greeting
---
<<if $n_attempts == 0>>
  Professor: Welcome to the exam!
  <<jump Exam>>
<<elseif $n_attempts < 5>>
  Professor: You have tried {plural($n_attempts, "% time")} already, but I \
             can give you another try.
  <<jump Exam>>
<<else>>
  Professor: You've failed 5 times in a row! How is this even possible?
<<endif>> 
===
```

After evaluation, the text of the expression will be inserted into the line as-is, without any
further processing. Which means that the text of the expression may contain special characters
(such as `[`, `]`, `{`, `}`, `\`, etc), and they don't need to be escaped. It also means that the
expression cannot contain markup, or produce a hashtag, etc.

Read more about expressions in the [Expressions] section.


## Markup

The **markup** is a mechanism for text annotation. It is somewhat similar to HTML tags, except that
it uses square brackets `[]` instead of angular ones:

```yarn
title: Markup
---
Wizard: No, no, no! [em]This is insanity![/em]
===
```

The markup tags do not alter the text of the line, they merely insert annotations in it. Thus, the
line above will be delivered in game as "No, no, no! This is insanity!", however there will be
additional information attached to the line that shows that the last 17 characters were marked with
the `em` tag.

Markup tags can be nested, or be zero-width, they can also include parameters whose values can be
dynamic. Read more about this in the [Markup] document.


## Hashtags

Hashtags may appear at the end of the line, and take the following form: `#text`. That is, a hashtag
is a `#` symbol followed by any text that doesn't contain whitespace.

Hashtags are used to add line-level metadata. There can be no line content after a hashtag (though
comments are allowed). A line can have multiple hashtags associated with it.

<!-- cSpell:ignore HPMOR (Harry Potter and the Methods of Rationality) -->
```yarn
title: Hashtags
---
Harry: There is no justice in the laws of Nature, Headmaster, no term for \
       fairness in the equations of motion. #sad // HPMOR.39
Harry: The universe is neither evil, nor good, it simply does not care.
Harry: The stars don't care, or the Sun, or the sky.
Harry: But they don't have to! We care! #elated #volume:+1
Harry: There is light in the world, and it is us! #volume:+2
===
```

In most cases the Jenny engine does not interpret the tags, but merely stores them as part of the
line information. It is up to the programmer to examine these tags at runtime.


## Escaped text

Whenever you have a line that needs to include a character that would normally be interpreted as
one of the special syntaxes mentioned above, then such a character can be **escaped** with a
backslash `\`.

The following escape sequences are recognized: `\\`, `\/`, `\#`, `\<`, `\>`, `\[`, `\]`, `\{`, `\}`,
`\:`, `\-`, `\n`. In addition, there is also `\⏎` (i.e. backslash followed immediately by a
newline).

```yarn
title: Escapes
---
\// This is not a comment  // but this is
This is not a \#hashtag
This is not a \<<command>>
\{This line\} does not contain an expression
Not a \[markup\]
===
```

The `\⏎` escape can be used to split a single long line into multiple physical lines, that would
still be treated by Jenny as if it was a single line. This escape sequence consumes both the
newline symbol and all the whitespace at the start of the next line:

```yarn
title: One_long_line
---
This line is so long that it becomes uncomfortable to read in a text editor. \
    Therefore, we use the backslash-newline escape sequence to split it into \
    several physical lines. The indentation at the start of the continuation \
    lines is for convenience only, and will be removed from the resulting \
    text.
===
```


[node body]: nodes.md#body
[DialogueLine]: ../runtime/dialogue_line.md
[Expressions]: expressions/expressions.md
[Markup]: markup.md
