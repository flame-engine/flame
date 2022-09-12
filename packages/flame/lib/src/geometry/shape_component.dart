import 'dart:ui';

import 'package:flame/components.dart';

/// A shape can represent any geometrical shape with optionally a size, position
/// and angle. It can also have an anchor if it shouldn't be rotated around its
/// center.
/// A point can be determined to be within of outside of a shape.
abstract class ShapeComponent extends PositionComponent with HasPaint {
  ShapeComponent({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    Paint? paint,
  }) {
    this.paint = paint ?? this.paint;
  }

  bool renderShape = true;

  /// Whether the shape should be regarded as solid in regards to
  /// intersections.
  ///
  /// This field is not related to how the shape should be rendered, see
  /// [Paint.style] for that.
  bool isSolid = false;
}
