/// Dimensions of a single line of text.
class LineMetrics {
  LineMetrics({
    required this.baseline,
    required this.left,
    double? right,
    double? top,
    double? bottom,
  })  : right = right ?? left,
        top = top ?? baseline,
        bottom = bottom ?? baseline;

  double left;
  double right;
  double top;
  double bottom;
  double baseline;

  double get width => right - left;
  double get height => bottom - top;
}
