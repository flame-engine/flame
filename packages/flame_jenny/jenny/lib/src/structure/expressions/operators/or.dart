import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

/// Logical OR operator, applies to binary operands only.
///
/// The OR operator returns `false` if both of its operands are `false`, and
/// `true` otherwise.
class Or extends BoolExpression {
  const Or(this._lhs, this._rhs);

  final BoolExpression _lhs;
  final BoolExpression _rhs;

  factory Or.make(
    Expression lhs,
    Expression rhs,
    int operatorPosition,
    ErrorFn errorFn,
  ) {
    if (lhs.isBoolean && rhs.isBoolean) {
      return Or(lhs as BoolExpression, rhs as BoolExpression);
    }
    errorFn(
      'both left and right sides of `||` must be boolean, instead the types '
      'are (${lhs.type.name}, ${rhs.type.name})',
      operatorPosition,
    );
  }

  @override
  bool get value => _lhs.value || _rhs.value;
}
