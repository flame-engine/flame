# Expressions

The **expressions** in YarnSpinner provide a way to dynamically change the flow or the content
of the dialogue, based on [variables] or *function* calls. They are used in several places:

- to insert a dynamic text into a [line];
- as part of a [command] such as `<<if>>` or `<<set>>`;
- to compute the values of [markup] attributes.




## Functions

An expression may also contain function calls, which are indicated by the name of the function,
followed by its arguments in parentheses. The parentheses are required, even when there are no
arguments:

```yarn
<<set $roll_2d6 = dice(6) + dice(6)>>
<<set $random = random()>>
```


```{toctree}
:hidden:

Variables   <variables.md>
Operators   <operators.md>
```

[command]: ../commands/commands.md
[line]: ../lines.md
[markup]: ../markup.md
[variables]: variables.md
