/// [LineMetrics] represents dimensions of a single line of text, or a fragment
/// of a line.
///
/// A line of text can be thought of as surrounded by a box (rect) that outlines
/// the boundaries of the text, plus there is a [baseline] inside the box which
/// is the line on top of which the text is placed.
///
/// The [LineMetrics] box surrounding a piece of text is not necessarily tight:
/// there's usually some amount of space above and below to improve legibility
/// of multi-line text.
class LineMetrics {
  LineMetrics({
    required this.left,
    required this.baseline,
    this.width = 0,
    this.ascent = 0,
    this.descent = 0,
  });

  /// X-coordinate of the left edge of the box.
  double left;

  /// Y-coordinate of the baseline of the box. When several line fragments are
  /// placed next to each other, their baselines will match.
  double baseline;

  /// The total width of the box.
  double width;

  /// The distance from the baseline to the top of the box.
  double ascent;

  /// The distance from the baseline to the bottom of the box.
  double descent;

  double get right => left + width;
  double get top => baseline - ascent;
  double get bottom => baseline + descent;
  double get height => ascent + descent;

  /// Appends another [LineMetrics] box that is adjacent to the current and on
  /// the same baseline. The current object will be modified to encompass the
  /// [other] box.
  void append(LineMetrics other) {
    assert(right == other.left);
    assert(baseline == other.baseline);
    width += other.width;
    if (ascent < other.ascent) {
      ascent = other.ascent;
    }
    if (descent < other.descent) {
      descent = other.descent;
    }
  }

  @override
  String toString() => 'LineMetrics('
      'left: $left, baseline: $baseline, '
      'width: $width, ascent: $ascent, descent: $descent)';
}
