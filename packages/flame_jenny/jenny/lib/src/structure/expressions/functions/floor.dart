import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

/// Function `floor(x)` will round `x` down towards negative infinity.
class FloorFn extends NumExpression {
  const FloorFn(this.arg);

  final NumExpression arg;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) =>
      num1Builder('floor', FloorFn.new, args, errorFn);

  @override
  num get value => arg.value.floor();
}
