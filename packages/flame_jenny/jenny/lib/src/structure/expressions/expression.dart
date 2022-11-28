abstract class Expression {
  const Expression();

  dynamic get value;

  bool get isNumeric => false;
  bool get isBoolean => false;
  bool get isString => false;

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

enum ExpressionType {
  unknown,
  boolean,
  numeric,
  string,
}

abstract class NumExpression extends Expression {
  const NumExpression();

  @override
  num get value;

  @override
  bool get isNumeric => true;
}

abstract class StringExpression extends Expression {
  const StringExpression();

  @override
  String get value;

  @override
  bool get isString => true;
}

abstract class BoolExpression extends Expression {
  const BoolExpression();

  @override
  bool get value;

  @override
  bool get isBoolean => true;
}
