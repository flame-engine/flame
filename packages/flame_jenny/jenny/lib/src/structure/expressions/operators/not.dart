import 'package:jenny/src/structure/expressions/expression.dart';

/// Logical NOT applied to a boolean expression.
///
/// In a Yarn script this can be written as `!x` or `not x`.
class LogicalNot extends BoolExpression {
  LogicalNot(this._arg);

  final BoolExpression _arg;

  @override
  bool get value => !_arg.value;

  @override
  String get name => '!';
}
