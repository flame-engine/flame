import 'dart:ui';

import 'package:flame/src/text/common/glyph_data.dart';
import 'package:flame/src/text/common/sprite_font.dart';
import 'package:flame/src/text/formatter_text_renderer.dart';
import 'package:flame/src/text/formatters/sprite_font_text_formatter.dart';
import 'package:flame/src/text/text_renderer.dart';

/// [TextRenderer] implementation that uses a spritesheet of various font glyphs
/// to render text.
///
/// For example, suppose there is a spritesheet with sprites for characters from
/// A to Z. Mapping these sprites into a [SpriteFontRenderer] allows then to
/// write text using these sprite images as the font.
///
/// Currently, this class supports monospace fonts only -- the widths and the
/// heights of all characters must be the same.
/// Extra space between letters can be added via the `letterSpacing` parameter
/// (it can also be negative to "squish" characters together). Finally, the
/// `scale` parameter allows scaling the font to be bigger/smaller relative to
/// its size in the source image.
///
/// The `paint` parameter is used to composite the character images onto the
/// canvas. Its default value will draw the character images as-is. Changing
/// the opacity of the paint's color will make the text semi-transparent.
class SpriteFontRenderer
    extends FormatterTextRenderer<SpriteFontTextFormatter> {
  @Deprecated('Use SpriteFontRenderer.fromFont() instead; this constructor '
      'will be removed in 1.6.0')
  SpriteFontRenderer({
    required Image source,
    required double charWidth,
    required double charHeight,
    // ignore: deprecated_member_use_from_same_package
    required Map<String, GlyphData> glyphs,
    double scale = 1,
    double letterSpacing = 0,
  }) : super(
          SpriteFontTextFormatter(
            source: source,
            charWidth: charWidth,
            charHeight: charHeight,
            glyphs: glyphs,
            scale: scale,
            letterSpacing: letterSpacing,
          ),
        );

  SpriteFontRenderer.fromFont(
    SpriteFont font, {
    Color? color,
    double scale = 1,
    double letterSpacing = 0,
  }) : super(
          SpriteFontTextFormatter.fromFont(
            font,
            scale: scale,
            letterSpacing: letterSpacing,
            color: color,
          ),
        );
}
