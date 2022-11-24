import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/markup_attribute.dart';
import 'package:meta/meta.dart';

@internal
class LineContent {
  LineContent(this.text, [this.expressions, this.attributes]);

  final String text;
  final List<InlineExpression>? expressions;
  final List<MarkupAttribute>? attributes;

  bool get isConst => expressions == null;

  String evaluate() {
    attributes?.forEach((a) => a.reset());
    if (expressions == null) {
      return text;
    }
    final out = StringBuffer();
    var previousPosition = 0;
    var subIndex = 0;
    for (final e in expressions!) {
      if (previousPosition < e.position) {
        out.write(text.substring(previousPosition, e.position));
        subIndex = 0;
      }
      final insert = e.expression.value;
      attributes?.forEach((a) {
        a.maybeShift(e.position, insert.length, subIndex);
      });
      out.write(insert);
      subIndex += 1;
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
