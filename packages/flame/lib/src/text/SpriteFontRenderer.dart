import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/src/anchor.dart';
import 'package:flame/src/text.dart';
import 'package:vector_math/vector_math_64.dart';

class SpriteFontRenderer extends TextRenderer {
  SpriteFontRenderer(
    this.source, {
    this.charWidth,
    this.charHeight,
  });

  final Image source;
  double? charWidth;
  double? charHeight;
  bool get isMonospace => charWidth != null;

  Map<int, _GlyphInfo> glyphs = {};
  Paint paint = Paint()..color = const Color(0xFFFFFFFF);

  void addGlyph({
    required String char,
    required double srcLeft,
    required double srcTop,
    required double srcRight,
    required double srcBottom,
    double scale = 1,
  }) {
    assert(char.length == 1, 'A glyph must have a single character: "$char"');
    final codePoint = char.codeUnitAt(0);
    assert(
      !glyphs.containsKey(codePoint),
      'A glyph for "$char" has already been added',
    );
    final info = _GlyphInfo();
    info.srcLeft = srcLeft;
    info.srcTop = srcTop;
    info.srcRight = srcRight;
    info.srcBottom = srcBottom;
    info.rstSCos = scale;
    info.width = charWidth ?? (srcRight - srcLeft);
    glyphs[codePoint] = info;
  }

  Iterable<_GlyphInfo> textToGlyphs(String text) {
    return text.codeUnits.map(getGlyphFromCodeUnit);
  }

  _GlyphInfo getGlyphFromCodeUnit(int i) {
    final glyph = glyphs[i];
    if (glyph == null) {
      throw ArgumentError('No glyph for character "${String.fromCharCode(i)}"');
    }
    return glyph;
  }

  @override
  double measureTextHeight(String text) => charHeight!;

  @override
  double measureTextWidth(String text) {
    if (charWidth != null) {
      return charWidth! * text.length;
    }
    var width = 0.0;
    for (final g in textToGlyphs(text)) {
      width += g.width;
    }
    return width;
  }

  @override
  void render(
    Canvas canvas,
    String text,
    Vector2 position, {
    Anchor anchor = Anchor.topLeft,
  }) {
    final rstTransforms = Float32List(4 * text.length);
    final rects = Float32List(4 * text.length);
    var j = 0;
    var x0 = position.x;
    final y0 = position.y;
    for (final glyph in textToGlyphs(text)) {
      rects[j + 0] = glyph.srcLeft;
      rects[j + 1] = glyph.srcTop;
      rects[j + 2] = glyph.srcRight;
      rects[j + 3] = glyph.srcBottom;
      rstTransforms[j + 0] = glyph.rstSCos;
      rstTransforms[j + 1] = glyph.rstSSin;
      rstTransforms[j + 2] = x0 + glyph.rstTx;
      rstTransforms[j + 3] = y0 + glyph.rstTy;
      x0 += glyph.width;
      j += 4;
    }
    canvas.drawRawAtlas(source, rstTransforms, rects, null, null, null, paint);
  }
}

class _GlyphInfo {
  double srcLeft = 0;
  double srcTop = 0;
  double srcRight = 0;
  double srcBottom = 0;
  double rstSCos = 1;
  double rstSSin = 0;
  double rstTx = 0;
  double rstTy = 0;
  double width = 0;
}
