@Deprecated('This class will be removed in 1.6.0; use Glyph instead')
class GlyphData {
  @Deprecated('Will be removed in 1.6.0; use Glyph class instead')
  const GlyphData({
    required this.left,
    required this.top,
    this.right,
    this.bottom,
  });

  @Deprecated('Will be removed in 1.6.0; use Glyph class instead')
  const GlyphData.fromLTWH(this.left, this.top, double width, double height)
      : right = left + width,
        bottom = top + height;

  @Deprecated('Will be removed in 1.6.0; use Glyph class instead')
  const GlyphData.fromLTRB(this.left, this.top, this.right, this.bottom);

  final double left;
  final double top;
  final double? right;
  final double? bottom;
}
