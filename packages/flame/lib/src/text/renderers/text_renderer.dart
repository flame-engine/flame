import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/src/anchor.dart';
import 'package:flame/text.dart';

/// [TextRenderer] is an abstract interface for a class that can convert an
/// arbitrary string of text into a renderable [InlineTextElement].
abstract class TextRenderer {
  InlineTextElement format(String text);

  LineMetrics getLineMetrics(String text) {
    return format(text).metrics;
  }

  /// Returns a copy of this renderer with [paint] applied on top of its own
  /// styling.
  ///
  /// This is used by `TextComponent` whenever its paint changes, for example
  /// by an `OpacityEffect` or a `ColorEffect`. The returned renderer should
  /// keep the colors and other properties of this renderer, and scale its
  /// opacity by the opacity of [paint]. Implementations are always given the
  /// renderer that was originally set on the component, never a previously
  /// returned copy, so the opacity does not compound.
  TextRenderer copyWithPaint(Paint paint);

  void render(
    Canvas canvas,
    String text,
    Vector2 position, {
    Anchor anchor = Anchor.topLeft,
  }) {
    format(text).render(canvas, position, anchor: anchor);
  }
}
