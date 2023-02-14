import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

/// Function `random()` returns a random double between 0 and 1.
class RandomFn extends NumExpression {
  RandomFn(this._yarn);

  final YarnProject _yarn;

  static Expression make(
    List<FunctionArgument> arguments,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) {
    if (arguments.isNotEmpty) {
      errorFn('function random() requires no arguments', arguments[0].position);
    }
    return RandomFn(yarnProject);
  }

  @override
  num get value => _yarn.random.nextDouble();
}
