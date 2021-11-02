import 'package:flutter/widgets.dart';

import '../extensions/vector2.dart';
import 'position_component.dart';

/// A [PositionComponent] that renders a [CustomPainter] at the designated
/// position, scaled to have the designated size and rotated to the specified
/// angle.
///
/// This component is usefull to [CustomPainter]s between your Flutter UI and Flame game.
///
/// Note that given the active rendering nature of a game, `shouldRepaint` is ignored by
/// this component.
class CustomPainterComponent extends PositionComponent {
  /// The [CustomPainter] used to render this component
  CustomPainter? painter;

  CustomPainterComponent({
    this.painter,
    Vector2? position,
    Vector2? size,
    int? priority,
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
