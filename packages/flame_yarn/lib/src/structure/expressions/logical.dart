
import 'package:flame_yarn/src/structure/expressions/expression.dart';

class NotExpression extends Expression<bool> {
  const NotExpression(this.arg);

  final Expression<bool> arg;

  @override
  bool get value => !arg.value;
}

class AndExpression extends Expression<bool> {
  const AndExpression(this.lhs, this.rhs);

  final Expression<bool> lhs;
  final Expression<bool> rhs;

  @override
  bool get value => lhs.value && rhs.value;
}

class OrExpression extends Expression<bool> {
  const OrExpression(this.lhs, this.rhs);

  final Expression<bool> lhs;
  final Expression<bool> rhs;

  @override
  bool get value => lhs.value || rhs.value;
}

class XorExpression extends Expression<bool> {
  const XorExpression(this.lhs, this.rhs);

  final Expression<bool> lhs;
  final Expression<bool> rhs;

  @override
  bool get value => lhs.value ^ rhs.value;
}
