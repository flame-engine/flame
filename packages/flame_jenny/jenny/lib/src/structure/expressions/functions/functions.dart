import 'dart:math';

import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_utils.dart';
import 'package:jenny/src/yarn_project.dart';

Random $randomGenerator = Random();

// TODO(st-pasha): visited(String nodeName)
// TODO(st-pasha): visited_count(String nodeName)

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
      num2Builder('round_places', RoundPlacesFn.new, args, errorFn);

  @override
  num get value {
    final precision = places.value.toInt();
    final factor = pow(10, precision);
    return (arg.value * factor).roundToDouble() / factor;
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
      num1Builder('decimal', DecimalFn.new, args, errorFn);

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
      num1Builder('int', IntFn.new, args, errorFn);

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
