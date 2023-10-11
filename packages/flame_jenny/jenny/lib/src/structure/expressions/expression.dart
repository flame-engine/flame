abstract class Expression {
  const Expression();

  dynamic get value;

  bool get isNumeric => type == ExpressionType.numeric;
  bool get isBoolean => type == ExpressionType.boolean;
  bool get isString => type == ExpressionType.string;

  ExpressionType get type {
    return switch (this) {
      NumExpression() => ExpressionType.numeric,
      BoolExpression() => ExpressionType.boolean,
      StringExpression() => ExpressionType.string,
      _ => ExpressionType.unknown,
    };
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
}

abstract class StringExpression extends Expression {
  const StringExpression();

  @override
  String get value;
}

abstract class BoolExpression extends Expression {
  const BoolExpression();

  @override
  bool get value;
}
