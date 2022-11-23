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
  bool get isDynamic => expressions != null;

  String evaluate() {
    if (expressions == null) {
      return text;
    }
    _resetAttributes();
    final out = StringBuffer();
    var previousPosition = 0;
    for (final e in expressions!) {
      out.write(text.substring(previousPosition, e.position));
      final insert = e.expression.value;
      _adjustAttributes(e.position, insert.length);
      previousPosition = e.position;
      out.write(insert);
    }
    out.write(text.substring(previousPosition));
    return out.toString();
  }

  void _resetAttributes() {
    if (attributes != null) {
      for (final attribute in attributes!) {
        attribute.start = attribute.startPosition;
        attribute.end = attribute.endPosition;
      }
    }
  }

  void _adjustAttributes(int position, int length) {
    if (attributes != null) {
      for (final attribute in attributes!) {
        if (attribute.start > position) {
          attribute.start += length;
          attribute.end += length;
        } else if (attribute.end >= position) {
          attribute.end += length;
        }
      }
    }
  }
}

@internal
class InlineExpression {
  InlineExpression(this.position, this.expression);
  final int position;
  final StringExpression expression;
}
