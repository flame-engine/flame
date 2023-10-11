# Functions

A **function** in YarnSpinner is the same notion as in any other programming language, or in math:
it takes a certain number of arguments, and then computes and returns the result. A function call
is indicated by the name of the function, followed by its arguments in parentheses. The parentheses
are required, even when there are no arguments:

```yarn
<<set $roll_2d6 = dice(6) + dice(6)>>
<<set $random = random()>>
```

There are around 20 built-in functions in Jenny, listed below; and it is also possible to add
user-defined functions as well.


## Built-in functions

- **Random functions**
  - [`dice(n)`](random.md#dicen)
  - [`random()`](random.md#random)
  - [`random_range(a, b)`](random.md#random_rangea-b)

- **Numeric functions**
  - [`ceil(x)`](numeric.md#ceilx)
  - [`dec(x)`](numeric.md#decx)
  - [`decimal(x)`](numeric.md#decimalx)
  - [`floor(x)`](numeric.md#floorx)
  - [`inc(x)`](numeric.md#incx)
  - [`int(x)`](numeric.md#intx)
  - [`round(x)`](numeric.md#roundx)
  - [`round_places(x, n)`](numeric.md#round_placesx-n)

- **Type conversion functions**
  - [`bool(x)`](type.md#boolx)
  - [`number(x)`](type.md#numberx)
  - [`string(x)`](type.md#stringx)

- **Other functions**
  - [`if(condition, then, else)`](misc.md#ifcondition-then-else)
  - [`plural(x, ...)`](misc.md#pluralx-words)
  - [`visit_count(node)`](misc.md#visit_countnode)
  - [`visited(node)`](misc.md#visitednode)


## User-defined functions

In addition to the built-in functions, you can also define any number of **user-defined functions**
which can later be used in your yarn scripts. The syntax for these functions is exactly the same
as for the built-in functions: it consists of a function name, followed by the arguments in
parentheses.

Each user-defined function has a fixed signature, declared at the time when the function is added
to the `YarnProject`. A function must have a fixed number of arguments of specific types, and a
fixed return type.

All user-defined functions must be added to the `YarnProject` before they can be used. A compile
error will be raised if the parser encounters an unknown function, or if the number or types of
arguments do not match.

User-defined functions can be used for a variety of purposes, such as:

- implement functionality that is currently missing in Jenny;
- interface with the game engine;
- provide access to "variables" stored outside of Jenny;
- etc.

```yarn
title: Blacksmith
---
// This example showcases several hypothetical user-defined functions:
// - broken(slot): checks whether the item in the given slot is broken;
// - name(slot): gives the name for an item in a slot, e.g. "sword" or "bow";
// - money(): returns the current amount of money that the player has.
// At the same time, functions `round()` and `plural()` are built-in.

<<if broken("main_hand")>>
  <<local $repair_cost = round(value("main_hand") / 5)>>

  Blacksmith: Your {name("main_hand")} seems to be completely broken!
  Blacksmith: I can fix it for just {plural($repair_cost, "% coin")}
  -> Ok, do it  <<if money() >= $repair_cost>>
  -> I'll be fine...
<<endif>>
===
```

```{seealso}
- [`FunctionStorage`](../../../runtime/function_storage.md) -- document
  describing how to add user-defined functions to a `YarnProject`.
```


```{toctree}
:hidden:

Random functions          <random.md>
Numeric functions         <numeric.md>
Type conversion functions <type.md>
Miscellaneous functions   <misc.md>
```
