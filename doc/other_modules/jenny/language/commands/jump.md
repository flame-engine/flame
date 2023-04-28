# `<<jump>>`

The **\<\<jump\>\>** command stops executing the current node, and then immediately starts running
the target node. This is similar to a `goto` in many programming languages. For example:

```yarn
<<jump FarewellScene>>
```

The argument of this command is the id of the node to jump to. It can be given either as a plain
node ID, or as an expression in curly braces:

```yarn
<<jump {"Ending_" + $ending}>>
```

If the expression evaluates at runtime to an unknown name, then a `NameError` exception will be
thrown.


## See Also

- [\<\<visit\>\>](visit.md) command, which jumps into the destination node temporarily and then
  returns to the same place in the dialogue as before.
