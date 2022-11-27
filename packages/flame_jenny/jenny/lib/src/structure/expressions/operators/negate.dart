import 'package:jenny/src/structure/expressions/expression.dart';

/// Operator UNARY MINUS (-).
class Negate extends NumExpression {
  const Negate(this._arg);

  final NumExpression _arg;

  @override
  num get value => -_arg.value;
}
