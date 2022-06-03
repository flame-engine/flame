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
/// Currently, this class supports monospace fonts only -- the widths and the
/// heights of all characters must be the same.
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
          final info = _GlyphInfo();
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
  final Map<int, _GlyphInfo> _glyphs;
  final double letterSpacing;
  final double scale;
  final double scaledCharWidth;
  final double scaledCharHeight;
  bool get isMonospace => true;

  Paint paint = Paint()..color = const Color(0xFFFFFFFF);

  @override
  double measureTextHeight(String text) => scaledCharHeight;

  @override
  double measureTextWidth(String text) {
    final n = text.length;
    return n > 0 ? scaledCharWidth * n + letterSpacing * (n - 1) : 0;
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

class GlyphData {
  const GlyphData({
    required this.left,
    required this.top,
    this.right,
    this.bottom,
  });

  const GlyphData.fromLTWH(this.left, this.top, double width, double height)
      : right = left + width,
        bottom = top + height;

  const GlyphData.fromLTRB(this.left, this.top, this.right, this.bottom);

  final double left;
  final double top;
  final double? right;
  final double? bottom;
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
  double height = 0;
}
