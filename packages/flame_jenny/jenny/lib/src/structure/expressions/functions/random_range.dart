import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

/// Function `random_range(a, b)` returns a random integer between `a` and `b`,
/// inclusive.
class RandomRangeFn extends NumExpression {
  const RandomRangeFn(this._a, this._b, this._yarn);

  final NumExpression _a;
  final NumExpression _b;
  final YarnProject _yarn;

  /// Static constructor, used by <parse.dart>.
  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) {
    if (args.length != 2) {
      errorFn('function random_range() requires two arguments');
    }
    if (!args[0].expression.isNumeric) {
      errorFn('the first argument should be numeric', args[0].position);
    }
    if (!args[1].expression.isNumeric) {
      errorFn('the second argument should be numeric', args[1].position);
    }
    return RandomRangeFn(
      args[0].expression as NumExpression,
      args[1].expression as NumExpression,
      yarnProject,
    );
  }

  @override
  num get value {
    final lower = _a.value.toInt();
    final upper = _b.value.toInt();
    if (upper < lower) {
      throw DialogueError(
        'In random_range(a=$lower, b=$upper) the upper bound cannot be less '
        'than the lower bound',
      );
    }
    return _yarn.random.nextInt(upper - lower + 1) + lower;
  }
}
