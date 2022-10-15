
import 'package:flame_yarn/src/structure/expressions/expression.dart';

class Literal<T> extends Expression<T> {
  const Literal(this.value);

  @override
  final T value;
}

const constTrue = Literal<bool>(true);
const constFalse = Literal<bool>(false);
