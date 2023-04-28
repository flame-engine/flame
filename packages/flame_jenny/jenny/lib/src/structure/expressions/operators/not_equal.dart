import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

/// Common class for the NOT_EQUAL (!=) operator, with separate implementations
/// for each argument type.
abstract class NotEqual extends Expression {
  factory NotEqual.make(
    Expression lhs,
    Expression rhs,
    int operatorPosition,
    ErrorFn errorFn,
  ) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return _NumericNotEqual(lhs as NumExpression, rhs as NumExpression);
    }
    if (lhs.isString && rhs.isString) {
      return _StringNotEqual(lhs as StringExpression, rhs as StringExpression);
    }
    if (lhs.isBoolean && rhs.isBoolean) {
      return _BooleanNotEqual(lhs as BoolExpression, rhs as BoolExpression);
    }
    errorFn(
      'inequality operator between operands of unrelated types '
      '${lhs.type.name} and ${rhs.type.name}',
      operatorPosition,
    );
  }
}

/// Operator NOT_EQUAL (!=) for numeric arguments.
class _NumericNotEqual extends BoolExpression implements NotEqual {
  const _NumericNotEqual(this._lhs, this._rhs);

  final NumExpression _lhs;
  final NumExpression _rhs;

  @override
  bool get value => _lhs.value != _rhs.value;
}

/// Operator NOT_EQUAL (!=) for string arguments.
class _StringNotEqual extends BoolExpression implements NotEqual {
  const _StringNotEqual(this._lhs, this._rhs);

  final StringExpression _lhs;
  final StringExpression _rhs;

  @override
  bool get value => _lhs.value != _rhs.value;
}

/// Operator NOT_EQUAL (!=) for boolean arguments.
class _BooleanNotEqual extends BoolExpression implements NotEqual {
  const _BooleanNotEqual(this._lhs, this._rhs);

  final BoolExpression _lhs;
  final BoolExpression _rhs;

  @override
  bool get value => _lhs.value != _rhs.value;
}
