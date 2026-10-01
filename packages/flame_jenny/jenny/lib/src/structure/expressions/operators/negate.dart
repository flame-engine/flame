import 'package:jenny/src/structure/expressions/expression.dart';

/// Operator UNARY MINUS (-).
class const Negate(final NumExpression _arg) extends NumExpression {
  @override
  num get value => -_arg.value;
}
