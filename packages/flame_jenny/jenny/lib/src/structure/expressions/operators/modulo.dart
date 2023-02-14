import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

/// Operator MODULO (%), applies to numeric arguments only.
///
/// The divisor of a modulo must be a positive number. The result of `x % y` is
/// always a number between 0 and `y`, regardless of the sign of `x`.
class Modulo extends NumExpression {
  const Modulo(this._lhs, this._rhs);

  final NumExpression _lhs;
  final NumExpression _rhs;

  /// Static constructor, used by <parser.dart>
  factory Modulo.make(
    Expression lhs,
    Expression rhs,
    int operatorPosition,
    ErrorFn errorFn,
  ) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return Modulo(lhs as NumExpression, rhs as NumExpression);
    }
    errorFn(
      'both left and right sides of `%` must be numeric, instead the types are '
      '(${lhs.type.name}, ${rhs.type.name})',
      operatorPosition,
    );
  }

  @override
  num get value {
    final x = _lhs.value;
    final y = _rhs.value;
    if (y <= 0) {
      throw DialogueError(
        'The divisor of a modulo is not a positive number: $y',
      );
    }
    return x % y;
  }
}
