import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/operators/_common.dart';

/// Common class for the EQUAL (==) operator, with separate implementations for
/// each argument type.
abstract class Equal extends Expression {
  factory Equal.make(
    Expression lhs,
    Expression rhs,
    int operatorPosition,
    ErrorFn errorFn,
  ) {
    if (lhs.isNumeric && rhs.isNumeric) {
      return _NumericEqual(lhs as NumExpression, rhs as NumExpression);
    }
    if (lhs.isString && rhs.isString) {
      return _StringEqual(lhs as StringExpression, rhs as StringExpression);
    }
    if (lhs.isBoolean && rhs.isBoolean) {
      return _BooleanEqual(lhs as BoolExpression, rhs as BoolExpression);
    }
    errorFn(
      'equality operator between operands of unrelated types ${lhs.type.name} '
      'and ${rhs.type.name}',
      operatorPosition,
    );
  }
}

/// Operator EQUAL (==) for numeric arguments.
class const _NumericEqual(final NumExpression _lhs, final NumExpression _rhs)
    extends BoolExpression
    implements Equal {
  @override
  bool get value => _lhs.value == _rhs.value;
}

/// Operator EQUAL (==) for string arguments.
class const _StringEqual(
  final StringExpression _lhs,
  final StringExpression _rhs,
) extends BoolExpression implements Equal {
  @override
  bool get value => _lhs.value == _rhs.value;
}

/// Operator EQUAL (==) for boolean arguments.
class const _BooleanEqual(final BoolExpression _lhs, final BoolExpression _rhs)
    extends BoolExpression
    implements Equal {
  @override
  bool get value => _lhs.value == _rhs.value;
}
