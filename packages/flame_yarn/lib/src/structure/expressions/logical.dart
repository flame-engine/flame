
import 'package:flame_yarn/src/structure/expressions/expression.dart';

class NotExpression extends TypedExpression<bool> {
  const NotExpression(this.arg);

  final TypedExpression<bool> arg;

  @override
  bool get value => !arg.value;
}

class AndExpression extends TypedExpression<bool> {
  const AndExpression(this.lhs, this.rhs);

  final TypedExpression<bool> lhs;
  final TypedExpression<bool> rhs;

  @override
  bool get value => lhs.value && rhs.value;
}

class OrExpression extends TypedExpression<bool> {
  const OrExpression(this.lhs, this.rhs);

  final TypedExpression<bool> lhs;
  final TypedExpression<bool> rhs;

  @override
  bool get value => lhs.value || rhs.value;
}

class XorExpression extends TypedExpression<bool> {
  const XorExpression(this.lhs, this.rhs);

  final TypedExpression<bool> lhs;
  final TypedExpression<bool> rhs;

  @override
  bool get value => lhs.value ^ rhs.value;
}
