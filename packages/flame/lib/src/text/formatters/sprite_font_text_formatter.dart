import 'dart:typed_data';
import 'dart:ui' hide LineMetrics;

import 'package:flame/src/text/common/glyph_data.dart';
import 'package:flame/src/text/common/glyph_info.dart';
import 'package:flame/src/text/common/line_metrics.dart';
import 'package:flame/src/text/formatters/text_formatter.dart';
import 'package:flame/src/text/inline/sprite_font_text_element.dart';

class SpriteFontTextFormatter extends TextFormatter {
  SpriteFontTextFormatter({
    required this.source,
    required double charWidth,
    required double charHeight,
    required Map<String, GlyphData> glyphs,
    this.scale = 1,
    this.letterSpacing = 0,
  })  : scaledCharWidth = charWidth * scale,
        scaledCharHeight = charHeight * scale,
        _glyphs = glyphs.map((char, rect) {
          assert(
            char.length == 1,
            'A glyph must have a single character: "$char"',
          );
          final info = GlyphInfo();
          info.srcLeft = rect.left;
          info.srcTop = rect.top;
          info.srcRight = rect.right ?? rect.left + charWidth;
          info.srcBottom = rect.bottom ?? rect.top + charHeight;
          info.rstSCos = scale;
          info.rstTy = (charHeight - (info.srcBottom - info.srcTop)) * scale;
          info.width = charWidth * scale;
          info.height = charHeight * scale;
          return MapEntry(char.codeUnitAt(0), info);
        });

  final Image source;
  final paint = Paint()..color = const Color(0xFFFFFFFF);
  final double letterSpacing;
  final double scale;
  final double scaledCharWidth;
  final double scaledCharHeight;
  final Map<int, GlyphInfo> _glyphs;

  @override
  SpriteFontTextElement format(String text) {
    final rstTransforms = Float32List(4 * text.length);
    final rects = Float32List(4 * text.length);
    var j = 0;
    var x0 = 0.0;
    final y0 = -scaledCharHeight;
    for (final glyph in _textToGlyphs(text)) {
      rects[j + 0] = glyph.srcLeft;
      rects[j + 1] = glyph.srcTop;
      rects[j + 2] = glyph.srcRight;
      rects[j + 3] = glyph.srcBottom;
      rstTransforms[j + 0] = glyph.rstSCos;
      rstTransforms[j + 1] = glyph.rstSSin;
      rstTransforms[j + 2] = x0 + glyph.rstTx;
      rstTransforms[j + 3] = y0 + glyph.rstTy;
      x0 += glyph.width + letterSpacing;
      j += 4;
    }
    return SpriteFontTextElement(
      source: source,
      transforms: rstTransforms,
      rects: rects,
      paint: paint,
      metrics: LineMetrics(width: x0, height: scaledCharHeight, descent: 0),
    );
  }

  Iterable<GlyphInfo> _textToGlyphs(String text) {
    return text.codeUnits.map((int i) {
      final glyph = _glyphs[i];
      assert(
        glyph != null,
        'No glyph for character "${String.fromCharCode(i)}"',
      );
      return glyph!;
    });
  }
}
