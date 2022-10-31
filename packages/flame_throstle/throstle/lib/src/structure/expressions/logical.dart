import 'package:throstle/src/structure/expressions/expression.dart';

class LogicalNot extends BoolExpression {
  const LogicalNot(this.arg);

  final BoolExpression arg;

  @override
  bool get value => !arg.value;
}

class LogicalAnd extends BoolExpression {
  const LogicalAnd(this.lhs, this.rhs);

  final BoolExpression lhs;
  final BoolExpression rhs;

  @override
  bool get value => lhs.value && rhs.value;
}

class LogicalOr extends BoolExpression {
  const LogicalOr(this.lhs, this.rhs);

  final BoolExpression lhs;
  final BoolExpression rhs;

  @override
  bool get value => lhs.value || rhs.value;
}

class LogicalXor extends BoolExpression {
  const LogicalXor(this.lhs, this.rhs);

  final BoolExpression lhs;
  final BoolExpression rhs;

  @override
  bool get value => lhs.value ^ rhs.value;
}
