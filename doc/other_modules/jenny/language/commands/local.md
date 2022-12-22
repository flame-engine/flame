# `<<local>>`

The **\<\<local\>\>** command creates a new variable within the current node, and initializes it
to some starting value. Thus, it is similar to [\<\<declare\>\>][declare], except that the variable
it creates is visible within a single node only.

The syntax of the `<<local>>` command can be one of the following:

```yarn
<<local $VARIABLE = EXPRESSION>>
<<local $VARIABLE = EXPRESSION as TYPE>>
```

This would create a variable with the name `$VARIABLE` (all variables in YarnSpinner start with a
`$` sign), and assign it the value of `EXPRESSION`. In the second form, it will ensure that the
type of the expression is equal to `TYPE`, otherwise a compile-time error will be thrown. Thus, the
second form serves as the explicit annotation for the type of the variable created.

The following restrictions apply:

- each local variable can be declared only once within a node;
- the name of a local variable cannot coincide with the name of any global variable.


## Examples

In this example the variable `$roll` will only be needed temporarily within this one node, so it
wouldn't make sense to declare it as global.

```yarn
title: a_dice_roll
---
<<local $roll = dice(6)>>
<<if $roll == 1>>
  You've rolled 1, rotten luck...
<<elseif $roll == 2>>
  You've rolled 2, which is still below the average. Try harder!
<<elseif $roll == 3>>
  You've rolled 3.14159265 (well, almost).
<<elseif $roll == 4>>
  Your roll is an unlucky number. Please roll again
<<else>>
  You've rolled 10 (when rounded to the nearest ten). Good job!
<<endif>>
===
```

[declare]: declare.md
