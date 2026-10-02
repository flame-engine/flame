import 'package:jenny/src/structure/expressions/expression.dart';

/// Logical NOT applied to a boolean expression.
///
/// In a Yarn script this can be written as `!x` or `not x`.
class Not(final BoolExpression _arg) extends BoolExpression {
  @override
  bool get value => !_arg.value;
}
