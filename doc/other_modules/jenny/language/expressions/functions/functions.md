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
[user-defined functions] as well.


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


```{toctree}
:hidden:

Random functions          <random.md>
Numeric functions         <numeric.md>
Type conversion functions <type.md>
Miscellaneous functions   <misc.md>
User-defined functions    <user_defined_functions.md>
```

[user-defined functions]: user_defined_functions.md
