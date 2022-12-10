# Commands
The **commands** are special instructions surrounded with double angle-brackets: `<<stop>>`. There
are both built-in and user-defined commands.


### `<<if>>`

The **\<\<if\>\>** command evaluates its condition, and based on that decides which statements to
execute next. This command may have multiple parts, which look as following:

```yarn
<<if condition1>>
  statements1...
<<elseif condition2>>
  statements2...
<<else>>
  statementsN...
<<endif>>
```

The `<<elseif>>`s and the `<<else>>` are optional, whereas the final `<<endif>>` is mandatory. Also,
notice that the statements within each block are indented.

During the runtime, the conditions within each `<<if>>` and `<<elseif>>` blocks will be evaluated
in turn, and the first one which evaluates to `true` will have its statements executed next. These
conditions must be boolean.


### `<<stop>>`

The **\<\<stop\>\>** command is very simple: it immediately stops evaluating the current node, as if
we reached the end of the dialogue. This command takes no arguments.


### `<<wait>>`

The **\<\<wait\>\>** command forces the engine to wait the provided number of seconds before
proceeding with the dialogue.

```yarn
<<wait 1.5>>
```


### `<<declare>>`


### `<<set>>`




```{toctree}
:hidden:

<<jump>>     <jump.md>
```
