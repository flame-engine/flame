# Functions

An expression may also contain function calls, which are indicated by the name of the function,
followed by its arguments in parentheses. The parentheses are required, even when there are no
arguments:

```yarn
<<set $roll_2d6 = dice(6) + dice(6)>>
<<set $random = random()>>
```

- **Random**
  - [`dice(n)`](random.md#dicen)
  - [`random()`](random.md#random)
  - [`random_range(a, b)`](random.md#random_rangea-b)

- **Numeric**
  - [`ceil(x)`](numeric.md#ceilx)
  - [`dec(x)`](numeric.md#decx)
  - [`decimal(x)`](numeric.md#decimalx)
  - [`floor(x)`](numeric.md#floorx)
  - [`inc(x)`](numeric.md#incx)
  - [`int(x)`](numeric.md#intx)
  - [`round(x)`](numeric.md#roundx)
  - [`round_places(x, n)`](numeric.md#round_placesx-n)

- **Type conversion**
  - [`bool(x)`](type.md#boolx)
  - [`number(x)`](type.md#numberx)
  - [`string(x)`](type.md#stringx)

- **Other**
  - [`plural(x, ...)`](misc.md#pluralx-words)
  - [`visit_count(node)`](misc.md#visit_countnode)
  - [`visited(node)`](misc.md#visitednode)


```{toctree}
:hidden:

Random functions          <random.md>
Numeric functions         <numeric.md>
Type conversion functions <type.md>
Miscellaneous functions   <misc.md>
```
