import 'dart:ui';

/// The [LineMetrics] object contains measurements of a text line.
///
/// A line of text can be thought of as surrounded by a box (rect) that outlines
/// the boundaries of the text, plus there is a [baseline] inside the box which
/// is the line on top of which the text is placed.
///
/// The [LineMetrics] box surrounding a piece of text is not necessarily tight:
/// there's usually some amount of space above and below the text glyphs to
/// improve legibility of multi-line text.
class LineMetrics {
  LineMetrics({
    double left = 0,
    double baseline = 0,
    double width = 0,
    double? ascent,
    double? descent,
    double? height,
  })  : _left = left,
        _baseline = baseline,
        _width = width,
        _ascent = ascent ?? (height == null ? 0 : height - (descent ?? 0)),
        _descent =
            descent ?? (height == null ? 0 : height - (ascent ?? height));

  /// X-coordinate of the left edge of the box.
  double get left => _left;
  double _left;

  /// Y-coordinate of the baseline of the box. When several line fragments are
  /// placed next to each other, their baselines will match.
  double get baseline => _baseline;
  double _baseline;

  /// The total width of the box.
  double get width => _width;
  double _width;

  /// The distance from the baseline to the top of the box.
  double get ascent => _ascent;
  double _ascent;

  /// The distance from the baseline to the bottom of the box.
  double get descent => _descent;
  double _descent;

  double get right => left + width;
  double get top => baseline - ascent;
  double get bottom => baseline + descent;
  double get height => ascent + descent;

  /// Moves the [LineMetrics] box by the specified offset [dx], [dy] leaving its
  /// width and height unmodified.
  void translate(double dx, double dy) {
    _left += dx;
    _baseline += dy;
  }

  /// Moves this [LineMetrics] box to the origin, setting [left] and [baseline]
  /// to 0.
  void moveToOrigin() {
    _left = 0;
    _baseline = 0;
  }

  /// Sets the position of the left edge of this [LineMetrics] box, leaving the
  /// [right] edge in place.
  void setLeftEdge(double x) {
    _width = right - x;
    _left = x;
  }

  /// Appends another [LineMetrics] box that is adjacent to the current and on
  /// the same baseline. The current object will be modified to encompass the
  /// [other] box.
  void append(LineMetrics other) {
    assert(
      baseline == other.baseline,
      'Baselines do not match: $baseline vs ${other.baseline}',
    );
    _width = other.right - left;
    if (_ascent < other.ascent) {
      _ascent = other.ascent;
    }
    if (_descent < other.descent) {
      _descent = other.descent;
    }
  }

  Rect toRect() => Rect.fromLTWH(left, top, width, height);

  @override
  String toString() => 'LineMetrics(left: $left, baseline: $baseline, '
      'width: $width, ascent: $ascent, descent: $descent)';
}
