import 'dart:typed_data';
import 'dart:ui' hide LineMetrics;

import 'package:flame/text.dart';

/// [SpriteFontRenderer] will render text using a [SpriteFont] font,
/// creating a [SpriteFontTextElement].
class SpriteFontRenderer extends TextRenderer {
  SpriteFontRenderer.fromFont(
    this.font, {
    this.scale = 1.0,
    this.letterSpacing = 0.0,
    Color? color,
  }) : paint = Paint() {
    if (color != null) {
      paint.colorFilter = ColorFilter.mode(color, BlendMode.srcIn);
    }
  }

  final SpriteFont font;
  final double scale;
  final double letterSpacing;
  final Paint paint;

  @override
  SpriteFontTextElement format(String text) {
    var rects = Float32List(text.length * 4);
    var transforms = Float32List(text.length * 4);
    var j = 0;
    var x0 = 0.0;
    for (final glyph in font.textToGlyphs(text)) {
      rects[j + 0] = glyph.srcLeft;
      rects[j + 1] = glyph.srcTop;
      rects[j + 2] = glyph.srcRight;
      rects[j + 3] = glyph.srcBottom;
      transforms[j + 0] = scale;
      transforms[j + 1] = 0;
      transforms[j + 2] = x0 + (glyph.srcLeft - glyph.left) * scale;
      transforms[j + 3] = (glyph.srcTop - glyph.top - font.ascent) * scale;
      j += 4;
      x0 += glyph.width * scale + letterSpacing;
    }
    if (j < text.length * 4) {
      rects = rects.sublist(0, j);
      transforms = transforms.sublist(0, j);
    }
    return SpriteFontTextElement(
      source: font.source,
      transforms: transforms,
      rects: rects,
      paint: paint,
      metrics: LineMetrics(
        width: x0 - letterSpacing,
        height: font.size * scale,
        ascent: font.ascent * scale,
      ),
    );
  }
}
