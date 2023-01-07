# Miscellaneous functions


## plural(x, words...)

Returns the correct plural form depending on the value of variable `x`.

This function is locale-dependent, and its implementation and signature changes depending on the
`locale` property in the `YarnProject`. In all cases, the first argument `x` must be numeric,
while all other arguments should be strings.


## visit_count(node)

Returns the number of times that the `node` was visited.

A node is considered "visited" if the dialogue enters and then exits that node. The node can be
exited either through the normal dialogue flow, or via the [\<\<stop\>\>] command. However, if a
runtime exception occurs while running the node, then the visit will not count. 

The `node` argument must be a string, and it must contain a valid node name. If a node with the
given name does not exist in the project, an exception will be thrown.

```{seealso}
- [`visited(node)`](#visitednode)
```


## visited(node)

Returns `true` if the node with the given title was visited, and `false` otherwise.

For a node to be considered "visited", the dialogue must enter and then exit the node at least
once. For example, within a node "X" the expression `visited("X")` will return `false` during the
first run of this node, and `true` upon all subsequent runs.

The `node` argument must be a string, and it must contain a valid node name. If a node with the
given name does not exist in the project, an exception will be thrown.

```{seealso}
- [`visit_count(node)`](#visit_countnode)
```


[\<\<stop\>\>]: ../../commands/stop.md
