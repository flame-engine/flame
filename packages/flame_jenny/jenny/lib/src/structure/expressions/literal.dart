import 'package:jenny/src/structure/expressions/expression.dart';

class const NumLiteral(@override final num value) extends NumExpression;

class const StringLiteral(@override final String value)
    extends StringExpression;

class const BoolLiteral({@override required final bool value})
    extends BoolExpression;

class const VoidLiteral() extends Expression {
  @override
  dynamic get value => null;
}

const constEmptyString = StringLiteral('');
const constTrue = BoolLiteral(value: true);
const constFalse = BoolLiteral(value: false);
const constVoid = VoidLiteral();
const constZero = NumLiteral(0);
