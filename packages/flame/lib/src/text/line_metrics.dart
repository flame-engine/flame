/// Dimensions of a single line of text, or partial line.
class LineMetrics {
  LineMetrics({
    required this.left,
    required this.baseline,
    this.width = 0,
    this.ascent = 0,
    double? bottom,
  })  :
        bottom = bottom ?? baseline;

  double left;
  double baseline;
  double ascent;
  double width;
  double bottom;

  double get right => left + width;
  double get top => baseline - ascent;
  double get height => bottom - top;

  @override
  String toString() => 'LineMetrics('
      'left: $left, baseline: $baseline, '
      'width: $width, ascent: $ascent, bottom: $bottom)';
}
