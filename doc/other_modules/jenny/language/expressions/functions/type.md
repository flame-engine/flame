# Type conversion functions

These functions convert values of one type into another type, if possible. All of these functions
take a single argument of arbitrary type, and return the result of the type corresponding to the
name of the function.


## `bool(x)`

Converts its argument into a boolean value.

- If `x` is already a boolean, then it returns the argument as-is.
- If `x` is numeric, then the result is `false` when `x` is `0`, and `true` for all other values
  of `x`.
- If `x` is string, then the function will check whether that string can be found within
  `YarnProject.trueValues` or `YarnProject.falseValues` sets. If yes, then it will return the
  `true` / `false` value respectively. Otherwise, an error will be thrown.


## `number(x)`

Converts its argument `x` into a numeric value.

- If `x` is boolean, then it returns `1` for `true` and `0` for `false`.
- If `x` is numeric, then it is returned unmodified.
- If `x` is string, then the function attempts to parse that string as a number. A runtime
  exception will be raised if `x` does not have a valid format for a number. The following formats
  are recognized:
  - integer: `"-3"`, `"214"`
  - decimal: `"0.745"`, `"3.14159"`, `".1"`, `"-3."`
  - scientific: `"2e5"`, `"3.11e-05"`
  - hexadecimal: `"0xDEAD"`, `"0x7F"`


## `string(x)`

Converts its argument `x` into a string value.

- If `x` is boolean, returns strings `"true"` or `"false"`.
- If `x` is numeric, converts it into a string representation using the standard Dart's
  `.toString()` method, which attempts to produce the shortest string that can represent
  the number `x`. In particular,
  - if `x` is integer-valued, returns its decimal representation without a decimal point;
  - if `x` is a double in the range `1e-6` to `1e21`, returns its decimal representation
    with a decimal point;
  - for all other doubles, returns `x` written in the scientific (exponential) format.
- If `x` is a string, then it is returned as-is.
