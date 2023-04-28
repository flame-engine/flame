import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

/// Logical AND operator, applies to binary operands only.
///
/// The AND operator returns `true` if both of its operands are `true`, and
/// `false` otherwise.
class And extends BoolExpression {
  And(this._lhs, this._rhs);

  final BoolExpression _lhs;
  final BoolExpression _rhs;

  /// Static constructor, used by <parse.dart>.
  factory And.make(
    Expression lhs,
    Expression rhs,
    int operatorPosition,
    ErrorFn errorFn,
  ) {
    if (lhs.isBoolean && rhs.isBoolean) {
      return And(lhs as BoolExpression, rhs as BoolExpression);
    }
    errorFn(
      'both left and right sides of `&&` must be boolean, instead the types '
      'are (${lhs.type.name}, ${rhs.type.name})',
      operatorPosition,
    );
  }

  @override
  bool get value => _lhs.value && _rhs.value;
}
