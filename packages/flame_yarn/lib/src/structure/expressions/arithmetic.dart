
import 'package:flame_yarn/src/structure/expressions/expression.dart';

class Add extends Expression<num> {
  const Add(this.lhs, this.rhs);

  final Expression<num> lhs;
  final Expression<num> rhs;

  @override
  num get value => lhs.value + rhs.value;
}

class Subtract extends Expression<num> {
  const Subtract(this.lhs, this.rhs);

  final Expression<num> lhs;
  final Expression<num> rhs;

  @override
  num get value => lhs.value - rhs.value;
}

class Multiply extends Expression<num> {
  const Multiply(this.lhs, this.rhs);

  final Expression<num> lhs;
  final Expression<num> rhs;

  @override
  num get value => lhs.value * rhs.value;
}

class Divide extends Expression<num> {
  const Divide(this.lhs, this.rhs);

  final Expression<num> lhs;
  final Expression<num> rhs;

  @override
  num get value => lhs.value / rhs.value;
}

class Modulo extends Expression<num> {
  const Modulo(this.lhs, this.rhs);

  final Expression<num> lhs;
  final Expression<num> rhs;

  @override
  num get value => lhs.value % rhs.value;
}
