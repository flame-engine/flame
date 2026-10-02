abstract class const Expression() {
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

enum ExpressionType() {
  unknown,
  boolean,
  numeric,
  string,
}

abstract class const NumExpression() extends Expression {
  @override
  num get value;
}

abstract class const StringExpression() extends Expression {
  @override
  String get value;
}

abstract class const BoolExpression() extends Expression {
  @override
  bool get value;
}
