
import 'package:flame_yarn/src/structure/expressions/expression.dart';

typedef NumericEqual = _Equal<num>;
typedef StringEqual = _Equal<String>;
typedef BoolEqual = _Equal<bool>;
typedef NumericNotEqual = _NotEqual<num>;
typedef StringNotEqual = _NotEqual<String>;
typedef BoolNotEqual = _NotEqual<bool>;

class _Equal<T> extends TypedExpression<bool> {
  const _Equal(this.lhs, this.rhs);

  final TypedExpression<T> lhs;
  final TypedExpression<T> rhs;

  @override
  bool get value => lhs.value == rhs.value;
}

class _NotEqual<T> extends TypedExpression<bool> {
  const _NotEqual(this.lhs, this.rhs);

  final TypedExpression<T> lhs;
  final TypedExpression<T> rhs;

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

class StringsNotEqual extends TypedExpression<bool> {
  const StringsNotEqual(this.lhs, this.rhs);

  final TypedExpression<String> lhs;
  final TypedExpression<String> rhs;

  @override
  bool get value => lhs.value != rhs.value;
}
