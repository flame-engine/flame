import 'package:flame/src/text/common/sprite_font.dart';
import 'package:meta/meta.dart';

/// [Glyph] describes a single character/icon comprising a [SpriteFont].
///
/// The properties [left], [top], [right] and [bottom] describe the rectangle
/// within the source image where the character's image is located. This part
/// of the image will end up being copied onto the canvas whenever the
/// corresponding character needs to be printed. The [right] and [bottom] need
/// not be specified if all characters in the sprite font will have the same
/// width and/or height.
///
/// The [ascent] property measures the distance from the character's [top] to
/// its baseline. This property can be omitted on a per-character level if it
/// will be the same across all characters.
///
/// The properties [paddingLeft], [paddingRight], [paddingTop] and
/// [paddingBottom] describe the distances between the character's "physical"
/// and "logical" boxes.
@immutable
class Glyph {
  const Glyph({
    required this.left,
    required this.top,
    this.right,
    this.bottom,
    this.ascent,
    this.paddingLeft = 0,
    this.paddingRight = 0,
    this.paddingTop = 0,
    this.paddingBottom = 0,
  });

  const Glyph.fromLTWH(this.left, this.top, double width, double height)
      : right = left + width,
        bottom = top + height,
        ascent = null,
        paddingLeft = 0,
        paddingTop = 0,
        paddingRight = 0,
        paddingBottom = 0;

  const Glyph.fromLTRB(this.left, this.top, this.right, this.bottom)
      : ascent = null,
        paddingLeft = 0,
        paddingTop = 0,
        paddingRight = 0,
        paddingBottom = 0;

  final double left;
  final double top;
  final double? right;
  final double? bottom;
  final double? ascent;
  final double paddingLeft;
  final double paddingRight;
  final double paddingTop;
  final double paddingBottom;
}
