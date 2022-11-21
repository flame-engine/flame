
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:meta/meta.dart';

@internal
class LineContent {
  LineContent(this.text, this.expressions);

  final String text;
  final List<InlineExpression>? expressions;
}

class InlineExpression {
  InlineExpression(this.position, this.expression);
  final int position;
  final StringExpression expression;
}
