import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

/// Function `dice(n)` returns a random integer between 1 and `n`, inclusive.
class DiceFn extends NumExpression {
  const DiceFn(this._n, this._yarn);

  final NumExpression _n;
  final YarnProject _yarn;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) {
    if (args.length != 1) {
      errorFn(
        'function dice() requires a single argument',
        args.isEmpty ? null : args[1].position,
      );
    }
    if (!args[0].expression.isNumeric) {
      errorFn('the argument should be numeric', args[0].position);
    }
    return DiceFn(args[0].expression as NumExpression, yarnProject);
  }

  @override
  num get value {
    final n = _n.value.toInt();
    if (n <= 0) {
      throw DialogueError('Argument to dice() must be positive: $n');
    }
    return _yarn.random.nextInt(n) + 1;
  }
}
