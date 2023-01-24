# DialogueRunner

```{dartdoc}
:file: src/dialogue_runner.dart
:symbol: DialogueRunner
:package: jenny
```


## Execution model

The `DialogueRunner` uses futures as a main mechanism for controlling the timing of the dialogue
progression. For each event, the dialogue runner will invoke the corresponding callback on all its
[DialogueView]s, and each of those callbacks may return a future. The dialogue runner then awaits
on all of these futures (in parallel), before proceeding to the next event.

For a simple `.yarn` script like this

```yarn
title: main
---
Hello
-> Hi
-> Go away
   <<jump Away>>
===

title: Away
---
<<OhNo>>
===
```

the sequence of emitted events will be as follows (assuming the second option is selected):

- `onDialogueStart()`
- `onNodeStart(Node("main"))`
- `onLineStart(Line("Hello"))`
- `onLineFinish(Line("Hello"))`
- `onChoiceStart(Choice(["Hi", "Go away"]))`
- `onChoiceFinish(Option("Go away"))`
- `onNodeFinish(Node("main"))`
- `onNodeStart(Node("Away"))`
- `onCommand(Command("OhNo"))`
- `onNodeFinish(Node("Away"))`
- `onDialogueFinish()`

:::{note}
Keep in mind that if a `DialogueError` is thrown while running the dialogue, then the dialogue will
terminate immediately and none of the `*Finish` callbacks will run.
:::


[DialogueView]: dialogue_view.md
