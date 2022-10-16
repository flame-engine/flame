
import 'package:flame_yarn/src/structure/expressions/expression.dart';

class Add extends TypedExpression<num> {
  const Add(this.lhs, this.rhs);

  final TypedExpression<num> lhs;
  final TypedExpression<num> rhs;

  @override
  num get value => lhs.value + rhs.value;
}

class Subtract extends TypedExpression<num> {
  const Subtract(this.lhs, this.rhs);

  final TypedExpression<num> lhs;
  final TypedExpression<num> rhs;

  @override
  num get value => lhs.value - rhs.value;
}

class Multiply extends TypedExpression<num> {
  const Multiply(this.lhs, this.rhs);

  final TypedExpression<num> lhs;
  final TypedExpression<num> rhs;

  @override
  num get value => lhs.value * rhs.value;
}

class Divide extends TypedExpression<num> {
  const Divide(this.lhs, this.rhs);

  final TypedExpression<num> lhs;
  final TypedExpression<num> rhs;

  @override
  num get value => lhs.value / rhs.value;
}

class Modulo extends TypedExpression<num> {
  const Modulo(this.lhs, this.rhs);

  final TypedExpression<num> lhs;
  final TypedExpression<num> rhs;

  @override
  num get value => lhs.value % rhs.value;
}

class Negate extends TypedExpression<num> {
  const Negate(this.arg);

  final TypedExpression<num> arg;

  @override
  num get value => -arg.value;
}
