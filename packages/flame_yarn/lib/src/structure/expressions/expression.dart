
abstract class Expression {
  const Expression();

  dynamic get value;
  ExpressionType get type;
}

abstract class TypedExpression<T> extends Expression {
  const TypedExpression();

  @override
  T get value;

  @override
  ExpressionType get type {
    return (T is bool)
        ? ExpressionType.boolean
        : (T is num)
            ? ExpressionType.numeric
            : (T is String)
                ? ExpressionType.string
                : ExpressionType.unknown;
  }
}

enum ExpressionType {
  unknown,
  boolean,
  numeric,
  string,
}
