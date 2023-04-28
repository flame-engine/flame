# Random functions

These functions produce random results each time they run.

Internally, each function uses `YarnSpinner.random` random generator, which can be replaced with a
custom generator if you need reproducible draws for debug purposes, or to prevent the player from
getting different results upon reload.


## `dice(n)`

Returns a random integer between `1` and `n`, inclusive. For example, `dice(6)` will return a
random integer from 1 to 6, as if throwing a regular six-sided die.

The argument `n` must be numeric, and greater or equal than 1. If `n` is a non-integer, then it
will be truncated to an integer value at runtime. Thus, `dice(3.5)` is equivalent to `dice(3)`.

```yarn
<<set $roll = dice(6)>>
<<set $coin_flip = if(dice(2) == 1, "H", "T")>>
```


## `random()`

Returns a random floating-point between `0` and `1`.

This function can be used to implement events with a prescribed probability. For example:

```yarn
<<if random() < 0.001>>
  // This happens only with 0.1% probability
  You found it! The Holy Grail!
<<endif>>
```


## `random_range(a, b)`

Returns a random integer between `a` and `b` inclusive.

Both arguments `a` and `b` must be numeric, and they will be truncated to integers upon evaluation.
The value of `a` must be less than or equal to `b`, or otherwise a runtime exception will be thrown.

The purpose of this function is similar to `dice()`, but it can be used in situations where a
custom range is desired.

```yarn
<<set $coin_flip = bool(random_range(0, 1))>>
```
