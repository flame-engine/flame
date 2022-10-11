import 'package:flame/src/text/common/glyph_data.dart';
import 'package:flame/src/text/common/sprite_font.dart';
import 'package:meta/meta.dart';

/// [Glyph] describes a single character/ligature/icon within a [SpriteFont].
///
/// A glyph has an associated "glyph box", which is the box where the glyph is
/// logically located. Here "logically" means that it includes not only the
/// character itself, but also some padding around it as necessary for the
/// character to look nice within the text. For all glyphs in a font, their
/// boxes will have the same height (which is the font size), the same ascent
/// and descent, but possibly different widths.
///
/// The properties [left], [top], [width] and [height] describe the location of
/// the glyph box within the source image.
///
/// In addition to the logical "glyph box", a glyph may also have a "source
/// box", which describes a rectangle within the source image where the glyph's
/// pixels are actually located. The source box may be larger or smaller than
/// the glyph box. It will be larger if the glyph has a particularly large
/// flourish that trespasses upon other characters' space; or smaller if the
/// characters are packed too tightly in the source image, or if you're trying
/// to improve rendering performance by not copying empty pixels.
class Glyph {
  Glyph(
    this.char, {
    required this.left,
    required this.top,
    double? width,
    double? height,
    double? srcLeft,
    double? srcTop,
    double? srcRight,
    double? srcBottom,
  })  : assert((width ?? 0) >= 0, 'The `width` parameter cannot be negative'),
        assert((height ?? 0) >= 0, 'The `height` parameter cannot be negative'),
        assert(
          (srcLeft == null &&
                  srcTop == null &&
                  srcRight == null &&
                  srcBottom == null) ||
              (srcLeft != null &&
                  srcTop != null &&
                  srcRight != null &&
                  srcBottom != null),
          'Either all or none of parameters `srcLeft`, `srcTop`, `srcRight` '
          'and `srcBottom` must be specified',
        ),
        width = width ?? -1,
        height = height ?? -1,
        srcLeft = srcLeft ?? -1,
        srcTop = srcTop ?? -1,
        srcRight = srcRight ?? -1,
        srcBottom = srcBottom ?? -1;

  // ignore: deprecated_member_use_from_same_package
  Glyph.fromGlyphData(this.char, GlyphData data)
      : left = data.left,
        top = data.top,
        width = data.right == null ? -1 : data.right! - data.left,
        height = data.bottom == null ? -1 : data.bottom! - data.top,
        srcLeft = -1,
        srcTop = -1,
        srcRight = -1,
        srcBottom = -1;

  final String char;
  final double left;
  final double top;
  double width;
  double height;
  double srcLeft;
  double srcTop;
  double srcRight;
  double srcBottom;

  @internal
  void initialize(double defaultCharWidth, double charHeight) {
    if (width < 0) {
      width = defaultCharWidth;
    }
    if (height < 0) {
      height = charHeight;
    } else {
      assert(
        height == charHeight,
        'The height of all glyphs must be the same and equal to the font size',
      );
    }
    if (srcLeft < 0) {
      srcLeft = left;
      srcTop = top;
      srcRight = left + width;
      srcBottom = top + height;
    }
  }

  @override
  String toString() {
    return 'Glyph(char="$char", '
        'LTWH=[$left, $top, $width, $height], '
        'srcLTRB=[$srcLeft, $srcTop, $srcRight, $srcBottom])';
  }
}
