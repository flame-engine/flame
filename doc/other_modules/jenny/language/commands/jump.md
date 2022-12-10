# `<<jump>>`

The **\<\<jump\>\>** command unconditionally moves the execution pointer to the start of the target
node. The target node will now become "current":

```yarn
<<jump FarewellScene>>
```

The argument of this command is the id of the node to jump to. It can be given in plain text if the
name of the node is a valid ID. If not, you can use the text interpolation syntax to supply an
arbitrary node id (which includes dynamically defined node ids):

```yarn
<<jump {"Farewell Scene"}>>
```
