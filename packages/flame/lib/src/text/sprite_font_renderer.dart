import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/src/anchor.dart';
import 'package:flame/src/text/text_renderer.dart';
import 'package:vector_math/vector_math_64.dart';

/// [TextRenderer] implementation that uses a spritesheet of various font glyphs
/// to render text.
///
/// For example, suppose there is a spritesheet with sprites for characters from
/// A to Z. Mapping these sprites into a [SpriteFontRenderer] allows then to
/// write text using these sprite images as the font.
///
/// Currently, this class supports monospace fonts only -- the width and the
/// height of all characters must be the same ([charWidth] and [charHeight]).
/// Extra space between letters can be added via the [letterSpacing] parameter
/// (it can also be negative to "squish" characters together). Finally, the
/// [scale] parameter allows scaling the font to be bigger/smaller relative to
/// its size in the source image.
///
/// The [paint] parameter is used to composite the character images onto the
/// canvas. Its default value will draw the character images as-is. Changing
/// the opacity of the paint's color will make the text semi-transparent.
class SpriteFontRenderer extends TextRenderer {
  SpriteFontRenderer({
    required this.source,
    required this.charWidth,
    required this.charHeight,
    this.letterSpacing = 0,
    this.scale = 1,
  });

  final Image source;
  final double charWidth;
  final double charHeight;
  final double scale;
  double letterSpacing;
  bool get isMonospace => true;

  final Map<int, _GlyphInfo> _glyphs = {};
  Paint paint = Paint()..color = const Color(0xFFFFFFFF);

  void addGlyph({
    required String char,
    required num srcLeft,
    required num srcTop,
    double? srcRight,
    double? srcBottom,
  }) {
    assert(char.length == 1, 'A glyph must have a single character: "$char"');
    final codePoint = char.codeUnitAt(0);
    assert(
      !_glyphs.containsKey(codePoint),
      'A glyph for "$char" has already been added',
    );
    final info = _GlyphInfo();
    info.srcLeft = srcLeft.toDouble();
    info.srcTop = srcTop.toDouble();
    info.srcRight = srcRight ?? srcLeft + charWidth;
    info.srcBottom = srcBottom ?? srcTop + charHeight;
    info.rstSCos = scale;
    info.width = charWidth * scale;
    info.rstTy = (charHeight - (info.srcBottom - srcTop)) * scale;
    _glyphs[codePoint] = info;
  }

  @override
  double measureTextHeight(String text) => charHeight * scale;

  @override
  double measureTextWidth(String text) {
    final n = text.length;
    return n > 0 ? charWidth * scale * n + letterSpacing * (n - 1) : 0;
  }

  @override
  Vector2 measureText(String text) {
    return Vector2(measureTextWidth(text), measureTextHeight(text));
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
    canvas.drawRawAtlas(source, rstTransforms, rects, null, null, null, paint);
  }

  Iterable<_GlyphInfo> _textToGlyphs(String text) {
    return text.codeUnits.map(_getGlyphFromCodeUnit);
  }

  _GlyphInfo _getGlyphFromCodeUnit(int i) {
    final glyph = _glyphs[i];
    if (glyph == null) {
      throw ArgumentError('No glyph for character "${String.fromCharCode(i)}"');
    }
    return glyph;
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
