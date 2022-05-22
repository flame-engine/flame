
/// Dimensions of a single line of text.
class LineMetrics {
  LineMetrics({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.baseline,
  });

  final double left;
  final double right;
  final double top;
  final double bottom;
  final double baseline;

  double get width => right - left;
  double get height => bottom - top;
}
