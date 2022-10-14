import 'dart:typed_data';
import 'dart:ui' hide LineMetrics;

import 'package:flame/src/text/common/glyph.dart';
import 'package:flame/src/text/common/glyph_data.dart';
import 'package:flame/src/text/common/line_metrics.dart';
import 'package:flame/src/text/common/sprite_font.dart';
import 'package:flame/src/text/elements/sprite_font_text_element.dart';
import 'package:flame/src/text/elements/text_element.dart';
import 'package:flame/src/text/formatters/text_formatter.dart';

class SpriteFontTextFormatter extends TextFormatter {
  @Deprecated('Use SpriteFontTextFormatter.fromFont() instead; this '
      'constructor will be removed in 1.6.0')
  SpriteFontTextFormatter({
    required Image source,
    required double charWidth,
    required double charHeight,
    // ignore: deprecated_member_use_from_same_package
    required Map<String, GlyphData> glyphs,
    this.scale = 1,
    this.letterSpacing = 0,
  })  : font = SpriteFont(
          source: source,
          size: charHeight,
          ascent: charHeight,
          defaultCharWidth: charWidth,
          glyphs: [
            for (final kv in glyphs.entries)
              Glyph.fromGlyphData(kv.key, kv.value)
          ],
        ),
        paint = Paint();

  SpriteFontTextFormatter.fromFont(
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
  TextElement format(String text) {
    var rects = Float32List(text.length * 4);
    var rsts = Float32List(text.length * 4);
    var j = 0;
    var x0 = 0.0;
    for (final glyph in font.textToGlyphs(text)) {
      rects[j + 0] = glyph.srcLeft;
      rects[j + 1] = glyph.srcTop;
      rects[j + 2] = glyph.srcRight;
      rects[j + 3] = glyph.srcBottom;
      rsts[j + 0] = scale;
      rsts[j + 1] = 0;
      rsts[j + 2] = x0 + (glyph.srcLeft - glyph.left) * scale;
      rsts[j + 3] = (glyph.srcTop - glyph.top - font.ascent) * scale;
      j += 4;
      x0 += glyph.width * scale + letterSpacing;
    }
    if (j < text.length * 4) {
      rects = rects.sublist(0, j);
      rsts = rsts.sublist(0, j);
    }
    return SpriteFontTextElement(
      source: font.source,
      transforms: rsts,
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
