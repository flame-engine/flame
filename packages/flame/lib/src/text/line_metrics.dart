/// Dimensions of a single line of text.
class LineMetrics {
  LineMetrics({
    required this.baseline,
    required this.left,
    this.width = 0,
    double? top,
    double? bottom,
  })  :
        top = top ?? baseline,
        bottom = bottom ?? baseline;

  double left;
  double width;
  double top;
  double bottom;
  double baseline;

  double get right => left + width;
  double get height => bottom - top;

  @override
  String toString() => 'LineMetrics('
      'left: $left, top: $top, right: $right, bottom: $bottom, '
      'baseline: $baseline)';
}
