# `<<stop>>`

The **\<\<stop\>\>** command: immediately stops evaluating the current node, as if you jumped to
its end. This command takes no arguments.

Normally, the effect of this command is that it stops the dialogue. However, if you're only
visiting the current node from a different one, then `<<stop>>` will only exit the current node,
and the execution flow will return to the parent. Thus, the `<<stop>>` command is similar to
`return;` in many programming languages.

```yarn
<<stop>>
```
