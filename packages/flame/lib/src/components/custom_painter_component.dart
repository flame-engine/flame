import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

/// A [PositionComponent] that renders a [CustomPainter] at the designated
/// position, scaled to have the designated size and rotated to the specified
/// angle.
///
/// This component makes it possible to provide a Flutter [CustomPainter] to
/// render on the canvas.
///
/// Note that given the active rendering nature of a game, `shouldRepaint` is
/// ignored by this component.
class CustomPainterComponent({
  /// The [CustomPainter] used to render this component
  var CustomPainter? painter,
  super.position,
  super.size,
  super.scale,
  super.angle,
  super.anchor,
  super.children,
  super.priority,
}) extends PositionComponent {
  @override
  @mustCallSuper
  void render(Canvas canvas) {
    painter?.paint(canvas, size.toSize());
  }
}
