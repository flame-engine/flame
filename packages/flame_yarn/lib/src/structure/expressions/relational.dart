import 'package:flame_yarn/src/structure/expressions/expression.dart';

class NumericEqual extends BoolExpression {
  const NumericEqual(this.lhs, this.rhs);

  final NumExpression lhs;
  final NumExpression rhs;

  @override
  bool get value => lhs.value == rhs.value;
}

class StringEqual extends BoolExpression {
  const StringEqual(this.lhs, this.rhs);

  final StringExpression lhs;
  final StringExpression rhs;

  @override
  bool get value => lhs.value == rhs.value;
}

class BoolEqual extends BoolExpression {
  const BoolEqual(this.lhs, this.rhs);

  final BoolExpression lhs;
  final BoolExpression rhs;

  @override
  bool get value => lhs.value == rhs.value;
}

class NumericNotEqual extends BoolExpression {
  const NumericNotEqual(this.lhs, this.rhs);

  final NumExpression lhs;
  final NumExpression rhs;

  @override
  bool get value => lhs.value != rhs.value;
}

class StringNotEqual extends BoolExpression {
  const StringNotEqual(this.lhs, this.rhs);

  final StringExpression lhs;
  final StringExpression rhs;

  @override
  bool get value => lhs.value != rhs.value;
}

class BoolNotEqual extends BoolExpression {
  const BoolNotEqual(this.lhs, this.rhs);

  final BoolExpression lhs;
  final BoolExpression rhs;

  @override
  bool get value => lhs.value != rhs.value;
}

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

class StringsNotEqual extends BoolExpression {
  const StringsNotEqual(this.lhs, this.rhs);

  final StringExpression lhs;
  final StringExpression rhs;

  @override
  bool get value => lhs.value != rhs.value;
}
