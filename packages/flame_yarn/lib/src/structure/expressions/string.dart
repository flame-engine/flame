import 'package:flame_yarn/src/structure/expressions/expression.dart';

class Concat extends TypedExpression<String> {
  const Concat(this.parts);

  final List<TypedExpression<String>> parts;

  @override
  String get value => parts.map((p) => p.value).join();
}

class Remove extends TypedExpression<String> {
  const Remove(this.lhs, this.rhs);

  final TypedExpression<String> lhs;
  final TypedExpression<String> rhs;

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

class Repeat extends TypedExpression<String> {
  const Repeat(this.lhs, this.rhs);

  final TypedExpression<String> lhs;
  final TypedExpression<num> rhs;

  @override
  String get value => List.filled(rhs.value.toInt(), lhs.value).join();
}
