
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:meta/meta.dart';

@internal
class LineContent {
  LineContent(this.text, [this.expressions]);

  final String text;
  final List<InlineExpression>? expressions;

  String evaluate() {
    if (expressions == null) {
      return text;
    }
    final out = StringBuffer();
    var previousPosition = 0;
    for (final e in expressions!) {
      out.write(text.substring(previousPosition, e.position));
      out.write(e.expression.value);
      previousPosition = e.position;
    }
    out.write(text.substring(previousPosition));
    return out.toString();
  }
}

@internal
class InlineExpression {
  InlineExpression(this.position, this.expression);
  final int position;
  final StringExpression expression;
}
