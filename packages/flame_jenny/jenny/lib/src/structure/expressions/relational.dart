import 'package:jenny/src/structure/expressions/expression.dart';

class LessThan extends BoolExpression {
  const LessThan(this.lhs, this.rhs);

  final NumExpression lhs;
  final NumExpression rhs;

  @override
  bool get value => lhs.value < rhs.value;
}

class LessThanOrEqual extends BoolExpression {
  const LessThanOrEqual(this.lhs, this.rhs);

  final NumExpression lhs;
  final NumExpression rhs;

  @override
  bool get value => lhs.value <= rhs.value;
}

class GreaterThan extends BoolExpression {
  const GreaterThan(this.lhs, this.rhs);

  final NumExpression lhs;
  final NumExpression rhs;

  @override
  bool get value => lhs.value > rhs.value;
}

class GreaterThanOrEqual extends BoolExpression {
  const GreaterThanOrEqual(this.lhs, this.rhs);

  final NumExpression lhs;
  final NumExpression rhs;

  @override
  bool get value => lhs.value >= rhs.value;
}
