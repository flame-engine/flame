import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

/// Function `decimal(x)` returns a fractional point of `x`.
///
/// For positive `x` the value is from 0 to 1, for negative `x` the value is
/// between 0 and -1. For any `x` it should be true that
/// `x == int(x) + decimal(x)`.
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
    return x - x.toInt();
  }
}
