# Expressions

The **expressions** in YarnSpinner provide a way to dynamically change the flow or the content
of the dialogue, based on [variables], combined with [operators] or [function] calls. They are
used in several places:

- to insert a dynamic text into a [line];
- to create or update a [variable];
- as part of a [command] such as `<<if>>` or `<<set>>`;
- to compute the values of [markup] attributes.

An expression always evaluates synchronously, meaning that it cannot wait for user's input, nor
perform an action over time, nor carry out any computationally intensive calculations in a
different thread. If such functionality is really desired, then it can be achieved via a
[user-defined command] that waits for the calculation to succeed and then stores the result into
some global [variable], which can then be accessed from an expression.


```{toctree}
:hidden:

Variables   <variables.md>
Operators   <operators.md>
Functions   <functions/functions.md>
```

[command]: ../commands/commands.md
[function]: functions/functions.md
[line]: ../lines.md
[markup]: ../markup.md
[operators]: operators.md
[user-defined command]: ../commands/user_defined_commands.md
[variable]: variables.md
[variables]: variables.md
