import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

/// Operator GREATER_THAN(>), applies to numeric operands only.
class GreaterThan extends BoolExpression {
  const GreaterThan(this._lhs, this._rhs);

  final NumExpression _lhs;
  final NumExpression _rhs;

  /// Static constructor, used by <parser.dart>
  factory GreaterThan.make(
    Expression lhs,
    Expression rhs,
    int operatorPosition,
    ErrorFn errorFn,
  ) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return GreaterThan(lhs as NumExpression, rhs as NumExpression);
    }
    errorFn(
      'both left and right sides of `>` must be numeric, instead the types '
      'are (${lhs.type.name}, ${rhs.type.name})',
      operatorPosition,
    );
  }

  @override
  bool get value => _lhs.value > _rhs.value;
}
