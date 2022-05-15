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
class CustomPainterComponent extends PositionComponent {
  /// The [CustomPainter] used to render this component
  CustomPainter? painter;

  CustomPainterComponent({
    this.painter,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
  }) : super(
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          children: children,
          priority: priority,
        );

  @override
  @mustCallSuper
  void render(Canvas canvas) {
    painter?.paint(canvas, size.toSize());
  }
}
