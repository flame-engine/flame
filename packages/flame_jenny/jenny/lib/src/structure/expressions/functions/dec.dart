import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

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
      num1Builder('dec', DecFn.new, args, errorFn);

  @override
  num get value {
    final x = arg.value;
    final y = x.floor();
    return x == y ? y - 1 : y;
  }
}
