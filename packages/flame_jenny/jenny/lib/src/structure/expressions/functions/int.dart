import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

/// Function `int(x)` truncates fractional part of `x`, rounding it towards 0.
class const IntFn(final NumExpression arg) extends NumExpression {
  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) => num1Builder('int', IntFn.new, args, errorFn);

  @override
  num get value => arg.value.truncate();
}
