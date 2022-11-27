import 'package:jenny/src/structure/expressions/expression.dart';


class Negate extends NumExpression {
  const Negate(this.arg);

  final NumExpression arg;

  @override
  num get value => -arg.value;
}
