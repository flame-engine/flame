# flame_yarn

```{warning}
This library is currently under development. Many features are still missing.
```

<!-- Image taken from https://pxhere.com/en/photo/932518  License: CC0 Public Domain -->
![fireball](../../images/fireball-small.jpg){align=right}

The **flame_yarn** library allows you to easily add **dialogue** into your game, which includes
anything from simple exchange of phrases between characters, to user-controlled responses and
non-linear conversations that adjust with the game state. The `flame_yarn` library was inspired
by the [Yarn Spinner] library for Unity.

Adding dialogue into any game generally consists of two major stages:

1. Writing the text for the dialogue script;
2. Interactively displaying it within the game.

In fact, these tasks are so different, that they will often be done by separate people on the team.
The `flame_yarn` library allows these tasks to be carried out completely independently.

[Yarn Spinner]: https://docs.yarnspinner.dev/


## Writing dialogue

In `flame_yarn`, the dialogue is written in plain text and stored in `.yarn` files that are added
to the game as assets. The `.yarn` file format is developed by the authors of [Yarn Spinner], and
is specifically designed to make writing easy.

The simplest form of the yarn dialogue looks like a play:

```text
title: Scene1_Gregory_and_Sampson
---
Sampson: Gregory, on my word, we'll not carry coals.
Gregory: No, for then we should be colliers.
Sampson: I mean, an we be in choler, we'll draw.
Gregory: Ay, while you live, draw your neck out of collar.
Sampson: I strike quickly being moved.
Gregory: But thou are not quickly moved to strike.
Sampson: A dog of the house of Montague moves me.
Gregory: To move is to stir, and to be valiant is to stand. Therefore, \
         if thou art moved, thou runn'st away.
===
```

This simple exchange, when rendered within a game, will be shown as a sequence of phrases spoken
in turn by the two characters. The `DialogRunner` will allow you to control whether the dialogue
proceeds automatically or requires "clicking-through" by the user.

The `.yarn` format supports many more advanced features too, allowing the dialogue to proceed
non-linearly, supporting variables and conditional execution, giving the player an ability to
select their response, etc. Most importantly, the format is so intuitive that it can be generally
understood without having to learn it:

```text
title: Slughorn_encounter
---
<<if visited(Horcrux_question)>>
  Slughorn: Sorry, Tom, I don't have time right now.
  <<stop>>
<<endif>>

Slughorn: Oh hello, Tom, is there anything I can help you with?
Tom: Good {time_of_day()}, Professor.
-> I was curious about the 12 uses of the dragon blood.
    Slughorn: Such an inquisitive mind! You can read about that in the "Most \
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

For more information, see the [Yarn Language](language.md) section.


## Using the dialogue in a game

Once you have written your dialogue in yarn files, you will want to display it within your game.
In order to do this, you create a `YarnProject`, which is a central place where all dialogue-related
information will be gathered.

Once a dialogue is initiated, the `YarnProject` will send the lines to one or more `DialogueView`s,
whose responsibility is to display those lines within the game itself.

```dart
final yarn = YarnProject()
    ..addFunction('luck', player.luckDraw)
    ..parseFilesFromPattern(r'/assets/yarn/.*\.yarn$')
    ..addDialogueView(playerLineDialogueView)
    ..addDialogueView(playerOptionsDialogueView)
    ..addDialogueView(npcDialogueView)
    ..finalize();
```

For more information, see the [Yarn Project](yarn_project.md) section.


```{toctree}
:hidden:

Yarn language     <language.md>
Yarn Project      <yarn_project.md>
```
