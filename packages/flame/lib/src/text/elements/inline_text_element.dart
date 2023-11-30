import 'package:flame/extensions.dart';
import 'package:flame/src/anchor.dart';
import 'package:flame/text.dart';

/// [InlineTextElement] is the base class that represents a single line of text,
/// laid out and prepared for rendering.
abstract class InlineTextElement extends TextElement {
  /// The dimensions of this line.
  LineMetrics get metrics;

  void render(
    Canvas canvas,
    Vector2 position, {
    Anchor anchor = Anchor.topLeft,
  }) {
    final box = metrics;
    translate(
      position.x - box.width * anchor.x,
      position.y - box.height * anchor.y - box.top,
    );
    draw(canvas);
  }
}
