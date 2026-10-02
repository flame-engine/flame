import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

/// Operator GREATER_OR_EQUAL (>=), applies to numeric operands only.
class const GreaterOrEqual(final NumExpression _lhs, final NumExpression _rhs)
    extends BoolExpression {
  /// Static constructor, used by parse.dart
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
