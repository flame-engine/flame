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
