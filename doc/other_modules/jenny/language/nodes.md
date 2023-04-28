# Nodes

A **node** is a small section of text, that represents a single conversation or interaction with
an NPC. Each node has a **title**, which can be used to *run* that node in a [DialogueRunner], or to
[jump] to that node from another node.

You can think of a node as if it was a function in a regular programming language. Running a node
is equivalent to calling a function, and it is not possible to start execution in the middle of a
node/function. When a function becomes too large, we will usually want to split it into multiple
smaller ones -- the same is true for nodes, when a node becomes too long it is a good idea to split
it into several smaller nodes.

Each node consists of a **header** and a **body**. The header is separated from the body with 3
(or more) dashes, and the body is terminated with 3 "=" signs:

```yarn
// NODE HEADER
---
// NODE BODY
===
```

In addition, you can use 3 (or more) dashes to separate the header from the previous content, which
means the following is also a valid node:

```yarn
---------------
// NODE HEADER
---------------
// NODE BODY
===
```

A **node** is represented with a [Node] class in Jenny runtime.

[Node]: ../runtime/node.md


## Header

The header of a node consists of one or more lines of the form `TAG: CONTENT`. One of these lines
must contain the node's **title**, which is the name of the node:

```yarn
title: NodeName
```

The title of a node must be a valid ID (that is, starts with a letter, followed by any number of
letters, digits, or underscores). All nodes within a single project must have unique titles.

Besides the title, you can add any number of extra tags into the node's header. Jenny will store
these tags with the node's metadata, but will not interpret them in any other way. You will then
be able to access these tags programmatically

```yarn
title: Alert
colorID: 0
modal: true
---
WARNING\: Entering Radioactive Zone!
===
```


## Body

The body of a node is where the dialogue itself is located. The body is just a sequence of
statements, where each statement is either a [Line], an [Option], or a [Command]. For example:

```yarn
title: Gloomy_Morning
camera_zoom: 2
---
You  : Good morning!
Guard: You call this good? 'Tis as crappy as could be
You  : Why, what happened?
Guard: Don't you see the fog? Chills me through to the bones
You  : Sorry to hear that... 
You  : So, can I pass?
Guard: Can I get some exercise cutting you into pieces? Maybe that'll warm me up!
You  : Ok, I think I'll be going. Hope you feel better soon!
===
```

[DialogueRunner]: ../runtime/dialogue_runner.md
[jump]: commands/jump.md
[Line]: lines.md
[Option]: options.md
[Command]: commands/commands.md
