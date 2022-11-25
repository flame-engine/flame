import 'dart:math';

import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_utils.dart';
import 'package:jenny/src/yarn_project.dart';

// TODO(st-pasha): visited(String nodeName)
// TODO(st-pasha): visited_count(String nodeName)

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
