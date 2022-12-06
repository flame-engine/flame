import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

/// Function `number(x)` converts any `x` into a number, if possible.
///
/// If `x` is boolean, then it will be converted into numbers 0 or 1. If `x` is
/// a string, then
class NumberFn extends NumExpression {
  const NumberFn(this._arg);

  final Expression _arg;

  /// Static constructor to be used in <parse.dart>.
  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) {
    if (args.length != 1) {
      errorFn(
        'function number() requires a single argument',
        args.isEmpty ? null : args[1].position,
      );
    }
    return NumberFn(args[0].expression);
  }

  @override
  num get value {
    final dynamic value = _arg.value;
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is String) {
      final result = num.tryParse(value);
      if (result == null) {
        throw DialogueError('Unable to convert string "$value" into a number');
      }
      return result;
    }
    return value as num;
  }
}
