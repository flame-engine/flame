import 'dart:ui';

import 'package:flame/src/anchor.dart';
import 'package:flame/src/text/common/glyph_data.dart';
import 'package:flame/src/text/formatters/sprite_font_text_formatter.dart';
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
    required Image source,
    required double charWidth,
    required double charHeight,
    required Map<String, GlyphData> glyphs,
    double scale = 1,
    double letterSpacing = 0,
  }) : formatter = SpriteFontTextFormatter(
          source: source,
          charWidth: charWidth,
          charHeight: charHeight,
          glyphs: glyphs,
          scale: scale,
          letterSpacing: letterSpacing,
        );

  final SpriteFontTextFormatter formatter;

  @override
  Vector2 measureText(String text) {
    final box = formatter.format(text).metrics;
    return Vector2(box.width, box.height);
  }

  @override
  void render(
    Canvas canvas,
    String text,
    Vector2 position, {
    Anchor anchor = Anchor.topLeft,
  }) {
    final txt = formatter.format(text);
    txt.translate(
      position.x - txt.metrics.width * anchor.x,
      position.y - txt.metrics.height * anchor.y - txt.metrics.top,
    );
    txt.render(canvas);
  }
}
