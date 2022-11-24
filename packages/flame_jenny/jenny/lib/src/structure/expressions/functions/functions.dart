import 'dart:math';

import 'package:jenny/src/parse/parse.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/yarn_project.dart';

Random $randomGenerator = Random();

// TODO(st-pasha): visited(String nodeName)
// TODO(st-pasha): visited_count(String nodeName)

/// Function `random_range(a, b)` returns a random integer between `a` and `b`,
/// inclusive.
class RandomRangeFn extends NumExpression {
  const RandomRangeFn(this.a, this.b);

  final NumExpression a;
  final NumExpression b;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) =>
      _num2Builder('random_range', RandomRangeFn.new, args, errorFn);

  @override
  num get value {
    final lower = a.value.toInt();
    final upper = b.value.toInt();
    return $randomGenerator.nextInt(upper - lower + 1) + lower;
  }
}

/// Function `dice(n)` returns a random integer between 1 and `n`, inclusive.
class DiceFn extends NumExpression {
  const DiceFn(this.sides);

  final NumExpression sides;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) =>
      _num1Builder('dice', DiceFn.new, args, errorFn);

  @override
  num get value => $randomGenerator.nextInt(sides.value.toInt()) + 1;
}

/// Function `round(x)` will round `x` to the nearest integer.
class RoundFn extends NumExpression {
  const RoundFn(this.arg);

  final NumExpression arg;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) =>
      _num1Builder('round', RoundFn.new, args, errorFn);

  @override
  num get value => arg.value.round();
}

/// Function `round_places(x, n)` will round `x` to `n` decimal places.
class RoundPlacesFn extends NumExpression {
  const RoundPlacesFn(this.arg, this.places);

  final NumExpression arg;
  final NumExpression places;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) =>
      _num2Builder('round_places', RoundPlacesFn.new, args, errorFn);

  @override
  num get value {
    final precision = places.value.toInt();
    final factor = pow(10, precision);
    return (arg.value * factor).roundToDouble() / factor;
  }
}

/// Function `floor(x)` will round `x` down towards negative infinity.
class FloorFn extends NumExpression {
  const FloorFn(this.arg);

  final NumExpression arg;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) =>
      _num1Builder('floor', FloorFn.new, args, errorFn);

  @override
  num get value => arg.value.floor();
}

/// Function `ceil(x)` will round `x` up towards positive infinity.
class CeilFn extends NumExpression {
  const CeilFn(this.arg);

  final NumExpression arg;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) =>
      _num1Builder('ceil', CeilFn.new, args, errorFn);

  @override
  num get value => arg.value.ceil();
}

/// Function `inc(x)` increases `x` towards next integer. It is equal to `x + 1`
/// if `x` is already integer, or `ceil(x)` if `x` is not integer.
class IncFn extends NumExpression {
  const IncFn(this.arg);

  final NumExpression arg;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) =>
      _num1Builder('inc', IncFn.new, args, errorFn);

  @override
  num get value => arg.value.toInt() + 1;
}

/// Function `dec(x)` decreases `x` towards previous integer. It is equal to
/// `x - 1` if `x` is already integer, or `floor(x)` if `x` is not integer.
class DecFn extends NumExpression {
  const DecFn(this.arg);

  final NumExpression arg;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) =>
      _num1Builder('dec', DecFn.new, args, errorFn);

  @override
  num get value {
    final x = arg.value;
    final y = x.toInt();
    return x == y ? y - 1 : y;
  }
}

/// Function `decimal(x)` returns a fractional point of `x`.
class DecimalFn extends NumExpression {
  const DecimalFn(this.arg);

  final NumExpression arg;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) =>
      _num1Builder('decimal', DecimalFn.new, args, errorFn);

  @override
  num get value {
    final x = arg.value;
    return x - x.floor();
  }
}

/// Function `int(x)` truncates fractional part of `x`, rounding it towards 0.
class IntFn extends NumExpression {
  const IntFn(this.arg);

  final NumExpression arg;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) =>
      _num1Builder('int', IntFn.new, args, errorFn);

  @override
  num get value => arg.value.truncate();
}

/// Function `string(x)` converts a numeric or boolean `x` into a string.
class StringFn extends StringExpression {
  StringFn(this.arg);

  final Expression arg;

  static Expression make(
    List<FunctionArgument> arguments,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) {
    if (arguments.length != 1) {
      errorFn('function string() requires a single argument');
    }
    return StringFn(arguments[0].expression);
  }

  @override
  String get value => arg.value.toString();
}

/// Function `number(String x)`.
class StringToNumFn extends NumExpression {
  const StringToNumFn(this.arg);

  final StringExpression arg;

  @override
  num get value => double.parse(arg.value);
}

/// Function `bool(num x)`.
class NumToBoolFn extends BoolExpression {
  const NumToBoolFn(this.arg);

  final NumExpression arg;

  @override
  bool get value => arg.value != 0;
}

Expression _num1Builder(
  String name,
  Expression Function(NumExpression) constructor,
  List<FunctionArgument> args,
  ErrorFn errorFn,
) {
  if (args.length != 1) {
    errorFn('function $name() requires a single argument');
  }
  if (!args[0].expression.isNumeric) {
    errorFn('the argument should be numeric', args[0].position);
  }
  return constructor(args[0].expression as NumExpression);
}

Expression _num2Builder(
  String name,
  Expression Function(NumExpression, NumExpression) constructor,
  List<FunctionArgument> args,
  ErrorFn errorFn,
) {
  if (args.length != 2) {
    errorFn('function $name() requires 2 arguments');
  }
  if (!args[0].expression.isNumeric) {
    errorFn('first argument should be numeric', args[0].position);
  }
  if (!args[1].expression.isNumeric) {
    errorFn('second argument should be numeric', args[1].position);
  }
  return constructor(
    args[0].expression as NumExpression,
    args[1].expression as NumExpression,
  );
}
