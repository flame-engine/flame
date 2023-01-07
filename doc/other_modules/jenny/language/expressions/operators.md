# Operators

The **operators** are special symbols that perform common mathematical operations. For example,
operator `+` performs summation, and thus we can write `$x + $y` to denote the sum of variables
`$x` and `$y`. There are over 20 different operators in YarnSpinner, which can be loosely grouped
into the following categories:


## Operator types


### Arithmetic

The **arithmetic** operators, have the same meaning as in regular math. These apply to numeric
arguments (with the exception of `+` which can also be used with strings):

```{list-table}
:align: left
:class: first-col-align-center
:header-rows: 1
:widths: 1 2 9

* - operator
  - name
  - notes
* - `+`
  - addition
  -
* - `-`
  - subtraction
  - Also, a unary minus
* - `*`
  - multiplication
  -
* - `/`
  - division
  - Division by `0` is not allowed, and will throw a runtime error if it occurs.
* - `%`
  - modulo
  - This operator can apply to both integer and decimal numbers, and it returns
    the remainder of integer division of two numbers. The right-hand side of
    `%` cannot be zero or a negative number, otherwise a runtime error will be
    thrown. The result of `x % y` is always a number in the range `[0; y)`,
    regardless of the sign of `x`.
* - `+`
  - concatenation
  - When applied to strings, the `+` operator simply glues them together. For
    example, `"Hello" + "World"` produces string `"HelloWorld"`.
```


### Logical

The **logical** operators apply to boolean values. These operators can be written either in
symbolic or word form -- both forms are equivalent:

```{list-table}
:align: left
:class: first-col-align-center
:header-rows: 1
:widths: 1 2 9

* - operator
  - name
  - notes
* - `!`, `not`
  - logical NOT
  - This is a unary operator that inverts its operand: `!true` is `false`,
    and `!false` is `true`.
* - `&&`, `and`
  - logical AND
  - Returns `true` if both of its arguments are `true`.
* - `||`, `or`
  - logical OR
  - Returns `true` if at least one of its arguments is `true`.
* - `^`, `xor`
  - logical XOR
  - Returns `true` if the arguments are different, and `false` if they are
    the same.
```


### Assignment

The **assignment** operators modify the value of a variable. The left-hand side of such an operator
is the variable that shall be modified, the right-hand side is the expression of the same type as
the variable on the left:

```{list-table}
:align: left
:class: first-col-align-center
:header-rows: 1
:widths: 1 2 9

* - operator
  - name
  - notes
* - `=`, `to`
  - assign
  - `$var = X` stores the value of `X` into the variable `$var`
* - `+=`
  - increase
  - `$var += X` is equivalent to `$var = $var + X`
* - `-=`
  - decrease
  - `$var -= X` is equivalent to `$var = $var - X`
* - `*=`
  - multiply
  - `$var *= X` is equivalent to `$var = $var * X`
* - `/=`
  - divide
  - `$var /= X` is equivalent to `$var = $var / X`
* - `%=`
  - reduce modulo
  - `$var %= X` is equivalent to `$var = $var % X`
```

Unlike all other operators, the assignment operators do not produce a value. This means they
cannot be used inside a larger expression, for example the following is invalid: `3 + ($x += 7)`.
Instead, the assignment operators are only usable at the top level of commands such as
[\<\<set\>\>], [\<\<declare\>\>], and [\<\<local\>\>].


### Relational

The **relational** operators compare various values. The first two operators in this list can be
applied to operands of any types, as long as the types are the same. The remaining four operators
can only be used with numbers. Regardless of the types of operands, the result of every
relational operator is a boolean value, which can be either assigned to a variable, or used in a
larger expression:

```{list-table}
:align: left
:class: first-col-align-center
:header-rows: 1
:widths: 1 3 8

* - operator
  - name
  - notes
* - `==`
  - equality
  -
* - `!=`
  - inequality
  -
* - `<`
  - less than
  -
* - `<=`
  - less than or equal
  -
* - `>`
  - greater than
  -
* - `>=`
  - greater than or equal
  -
```

Note that operator chaining is not supported. Thus, for example, `$x == $y == $z` will first
compare variables `$x` and `$y`, then the result of that comparison, which is either `true` or
`false`, will be compared with variable `$z`. Given that such expressions would be highly
confusing to a reader, we recommend against using them. If you need to compare that all three
values `$x`, `$y` and `$z` are the same, then you should use the `&&` operator instead:
`$x == $y && $x == $z`.


## Precedence

Just as in mathematics, the operators have precedence ordering among them, meaning that some
operators will always evaluate before the others. For example, if you write `3 + 4 * 5`, then
the result will be `23` instead of `35` because multiplication has higher precedence than addition
and thus evaluates first.

The precedence order is as follows, from highest to lowest:

- `*`, `/`, `%`;
- `-`, `+`;
- `==`, `!=`, `<`, `<=`, `>=`, `>`;
- `!`;
- `&&`, `^`;
- `||`;
- `=`, `+=`, `-=`, `*=`, `/=`, `%=`.

You can use parentheses `()` in order to alter the order of evaluation. For example, `(3 + 4) * 5`
is `35` instead of `23`.


[\<\<declare\>\>]: ../commands/declare.md
[\<\<local\>\>]: ../commands/local.md
[\<\<set\>\>]: ../commands/set.md
