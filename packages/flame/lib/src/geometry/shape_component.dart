import 'dart:ui';

import '../../components.dart';

/// A shape can represent any geometrical shape with optionally a size, position
/// and angle. It can also have an anchor if it shouldn't be rotated around its
/// center.
/// A point can be determined to be within of outside of a shape.
abstract class ShapeComponent extends PositionComponent with HasPaint {
  bool renderShape = true;

  ShapeComponent({
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
    Paint? paint,
  }) : super(
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {
    this.paint = paint ?? this.paint;
  }
}
