import 'package:flame/src/text/common/line_metrics.dart';
import 'package:flame/src/text/elements/text_element.dart';

/// [TextLine] is an abstract class describing a single line (or a fragment of
/// a line) of a laid-out text.
///
/// More specifically, after any [TextElement] has been laid out, its layout
/// will be described by one or more [TextLine]s.
abstract class TextLine {
  /// The dimensions of this line.
  LineMetrics get metrics;

  /// Move the text within this [TextLine] by the specified offsets [dx], [dy].
  void translate(double dx, double dy);
}
