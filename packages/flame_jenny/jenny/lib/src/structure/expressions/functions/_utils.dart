import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:meta/meta.dart';

typedef ErrorFn = Never Function(String message, [int? position]);

class FunctionArgument {
  FunctionArgument(this.expression, this.position);
  final Expression expression;
  final int position;
}

@internal
Expression num1Builder(
  String name,
  Expression Function(NumExpression) constructor,
  List<FunctionArgument> args,
  ErrorFn errorFn,
) {
  if (args.length != 1) {
    errorFn(
      'function $name() requires a single argument',
      args.isEmpty ? null : args[1].position,
    );
  }
  if (!args[0].expression.isNumeric) {
    errorFn('the argument in $name() should be numeric', args[0].position);
  }
  return constructor(args[0].expression as NumExpression);
}
