import 'package:jenny/src/structure/expressions/expression.dart';

class Add extends NumExpression {
  const Add(this.lhs, this.rhs);

  final NumExpression lhs;
  final NumExpression rhs;

  @override
  num get value => lhs.value + rhs.value;

  @override
  String get name => '+';
}
