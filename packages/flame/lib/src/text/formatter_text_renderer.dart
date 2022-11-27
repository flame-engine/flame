import 'dart:ui';

import 'package:flame/src/anchor.dart';
import 'package:flame/text.dart';
import 'package:vector_math/vector_math_64.dart';

/// Helper class that implements a [TextRenderer] using a [TextFormatter].
class FormatterTextRenderer<T extends TextFormatter> extends TextRenderer {
  FormatterTextRenderer(this.formatter);

  final T formatter;

  @override
  Vector2 measureText(String text) {
    final box = formatter.format(text).metrics;
    return Vector2(box.width, box.height);
  }

  @override
  void render(
    Canvas canvas,
    String text,
    Vector2 position, {
    Anchor anchor = Anchor.topLeft,
  }) {
    final txt = formatter.format(text);
    final box = txt.metrics;
    txt.translate(
      position.x - box.width * anchor.x,
      position.y - box.height * anchor.y - box.top,
    );
    txt.render(canvas);
  }
}
