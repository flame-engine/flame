
import 'package:flame_yarn/src/structure/expressions/expression.dart';

class Literal<T> extends TypedExpression<T> {
  const Literal(this.value);

  @override
  final T value;
}

const constEmptyString = Literal<String>('');
const constTrue = Literal<bool>(true);
const constFalse = Literal<bool>(false);
