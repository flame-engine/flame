import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

/// Function `string(x)` converts a numeric or boolean `x` into a string.
class StringFn extends StringExpression {
  StringFn(this._arg);

  final Expression _arg;

  /// Static constructor to be used in <parse.dart>.
  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) {
    if (args.length != 1) {
      errorFn(
        'function string() requires a single argument',
        args.isEmpty ? null : args[1].position,
      );
    }
    return StringFn(args[0].expression);
  }

  @override
  String get value => _arg.value.toString();
}
