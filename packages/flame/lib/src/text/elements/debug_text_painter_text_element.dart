import 'dart:ui';

import 'package:flame/src/text/elements/text_painter_text_element.dart';

/// Replacement class for [TextPainterTextElement] which draws solid rectangles
/// instead of regular text.
///
/// This class is useful for testing purposes: different test environments may
/// have slightly different font definitions and mechanisms for anti-aliased
/// font rendering, which makes it impossible to create golden tests with
/// regular text painter.
class DebugTextPainterTextElement extends TextPainterTextElement {
  @Deprecated('Use DebugTextFormatter instead. Will be removed in 1.5.0')
  DebugTextPainterTextElement(super.textPainter);

  final paint = Paint()..color = const Color(0xFFFFFFFF);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(metrics.toRect(), paint);
  }
}
