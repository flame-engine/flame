import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

/// Operator MULTIPLY (*), applies to numeric arguments only.
class Multiply extends NumExpression {
  const Multiply(this._lhs, this._rhs);

  final NumExpression _lhs;
  final NumExpression _rhs;

  /// Static constructor, used by <parser.dart>
  factory Multiply.make(
    Expression lhs,
    Expression rhs,
    int operatorPosition,
    ErrorFn errorFn,
  ) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return Multiply(lhs as NumExpression, rhs as NumExpression);
    }
    errorFn(
      'both left and right sides of `*` must be numeric, instead the types are '
      '(${lhs.type.name}, ${rhs.type.name})',
      operatorPosition,
    );
  }

  @override
  num get value => _lhs.value * _rhs.value;
}
