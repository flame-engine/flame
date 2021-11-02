import 'package:flutter/widgets.dart';

import '../extensions/vector2.dart';
import 'position_component.dart';

/// A [PositionComponent] that renders a [CustomPainter] at the designated
/// position, scaled to have the designated size and rotated to the specified
/// angle.
///
/// This component is usefull to [CustomPainter]s between your Flutter UI and Flame game.
class CustomPainterComponent extends PositionComponent {
  /// The [CustomPainter] used to render this component
  CustomPainter? painter;

  CustomPainterComponent({
    Vector2? position,
    Vector2? size,
    int? priority,
    this.painter,
  }) : super(
          position: position,
          size: size,
          priority: priority,
        );

  @override
  @mustCallSuper
  void render(Canvas canvas) {
    super.render(canvas);

    painter?.paint(canvas, size.toSize());
  }
}
