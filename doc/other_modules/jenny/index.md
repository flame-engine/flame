<!-- cSpell:ignore Slughorn horcrux horcruxes Moste Potente -->

# Jenny

The **jenny** library is a toolset for adding *dialogue* into a game. The dialogue may be quite
complex, including user-controlled interactions, branching, dynamically-generated content, commands,
markup, state controlled either from Jenny or from the game, custom functions and commands, etc.
The `jenny` library is an unofficial port of the [Yarn Spinner] library for Unity. The name of the
library comes from [spinning jenny], a kind of yarn-spinning machine.

Adding dialogue into any game generally consists of two stages:

1. Writing the text of the dialogue;
2. Interactively displaying it within the game.

With `jenny`, these two tasks are completely separate, allowing the creation of game content and
development of the game engine to be independent.

[Yarn Spinner]: https://docs.yarnspinner.dev/
[spinning jenny]: https://en.wikipedia.org/wiki/Spinning_jenny


## Writing dialogue

In `jenny`, the dialogue is written in plain text and stored in `.yarn` files that are added
to the game as assets. The `.yarn` file format is developed by the authors of [Yarn Spinner], and
is specifically designed for writing dialogue.

The simplest form of the yarn dialogue looks like a play:

```yarn
title: Scene1_Gregory_and_Sampson
---
Sampson: Gregory, on my word, we'll not carry coals.
Gregory: No, for then we should be colliers.
Sampson: I mean, an we be in choler, we'll draw.
Gregory: Ay, while you live, draw your neck out of collar.
Sampson: I strike quickly being moved.
Gregory: But thou art not quickly moved to strike.
===
```

This simple exchange, when rendered within a game, will be shown as a sequence of phrases spoken
in turn by the two characters. The `DialogRunner` will allow you to control whether the dialogue
proceeds automatically or requires "clicking-through" by the user.

The `.yarn` format supports many more advanced features too, allowing the dialogue to proceed
non-linearly, supporting variables and conditional execution, giving the player an ability to
select their response, etc. Most importantly, the format is so intuitive that it can be generally
understood without having to learn it:

```yarn
title: Slughorn_encounter
---
<<if visited("Horcrux_question")>>
  Slughorn: Sorry, Tom, I don't have time right now.
  <<stop>>
<<endif>>

Slughorn: Oh hello, Tom, is there anything I can help you with?
Tom: Good {time_of_day()}, Professor.
-> I was curious about the 12 uses of the dragon blood.
    Slughorn: Such an inquisitive mind! You can read about that in the "Moste \
              Potente Potions" in the Restricted Section of the library.
    <<give restricted_library_pass>>
    Tom: Thank you, Professor, this is very munificent of you.
-> I wanted to ask... about Horcruxes <<if $knows_about_horcruxes>>
    <<jump Horcrux_question>>
-> I just wanted to say how much I always admire your lectures.
    Slughorn: Thank you, Tom. I do enjoy flattery, even if it is well-deserved.
===

title: Horcrux_question
---
Slughorn: Where... did you hear that?
-> Tom: It was mentioned in an old book in the library...
    Slughorn: I see that you have read more books from the Restricted Section \
              than is wise.
    Slughorn: I'm sorry, Tom, I should have seen you'd be tempted...
    <<take restricted_library_pass>>
    -> But Professor!..
        Slughorn: This is for your good, Tom. Many of those books are dangerous!
        Slughorn: Now off you go. And do your best to forget about what you \
                  asked...
        <<stop>>
-> Tom: I overheard it... And the word felt sharp and frigid, like it was the \
   embodiment of Dark Art <<if luck() >= 80>>
    Slughorn: It is a very Dark Art indeed, it is not good for you to know \
              about it...
    Tom: But if I don't know about this Dark Art, how can I defend myself \
         against it?
    Slughorn: It is a Ritual, one of the darkest known to wizard-kind ...
    ...
    <<achievement "The Darkest Secret">>
===
```

This fragment demonstrates many of the features of the `.yarn` language, including:

- ability to divide the text into smaller chunks called *nodes*;
- control the flow of the dialog via commands such as `<<if>>` or `<<jump>>`;
- different dialogue path depending on player's choices;
- disable certain menu choices dynamically;
- keep state information in variables;
- user-defined functions (`time_of_day`, `luck`) and commands (`<<give>>`, `<<take>>`).

For more information, see the [Yarn Language](language/language.md) section.


## Using the dialogue in a game

By itself, the `jenny` library does not integrate with any game engine. However, it provides a
runtime that can be used to build such an integration. This runtime consists of the following
components:

- [`YarnProject`](runtime/yarn_project.md) -- the central repository of information, which knows
  about all your yarn scripts, variables, custom functions and commands, settings, etc.
- [`DialogueRunner`](runtime/dialogue_runner.md) -- an executor that can run a specific dialogue
  node. This executor will send the dialogue lines into one or more `DialogueView`s.
- [`DialogueView`](runtime/dialogue_view.md) -- an abstract interface describing how the dialogue
  will be presented to the end user. Implementing this interface is the primary way of integrating
  `jenny` into a specific environment.


```{toctree}
:hidden:

YarnSpinner language  <language/language.md>
Jenny API             <runtime/index.md>
```
