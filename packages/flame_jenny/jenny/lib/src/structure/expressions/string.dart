import 'package:jenny/src/structure/expressions/expression.dart';

class Concatenate extends StringExpression {
  const Concatenate(this.parts);

  final List<StringExpression> parts;

  @override
  String get value => parts.map((p) => p.value).join();
}

class Remove extends StringExpression {
  const Remove(this.lhs, this.rhs);

  final StringExpression lhs;
  final StringExpression rhs;

  @override
  String get value {
    final lhsValue = lhs.value;
    final rhsValue = rhs.value;
    final i = lhsValue.indexOf(rhsValue);
    if (i == -1) {
      return lhsValue;
    } else {
      return lhsValue.substring(0, i) + lhsValue.substring(i + rhsValue.length);
    }
  }
}
