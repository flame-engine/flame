import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

/// Function `round(x)` will round `x` to the nearest integer.
class RoundFn extends NumExpression {
  const RoundFn(this.arg);

  final NumExpression arg;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) =>
      num1Builder('round', RoundFn.new, args, errorFn);

  @override
  num get value => arg.value.round();
}
