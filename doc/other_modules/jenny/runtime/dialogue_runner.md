# DialogueRunner

The **DialogueRunner** class is used to execute the dialogue at runtime. If you think of a
[YarnProject] as a dialogue program consisting of multiple [Node]s as "functions", then a
`DialogueRunner` is the virtual machine that can run a single "function" within that "program".

A single DialogueRunner may only execute one dialogue `Node` at a time. It is an error to try to
run another Node before the first one concludes. However, it is possible to create multiple
DialogueRunners for the same YarnProject, and then they would be able to execute multiple dialogues
simultaneously (for example, in a crowded room there could be multiple dialogues occurring at once
with different groups of people).

The job of a DialogueRunner is to fetch the dialogue lines in the correct order and at the
appropriate pace, to execute the logic in dialogue scripts, and to branch according to user input
in [DialogueChoice]s. The output of a DialogueRunner, therefore, is a stream of dialogue statements
that need to be presented to the player. Such presentation, is handled by the [DialogueView]s.


## Construction

The constructor takes two required parameters:

**yarnProject** `YarnProject`
: The [YarnProject] which the dialogue runner will be executing.

**dialogueViews** `List<DialogueView>`
: The list of [DialogueView]s that will be presenting the dialogue within the game. Each of these
  `DialogueView`s can only be assigned to a single `DialogueRunner` at a time.


## Properties

**project** `YarnProject`
: The [YarnProject] within which the dialogue runner is running.


## Methods

**runNode**(`String nodeName`)
: Executes the node with the given name, and returns a future that completes only when the dialogue
  finishes running (which may be a while). A single `DialogueRunner` can only run one node at a
  time.

**sendSignal**(`dynamic signal`)
: Delivers the given `signal` to all dialogue views, in the form of a `DialogueView` method
  `onLineSignal(line, signal)`. This can be used, for example, as a means of communication between
  the dialogue views.

  The `signal` object here is completely arbitrary, and it is up to the implementations to decide
  which signals to send and to receive. Implementations should ignore any signals they do not
  understand.

**stopLine**()
: Requests (via `onLineStop()`) that the presentation of the current line be finished as quickly
  as possible. The dialogue will then proceed normally to the next line.


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


[DialogueChoice]: dialogue_choice.md
[DialogueView]: dialogue_view.md
[Node]: node.md
[YarnProject]: yarn_project.md
