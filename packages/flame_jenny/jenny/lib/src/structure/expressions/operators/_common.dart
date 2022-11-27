import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/structure/expressions/arithmetic.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/literal.dart';
import 'package:jenny/src/structure/expressions/operators/add.dart';
import 'package:jenny/src/structure/expressions/operators/and.dart';
import 'package:jenny/src/structure/expressions/operators/or.dart';
import 'package:jenny/src/structure/expressions/operators/xor.dart';

typedef ErrorFn = Never Function(String message, [int? position]);

typedef BinaryOperatorBuilder = Expression Function(
  Expression lhs,
  Expression rhs,
  int operatorPosition,
  ErrorFn errorFn,
);

Expression? makeBinaryOperatorExpression(
  Token operator,
  Expression lhs,
  Expression rhs,
  int operatorPosition,
  ErrorFn errorFn,
) {
  final builder = _builders[operator];
  if (builder == null) {
    return null;
  }
  return builder(lhs, rhs, operatorPosition, errorFn);
}

final Map<Token, String> _operatorNames = {
  Token.operatorAnd: '&&',
  Token.operatorDivide: '/',
  Token.operatorEqual: '==',
  Token.operatorGreaterOrEqual: '>=',
  Token.operatorGreaterThan: '>',
  Token.operatorLessOrEqual: '<=',
  Token.operatorLessThan: '<',
  Token.operatorMinus: '-',
  Token.operatorModulo: '%',
  Token.operatorMultiply: '*',
  Token.operatorNot: '!',
  Token.operatorNotEqual: '!=',
  Token.operatorOr: '||',
  Token.operatorPlus: '+',
  Token.operatorXor: '^',
};

final Map<Token, BinaryOperatorBuilder> _builders = {
  Token.operatorAnd: And.make,
  Token.operatorOr: Or.make,
  Token.operatorXor: Xor.make,
};
