abstract class Expression {
  const Expression();

  dynamic get value;

  bool get isNumeric;
  bool get isBoolean;
  bool get isString;

  ExpressionType get type {
    return isNumeric
        ? ExpressionType.numeric
        : isBoolean
            ? ExpressionType.boolean
            : isString
                ? ExpressionType.string
                : ExpressionType.unknown;
  }
}

abstract class TypedExpression<T> extends Expression {
  const TypedExpression();

  @override
  T get value;

  @override
  bool get isNumeric => T is num;

  @override
  bool get isBoolean => T is bool;

  @override
  bool get isString => T is String;
}

enum ExpressionType {
  unknown,
  boolean,
  numeric,
  string,
}
