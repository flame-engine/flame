import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

/// Logical XOR, applies to boolean arguments only.
///
/// The XOR operator returns `false` when both of its operands are the same,
/// and `true` when they are different.
class Xor extends BoolExpression {
  Xor(this._lhs, this._rhs);

  final BoolExpression _lhs;
  final BoolExpression _rhs;

  /// Static constructor, used by <parse.dart>.
  factory Xor.make(
    Expression lhs,
    Expression rhs,
    int operatorPosition,
    ErrorFn errorFn,
  ) {
    if (lhs.isBoolean && rhs.isBoolean) {
      return Xor(lhs as BoolExpression, rhs as BoolExpression);
    }
    errorFn(
      'both left and right sides of `^` must be boolean, instead the types '
      'are (${lhs.type.name}, ${rhs.type.name})',
      operatorPosition,
    );
  }

  @override
  bool get value => _lhs.value ^ _rhs.value;
}
