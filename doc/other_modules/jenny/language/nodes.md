# Nodes

Each `.yarn` file will contain one or more **nodes**. A *node* is a small section of text,
approximately the size of a single conversation. For example, if you have a node named "Barn", then
you can request `YarnProject` to *run* this node -- that is, display its dialogue lines in turns,
until we reach the end of the node, at which point the dialogue stops.

If you have a conversation that is too large to comfortably fit within a single node (or where
parts are reused), then such conversation can be split into multiple nodes, and then you can use
`<<jump>>` commands to transition between them.

Each node has the following format:

```yarn
title: NODE_TITLE
custom_tag: content
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

```yarn
title: Gloomy_Morning
CameraZoom: 2
---
You  : Good morning!
Guard: You call this good? 'Tis as crappy as could be
You  : Why, what happened?
Guard: Don't you see the fog? Chills me through to the bones
You  : Sorry to hear that... 
You  : So, can I pass?
Guard: Can I get some exercise cutting you into pieces? Maybe that'll cheer me up!
You  : Ok, I think I'll be going. Hope you feel better soon!
===
```
