import 'dart:ui';

import 'package:flame/src/anchor.dart';
import 'package:flame/text.dart';
import 'package:vector_math/vector_math_64.dart';

/// [TextRenderer] is the most basic API for drawing text.
///
/// A text renderer contains a [formatter] that embodies a particular style
/// for rendering text, such as font-family, color, size, and so on.
/// At the same time, nor the text renderer or the [formatter] are tied to a
/// specific string -- it can render any text fragment that you give it.
///
/// A text renderer object has two functions: to measure the size of a text
/// string that it will have when rendered, and to actually render that string
/// onto a canvas.
///
/// [TextRenderer] is a low-level API that may be somewhat inconvenient to use
/// directly. Instead, consider using components such as TextComponent or
/// TextBoxComponent.
///
/// See [TextFormatter] for more information about existing options.
class TextRenderer<T extends TextFormatter> {
  TextRenderer(this.formatter);

  final T formatter;

  TextElement format(String text) {
    return formatter.format(text);
  }

  LineMetrics getLineMetrics(String text) {
    return format(text).metrics;
  }

  void render(
    Canvas canvas,
    String text,
    Vector2 position, {
    Anchor anchor = Anchor.topLeft,
  }) {
    format(text).render(canvas, position, anchor: anchor);
  }
}
