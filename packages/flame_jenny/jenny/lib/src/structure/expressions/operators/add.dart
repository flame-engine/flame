import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

class Add {
  static Expression make(
    Expression lhs,
    Expression rhs,
    int operatorPosition,
    ErrorFn errorFn,
  ) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return _NumAdd(lhs as NumExpression, rhs as NumExpression);
    }
    if (lhs.isString && rhs.isString) {
      return _StringAdd(lhs as StringExpression, rhs as StringExpression);
    }
    errorFn(
      'both left and right sides of `+` must be numeric or strings, instead '
      'the types are (${lhs.type.name}, ${rhs.type.name})',
      operatorPosition,
    );
  }
}

/// Operator PLUS (+) for numeric arguments.
class _NumAdd extends NumExpression {
  _NumAdd(this._lhs, this._rhs);

  final NumExpression _lhs;
  final NumExpression _rhs;

  @override
  num get value => _lhs.value + _rhs.value;
}

/// Operator PLUS (+) for string arguments.
class _StringAdd extends StringExpression {
  _StringAdd(this._lhs, this._rhs);

  final StringExpression _lhs;
  final StringExpression _rhs;

  @override
  String get value => _lhs.value + _rhs.value;
}
