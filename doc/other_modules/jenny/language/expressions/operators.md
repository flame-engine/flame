# Operators

Variables can be combined into more complicated formulas with the help of various operators. These
can be loosely grouped into the following categories:


## Operator types

### Arithmetic

The **arithmetic** operators, same as in traditional math. These apply to numeric values, except
for `+` which can also be used with strings:

- `+` (addition);
- `-` (subtraction, or unary minus);
- `*` (multiplication);
- `/` (division) -- division by `0` is not allowed, and will throw a runtime error if it occurs;
- `%` (modulo) -- this operator can apply to either integer or decimal numbers. The right-hand
  side of `%` must be a positive number, otherwise a runtime error will be thrown. The result of
  `x % y` is always a number in the range `[0; y)`, regardless of the sign of `x`.


### Assignment

The **assignment** operators, which modify the value of a variable:

- `=` (assign);
- `+=` (increase);
- `-=` (decrease);
- `*=` (multiply);
- `/=` (divide);
- `%=` (reduce modulo).


### Logical

The **logical** operators, which apply to boolean values:

- `!`, `not` (logical NOT);
- `&&`, `and` (logical AND);
- `||`, `or` (logical OR);
- `^`, `xor` (logical XOR).


### Relational

The **relational**, i.e. operators that compare various values. The first two operators in this
list can be applied to operands of any types, as long as the types are the same. The remaining
four operators can only be used with numbers:

- `==` (equality);
- `!=` (inequality);
- `<` (less than);
- `<=` (less than or equal);
- `>` (greater than);
- `>=` (greater than or equal).


## Precedence

Just as in mathematics, the operators have precedence ordering among them. This order is as
follows, from highest precedence to lowest:

- `*`, `/`, `%`;
- `-`, `+`;
- `==`, `!=`, `<`, `<=`, `>=`, `>`;
- `!`;
- `&&`, `^`;
- `||`;
- `=`, `+=`, `-=`, `*=`, `/=`, `%=`.
