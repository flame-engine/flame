# Node

The **Node** class represents a single [node] within the `.yarn` script. The objects of this class
will be delivered to your [DialogueView]s with the methods `onNodeStart()`, `onNodeFinish()`.


## Properties

**title** `String`
: The title (name) of the node.

**tags** `Map<String, String>`
: Additional tags specified in the header of the node. The map will be empty if there were no tags
  besides the required `title` tag.

**iterator** `Iterator<DialogueEntry>`
: The content of the node, which is a sequence of `DialogueLine`s, `DialogueChoice`s, or
  `Command`s.

[node]: ../language/nodes.md
[DialogueView]: dialogue_view.md
