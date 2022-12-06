import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/add.dart';
import 'package:jenny/src/structure/expressions/operators/and.dart';
import 'package:jenny/src/structure/expressions/operators/divide.dart';
import 'package:jenny/src/structure/expressions/operators/equal.dart';
import 'package:jenny/src/structure/expressions/operators/greater_or_equal.dart';
import 'package:jenny/src/structure/expressions/operators/greater_than.dart';
import 'package:jenny/src/structure/expressions/operators/less_or_equal.dart';
import 'package:jenny/src/structure/expressions/operators/less_than.dart';
import 'package:jenny/src/structure/expressions/operators/modulo.dart';
import 'package:jenny/src/structure/expressions/operators/multiply.dart';
import 'package:jenny/src/structure/expressions/operators/not_equal.dart';
import 'package:jenny/src/structure/expressions/operators/or.dart';
import 'package:jenny/src/structure/expressions/operators/subtract.dart';
import 'package:jenny/src/structure/expressions/operators/xor.dart';

typedef ErrorFn = Never Function(String message, [int? position]);
typedef BinaryOperatorBuilder = Expression Function(
  Expression lhs,
  Expression rhs,
  int operatorPosition,
  ErrorFn errorFn,
);

/// Static constructor of expressions involving binary operators. Used by
/// <parser.dart>.
Expression makeBinaryOpExpression(
  Token operator,
  Expression lhs,
  Expression rhs,
  int operatorPosition,
  ErrorFn errorFn,
) {
  final builder = _builders[operator];
  return builder!(lhs, rhs, operatorPosition, errorFn);
}

final Map<Token, BinaryOperatorBuilder> _builders = {
  Token.operatorAnd: And.make,
  Token.operatorDivide: Divide.make,
  Token.operatorEqual: Equal.make,
  Token.operatorGreaterOrEqual: GreaterOrEqual.make,
  Token.operatorGreaterThan: GreaterThan.make,
  Token.operatorLessOrEqual: LessOrEqual.make,
  Token.operatorLessThan: LessThan.make,
  Token.operatorMinus: Subtract.make,
  Token.operatorModulo: Modulo.make,
  Token.operatorMultiply: Multiply.make,
  Token.operatorNotEqual: NotEqual.make,
  Token.operatorOr: Or.make,
  Token.operatorPlus: Add.make,
  Token.operatorXor: Xor.make,
};
