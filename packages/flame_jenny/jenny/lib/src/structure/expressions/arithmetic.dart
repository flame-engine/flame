import 'package:jenny/src/structure/expressions/expression.dart';

class Multiply extends NumExpression {
  const Multiply(this.lhs, this.rhs);

  final NumExpression lhs;
  final NumExpression rhs;

  @override
  num get value => lhs.value * rhs.value;
}

class Divide extends NumExpression {
  const Divide(this.lhs, this.rhs);

  final NumExpression lhs;
  final NumExpression rhs;

  @override
  num get value => lhs.value / rhs.value;
}

class Modulo extends NumExpression {
  const Modulo(this.lhs, this.rhs);

  final NumExpression lhs;
  final NumExpression rhs;

  @override
  num get value => lhs.value % rhs.value;
}

class Negate extends NumExpression {
  const Negate(this.arg);

  final NumExpression arg;

  @override
  num get value => -arg.value;
}
