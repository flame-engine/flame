import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

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
      num1Builder('inc', IncFn.new, args, errorFn);

  @override
  num get value {
    final x = arg.value;
    final y = x.ceil();
    return x == y ? y + 1 : y;
  }
}
