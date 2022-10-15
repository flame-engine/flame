
import 'package:flame_yarn/src/structure/expressions/expression.dart';

class Equal extends TypedExpression<bool> {
  const Equal(this.lhs, this.rhs);

  final TypedExpression<num> lhs;
  final TypedExpression<num> rhs;

  @override
  bool get value => lhs.value == rhs.value;
}

class NotEqual extends TypedExpression<bool> {
  const NotEqual(this.lhs, this.rhs);

  final TypedExpression<num> lhs;
  final TypedExpression<num> rhs;

  @override
  bool get value => lhs.value != rhs.value;
}

class LessThan extends TypedExpression<bool> {
  const LessThan(this.lhs, this.rhs);

  final TypedExpression<num> lhs;
  final TypedExpression<num> rhs;

  @override
  bool get value => lhs.value < rhs.value;
}

class LessThanOrEqual extends TypedExpression<bool> {
  const LessThanOrEqual(this.lhs, this.rhs);

  final TypedExpression<num> lhs;
  final TypedExpression<num> rhs;

  @override
  bool get value => lhs.value <= rhs.value;
}

class GreaterThan extends TypedExpression<bool> {
  const GreaterThan(this.lhs, this.rhs);

  final TypedExpression<num> lhs;
  final TypedExpression<num> rhs;

  @override
  bool get value => lhs.value > rhs.value;
}

class GreaterThanOrEqual extends TypedExpression<bool> {
  const GreaterThanOrEqual(this.lhs, this.rhs);

  final TypedExpression<num> lhs;
  final TypedExpression<num> rhs;

  @override
  bool get value => lhs.value >= rhs.value;
}

class StringsEqual extends TypedExpression<bool> {
  const StringsEqual(this.lhs, this.rhs);

  final TypedExpression<String> lhs;
  final TypedExpression<String> rhs;

  @override
  bool get value => lhs.value == rhs.value;
}

class StringsNotEqual extends TypedExpression<bool> {
  const StringsNotEqual(this.lhs, this.rhs);

  final TypedExpression<String> lhs;
  final TypedExpression<String> rhs;

  @override
  bool get value => lhs.value != rhs.value;
}
