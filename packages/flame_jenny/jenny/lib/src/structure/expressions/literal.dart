import 'package:jenny/src/structure/expressions/expression.dart';

class const NumLiteral(@override final num value) extends NumExpression;

class const StringLiteral(@override final String value)
    extends StringExpression;

// ignore: avoid_positional_boolean_parameters
class const BoolLiteral(@override final bool value) extends BoolExpression;

class const VoidLiteral() extends Expression {
  @override
  dynamic get value => null;
}

const constEmptyString = StringLiteral('');
const constTrue = BoolLiteral(true);
const constFalse = BoolLiteral(false);
const constVoid = VoidLiteral();
const constZero = NumLiteral(0);
