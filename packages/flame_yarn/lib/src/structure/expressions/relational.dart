
import 'package:flame_yarn/src/structure/expressions/expression.dart';

class Equal extends Expression<bool> {
  const Equal(this.lhs, this.rhs);

  final Expression<num> lhs;
  final Expression<num> rhs;

  @override
  bool get value => lhs.value == rhs.value;
}

class NotEqual extends Expression<bool> {
  const NotEqual(this.lhs, this.rhs);

  final Expression<num> lhs;
  final Expression<num> rhs;

  @override
  bool get value => lhs.value != rhs.value;
}

class LessThan extends Expression<bool> {
  const LessThan(this.lhs, this.rhs);

  final Expression<num> lhs;
  final Expression<num> rhs;

  @override
  bool get value => lhs.value < rhs.value;
}

class LessThanOrEqual extends Expression<bool> {
  const LessThanOrEqual(this.lhs, this.rhs);

  final Expression<num> lhs;
  final Expression<num> rhs;

  @override
  bool get value => lhs.value <= rhs.value;
}

class GreaterThan extends Expression<bool> {
  const GreaterThan(this.lhs, this.rhs);

  final Expression<num> lhs;
  final Expression<num> rhs;

  @override
  bool get value => lhs.value > rhs.value;
}

class GreaterThanOrEqual extends Expression<bool> {
  const GreaterThanOrEqual(this.lhs, this.rhs);

  final Expression<num> lhs;
  final Expression<num> rhs;

  @override
  bool get value => lhs.value >= rhs.value;
}

class StringsEqual extends Expression<bool> {
  const StringsEqual(this.lhs, this.rhs);

  final Expression<String> lhs;
  final Expression<String> rhs;

  @override
  bool get value => lhs.value == rhs.value;
}

class StringsNotEqual extends Expression<bool> {
  const StringsNotEqual(this.lhs, this.rhs);

  final Expression<String> lhs;
  final Expression<String> rhs;

  @override
  bool get value => lhs.value != rhs.value;
}
