import 'package:jenny/src/structure/expressions/expression.dart';

class NumLiteral extends NumExpression {
  const NumLiteral(this.value);

  @override
  final num value;
}

class StringLiteral extends StringExpression {
  const StringLiteral(this.value);

  @override
  final String value;
}

class BoolLiteral extends BoolExpression {
  const BoolLiteral(this.value);

  @override
  final bool value;
}

class VoidLiteral extends Expression {
  const VoidLiteral();

  @override
  dynamic get value => null;
}

const constEmptyString = StringLiteral('');
const constTrue = BoolLiteral(true);
const constFalse = BoolLiteral(false);
const constVoid = VoidLiteral();
const constZero = NumLiteral(0);
