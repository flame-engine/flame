import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

class Subtract {
  static Expression make(
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
class _NumSubtract extends NumExpression {
  _NumSubtract(this._lhs, this._rhs);

  final NumExpression _lhs;
  final NumExpression _rhs;

  @override
  num get value => _lhs.value - _rhs.value;
}

/// Operator MINUS (-) for string arguments.
class _StringSubtract extends StringExpression {
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
