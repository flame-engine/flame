import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

/// Operator GREATER_OR_EQUAL (>=), applies to numeric operands only.
class GreaterOrEqual extends BoolExpression {
  const GreaterOrEqual(this._lhs, this._rhs);

  final NumExpression _lhs;
  final NumExpression _rhs;

  /// Static constructor, used by <parser.dart>
  factory GreaterOrEqual.make(
    Expression lhs,
    Expression rhs,
    int operatorPosition,
    ErrorFn errorFn,
  ) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return GreaterOrEqual(lhs as NumExpression, rhs as NumExpression);
    }
    errorFn(
      'both left and right sides of `>=` must be numeric, instead the types '
      'are (${lhs.type.name}, ${rhs.type.name})',
      operatorPosition,
    );
  }

  @override
  bool get value => _lhs.value >= _rhs.value;
}
