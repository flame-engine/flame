import 'dart:ui';

import 'package:flame/text.dart';

/// Text formatter suitable for use in golden tests. This formatter renders
/// words as rectangles.
///
/// Rendering regular text in golden tests is unreliable due to differences in
/// font definitions across platforms and different algorithms used for anti-
/// aliasing.
class DebugTextFormatter extends TextFormatter {
  DebugTextFormatter({
    this.color = const Color(0xFFFFFFFF),
    this.fontSize = 16.0,
    this.lineHeight = 1.2,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
  });

  final Color color;
  final double fontSize;
  final double lineHeight;
  final FontWeight fontWeight;
  final FontStyle fontStyle;

  @override
  TextElement format(String text) => _DebugTextElement(this, text);
}

class _DebugTextElement extends TextElement {
  _DebugTextElement(this.style, this.text) {
    final charWidth = style.fontSize * 1.0;
    final charHeight = style.fontSize;
    paint
      ..color = style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * (style.fontWeight.index + 1) / 4;
    metrics = LineMetrics(
      width: text.length * charWidth,
      ascent: charHeight * (style.lineHeight + 1) / 2,
      descent: charHeight * (style.lineHeight - 1) / 2,
      baseline: charHeight * (style.lineHeight + 1) / 2,
    );
    assert(metrics.left == 0 && metrics.top == 0);
    _initRects(charWidth, charHeight);
  }

  final DebugTextFormatter style;
  final String text;
  final List<Rect> rects = [];
  final Paint paint = Paint();
  @override
  late final LineMetrics metrics;

  @override
  void render(Canvas canvas) {
    canvas.save();
    if (style.fontStyle == FontStyle.italic) {
      canvas.skew(-0.25, 0);
      canvas.translate(metrics.bottom * 0.25, 0);
    }
    for (final rect in rects) {
      canvas.drawRect(rect, paint);
    }
    canvas.restore();
  }

  @override
  void translate(double dx, double dy) {
    metrics.translate(dx, dy);
    for (var i = 0; i < rects.length; i++) {
      rects[i] = rects[i].translate(dx, dy);
    }
  }

  void _initRects(double charWidth, double charHeight) {
    var i0 = 0;
    while (true) {
      while (i0 < text.length && text[i0] == ' ') {
        i0 += 1;
      }
      if (i0 == text.length) {
        break;
      }
      var i1 = i0;
      while (i1 < text.length && text[i1] != ' ') {
        i1 += 1;
      }
      rects.add(
        Rect.fromLTRB(i0 * charWidth, 0, i1 * charWidth, charHeight)
            .deflate(paint.strokeWidth / 2),
      );
      i0 = i1;
    }
  }
}
