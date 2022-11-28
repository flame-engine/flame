import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

/// Operator DIVIDE (/), applies to numeric arguments only.
class Divide extends NumExpression {
  const Divide(this._lhs, this._rhs);

  final NumExpression _lhs;
  final NumExpression _rhs;

  /// Static constructor, used by <parser.dart>
  factory Divide.make(
    Expression lhs,
    Expression rhs,
    int operatorPosition,
    ErrorFn errorFn,
  ) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return Divide(lhs as NumExpression, rhs as NumExpression);
    }
    errorFn(
      'both left and right sides of `/` must be numeric, instead the types are '
      '(${lhs.type.name}, ${rhs.type.name})',
      operatorPosition,
    );
  }

  @override
  num get value {
    final x = _lhs.value.toDouble();
    final y = _rhs.value.toDouble();
    if (y == 0) {
      throw DialogueError('Division by zero');
    }
    return x / y;
  }
}
