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

@internal
Expression num2Builder(
  String name,
  Expression Function(NumExpression, NumExpression) constructor,
  List<FunctionArgument> args,
  ErrorFn errorFn,
) {
  if (args.length != 2) {
    errorFn('function $name() requires 2 arguments');
  }
  if (!args[0].expression.isNumeric) {
    errorFn('first argument should be numeric', args[0].position);
  }
  if (!args[1].expression.isNumeric) {
    errorFn('second argument should be numeric', args[1].position);
  }
  return constructor(
    args[0].expression as NumExpression,
    args[1].expression as NumExpression,
  );
}
