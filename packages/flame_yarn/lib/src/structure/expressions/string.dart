import 'package:flame_yarn/src/structure/expressions/expression.dart';

class Concat extends Expression<String> {
  const Concat(this.parts);

  final List<Expression<String>> parts;

  @override
  String get value => parts.map((p) => p.value).join();
}

class Remove extends Expression<String> {
  const Remove(this.lhs, this.rhs);

  final Expression<String> lhs;
  final Expression<String> rhs;

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

class Repeat extends Expression<String> {
  const Repeat(this.lhs, this.rhs);

  final Expression<String> lhs;
  final Expression<num> rhs;

  @override
  String get value => List.filled(rhs.value.toInt(), lhs.value).join();
}
