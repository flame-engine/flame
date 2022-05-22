
import 'package:flame/src/text/inline_text_element.dart';
import 'package:flame/src/text/line_metrics.dart';
import 'package:meta/meta.dart';

/// A single line within an [InlineTextElement].
@internal
abstract class TextLine {
  LineMetrics get metrics;
}
