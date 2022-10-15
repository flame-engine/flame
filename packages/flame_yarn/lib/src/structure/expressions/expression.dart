abstract class Expression<T> extends ExpressionBase {
  const Expression();

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

abstract class ExpressionBase {
  const ExpressionBase();

  dynamic get value;
  ExpressionType get type;
}

enum ExpressionType {
  unknown,
  boolean,
  numeric,
  string,
}
