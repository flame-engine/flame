# Numeric functions

These functions are used to manipulate numeric values. Most of them take a single numeric argument
and produce a numeric result.


## `ceil(x)`

Returns the value `x` rounded up towards positive infinity. In other words, this returns the
smallest integer value greater than or equal to `x`.

```yarn
title: ceil
---
{ ceil(0)     }  // 0
{ ceil(0.3)   }  // 1
{ ceil(5)     }  // 5
{ ceil(5.001) }  // 6
{ ceil(5.999) }  // 6
{ ceil(-2.07) }  // -2
===
```

```{seealso}
- [`floor(x)`](#floorx)
- [`int(x)`](#intx)
```


## `dec(x)`

Returns the value `x` reduced towards the previous integer. Thus, if `x` is already an integer
this returns `x - 1`, but if `x` is not an integer then this returns `floor(x)`.

```yarn
title: dec
---
{ dec(0)     }  // -1
{ dec(0.3)   }  // 0
{ dec(5.0)   }  // 4
{ dec(5.001) }  // 5
{ dec(5.999) }  // 5
{ dec(-2.07) }  // -3
===
```

```{seealso}
- [`inc(x)`](#incx)
```


## `decimal(x)`

Returns a fractional part of `x`.

If `x` is positive, then the returned value will be between `0` (inclusive) and `1` (exclusive).
If `x` is negative, then the returned value will be between `0` and `-1`. In all cases it should
hold that `x == int(x) + decimal(x)`.

```yarn
title: decimal
---
{ decimal(0)     }  // 0
{ decimal(0.3)   }  // 0.3
{ decimal(5.0)   }  // 0
{ decimal(5.001) }  // 0.001
{ decimal(5.999) }  // 0.999
{ decimal(-2.07) }  // -0.07
===
```

```{seealso}
- [`int(x)`](#intx)
```


## `floor(x)`

Returns the value `x` rounded down towards negative infinity. In other words, this returns the
largest integer value less than or equal to `x`.

```yarn
title: floor
---
{ floor(0)     }  // 0
{ floor(0.3)   }  // 0
{ floor(5)     }  // 5
{ floor(5.001) }  // 5
{ floor(5.999) }  // 5
{ floor(-2.07) }  // -3
===
```

```{seealso}
- [`ceil(x)`](#ceilx)
- [`int(x)`](#intx)
```


## `inc(x)`

Returns the value `x` increased towards the next integer. Thus, if `x` is already an integer
this returns `x + 1`, but if `x` is not an integer then this returns `ceil(x)`.

```yarn
title: inc
---
{ inc(0)     }  // 1
{ inc(0.3)   }  // 1
{ inc(5.0)   }  // 6
{ inc(5.001) }  // 6
{ inc(5.999) }  // 6
{ inc(-2.07) }  // -2
===
```

```{seealso}
- [`dec(x)`](#decx)
```


## `int(x)`

Truncates the fractional part of `x`, rounding it towards zero, and returns just the integer part
of the argument `x`.

```yarn
title: int
---
{ int(0)     }  // 0
{ int(0.3)   }  // 0
{ int(5.0)   }  // 5
{ int(5.001) }  // 5
{ int(5.999) }  // 5
{ int(-2.07) }  // -2
===
```

```{seealso}
- [`decimal(x)`](#decimalx)
- [`round(x)`](#roundx)
```


## `round(x)`

Rounds the value `x` towards a nearest integer.

The values that end with `.5` are rounded up if `x` is positive, and down if `x` is negative.

```yarn
title: round
---
{ round(0)     }  // 0
{ round(0.3)   }  // 0
{ round(5.0)   }  // 5
{ round(5.001) }  // 5
{ round(5.5)   }  // 6
{ round(5.999) }  // 6
{ round(-2.07) }  // -2
{ round(-2.5) }   // -3
===
```

```{seealso}
- [`round_places(x, n)`](#round_placesx-n)
```


## `round_places(x, n)`

Rounds the value `x` to `n` decimal places.

The value `x` can be either positive, negative, or zero, but it must be an integer. Rounding to
`0` decimal places is equivalent to the regular `round(x)` function. If `n` is positive, then the
function will attempt to keep that many digits after the decimal point in `x`. If `n` is negative,
then `round_places()` will round `x` to nearest tens, hundreds, thousands, etc:

```yarn
title: round_places
---
{ round_places(0, 1)     }  // 0
{ round_places(0.3, 1)   }  // 0.3
{ round_places(5.001, 1) }  // 5.0
{ round_places(5.001, 2) }  // 5.0
{ round_places(5.001, 3) }  // 5.001
{ round_places(5.5, 1)   }  // 5.5
{ round_places(5.999, 1) }  // 6.0
{ round_places(-2.07, 1) }  // -2.1
{ round_places(13, -1)   }  // 10
{ round_places(252, -2)  }  // 200
===
```

```{seealso}
- [`round(x)`](#roundx)
```
