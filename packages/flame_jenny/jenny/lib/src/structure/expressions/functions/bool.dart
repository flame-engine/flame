import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

/// Function `bool(x)` converts its argument into a boolean.
///
/// If `x` is numeric, then the value 0 becomes `false` and all other values
/// become `true`.
class BoolFn extends BoolExpression {
  const BoolFn(this._arg);

  final Expression _arg;

  /// Static constructor to be used in <parse.dart>.
  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) {
    if (args.length != 1) {
      errorFn(
        'function bool() requires a single argument',
        args.isEmpty ? null : args[1].position,
      );
    }
    return BoolFn(args[0].expression);
  }

  @override
  bool get value {
    final dynamic x = _arg.value;
    if (x is num) {
      return x != 0;
    }
    if (x is String) {
      final value = x.trim().toLowerCase();
      if (value == 'true') {
        return true;
      }
      if (value == 'false') {
        return false;
      }
      throw DialogueError(
        'String value "$x" cannot be interpreted as a boolean',
      );
    }
    return x as bool;
  }
}
