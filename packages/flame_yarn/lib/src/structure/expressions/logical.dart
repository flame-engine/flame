
import 'package:flame_yarn/src/structure/expressions/expression.dart';

class NotExpression extends BoolExpression {
  const NotExpression(this.arg);

  final BoolExpression arg;

  @override
  bool get value => !arg.value;
}

class AndExpression extends BoolExpression {
  const AndExpression(this.lhs, this.rhs);

  final BoolExpression lhs;
  final BoolExpression rhs;

  @override
  bool get value => lhs.value && rhs.value;
}

class OrExpression extends BoolExpression {
  const OrExpression(this.lhs, this.rhs);

  final BoolExpression lhs;
  final BoolExpression rhs;

  @override
  bool get value => lhs.value || rhs.value;
}

class XorExpression extends BoolExpression {
  const XorExpression(this.lhs, this.rhs);

  final BoolExpression lhs;
  final BoolExpression rhs;

  @override
  bool get value => lhs.value ^ rhs.value;
}
