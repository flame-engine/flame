import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

/// Function `ceil(x)` will round `x` up towards positive infinity.
class CeilFn extends NumExpression {
  const CeilFn(this.arg);

  final NumExpression arg;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) =>
      num1Builder('ceil', CeilFn.new, args, errorFn);

  @override
  num get value => arg.value.ceil();
}
