# `<<declare>>`

The **\<\<declare\>\>** command creates a new global variable and assigns an initial value to it.
After this command is encountered, the declared variable will be available for use anywhere a
variable might be needed, including in inline expressions, other commands, and even other declare
statements.

Unlike most other commands, the `<<declare>>` command is executed at compile time, i.e. when the
yarn scripts are parsed. When the dialogue runs, it has no effect, since by that time the variable
is already initialized and ready for use. For this reason, the `<<declare>>` commands must be
placed outside of nodes, at the root level of the script, making it clear that these commands do
not execute when a node runs.

For example:

```yarn
<<declare $monicker = "boy">>

---------------
title: Greeting
---------------
Teacher: Welcome to the class, {$monicker}!
===
```

Here the `<<declare>>` command introduces a new variable called `$monicker`, of type `String`, and
assigns it an initial value of `"boy"`. Later on, this variable is used inside the "Greeting" node.
By that time, the value of the variable can be anything: it could be changed in some other node, or
by the game itself. The `<<declare>>` statement, however, is necessary to tell Jenny that this is
a valid variable name, and what type it has.

From the project organization standpoint, the recommended approach is to put all the `<<declare>>`
statements into a separate file, and then make sure that this yarn file is parsed first. This will
ensure that all global variables are declared before they are used in subsequent nodes.

If your game supports save-games, then you would probably want to store the values of yarn global
variables too. In this case restoring the saved values should be done *after* all yarn scripts are
parsed (otherwise the engine will think that a variable is declared twice).


## Syntax

There are several forms of the `<<declare>>` statement. The most common one is the following:

```yarn
<<declare $VARIABLE = EXPRESSION>>
```

Here `$VARIABLE` is the name of the variable being declared (all variables in Yarn start with a `$`
sign), and `EXPRESSION` is either a literal or a more complicated [expression] that will be
evaluated at compile time in order to provide the initial value for the variable. The type of the
variable will be deduced from the type of the `EXPRESSION`.

Another possible syntax for the `<<declare>>` command is this:

```yarn
<<declare $VARIABLE as TYPE>>
```

where `TYPE` is one of `Bool`, `Number`, or `String`. This will create a variable of the given type,
and initialize it with values `false`, `0`, or `""` respectively.

Finally, it is possible to combine these two syntaxes:

```yarn
<<declare $VARIABLE = EXPRESSION as TYPE>>
```

This can be useful when the type of the `EXPRESSION` is not immediately obvious, and you want to
make the declaration more explicit. The compiler will check that the type of the `EXPRESSION` is
the same as `TYPE`, and will throw a compile-time error otherwise.


## Examples

```yarn
<<declare $prefix = "Mr.">>
<<declare $gold = 100>>
<<declare $been_to_hell = false>>

<<declare $name as String>>
<<declare $distanceTraveled as Number>>

<<declare $birthDay = randomRange(1, 365) as Number>>
<<declare $vulgarity = GetObscenitySetting() as Bool>>
```

:::{note}
It is a good idea to accompany each `<<declare>>` with a doc-comment explaining the purpose of the
variable, similarly to how you would document public members of a class.
:::


[expression]: ../expressions/expressions.md
