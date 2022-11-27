import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

/// Common class for the MINUS (-) operator, with separate implementations for
/// the numeric and string arguments.
abstract class Subtract extends Expression {
  factory Subtract.make(
    Expression lhs,
    Expression rhs,
    int operatorPosition,
    ErrorFn errorFn,
  ) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return _NumSubtract(lhs as NumExpression, rhs as NumExpression);
    }
    if (lhs.isString && rhs.isString) {
      return _StringSubtract(lhs as StringExpression, rhs as StringExpression);
    }
    errorFn(
      'both left and right sides of `-` must be numeric or strings, instead '
      'the types are (${lhs.type.name}, ${rhs.type.name})',
      operatorPosition,
    );
  }
}

/// Operator MINUS (-) for numeric arguments.
class _NumSubtract extends NumExpression implements Subtract {
  _NumSubtract(this._lhs, this._rhs);

  final NumExpression _lhs;
  final NumExpression _rhs;

  @override
  num get value => _lhs.value - _rhs.value;
}

/// Operator MINUS (-) for string arguments.
///
/// In the expression `x - y`, the first occurrence of string `y` is removed
/// from `x`. For example, `"YarnSpinner" - "n" == "YarSpinner"`. If there is
/// no string `y` in `x`, then `x` is returned unmodified.
class _StringSubtract extends StringExpression implements Subtract {
  _StringSubtract(this._lhs, this._rhs);

  final StringExpression _lhs;
  final StringExpression _rhs;

  @override
  String get value {
    final lhsValue = _lhs.value;
    final rhsValue = _rhs.value;
    final i = lhsValue.indexOf(rhsValue);
    if (i == -1) {
      return lhsValue;
    } else {
      return lhsValue.substring(0, i) + lhsValue.substring(i + rhsValue.length);
    }
  }
}
