import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

/// Operator LESS_OR_EQUAL (<=), applies to numeric operands only.
class LessOrEqual extends BoolExpression {
  const LessOrEqual(this._lhs, this._rhs);

  final NumExpression _lhs;
  final NumExpression _rhs;

  /// Static constructor, used by <parser.dart>
  factory LessOrEqual.make(
    Expression lhs,
    Expression rhs,
    int operatorPosition,
    ErrorFn errorFn,
  ) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return LessOrEqual(lhs as NumExpression, rhs as NumExpression);
    }
    errorFn(
      'both left and right sides of `<=` must be numeric, instead the types '
      'are (${lhs.type.name}, ${rhs.type.name})',
      operatorPosition,
    );
  }

  @override
  bool get value => _lhs.value <= _rhs.value;
}
