# `<<if>>`

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
