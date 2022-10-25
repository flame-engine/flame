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
    List<Paint>? paintLayers,
  }) {
    this.paint = paint ?? this.paint;
    // Only read from this.paintLayers if paintLayers not null to prevent
    // unnecessary creation of the paintLayers list.
    if (paintLayers != null) {
      this.paintLayers = paintLayers;
    }
  }

  bool renderShape = true;

  /// Whether the shape is solid or hollow.
  ///
  /// If it is solid, intersections will occur even if the other component is
  /// fully enclosed by the other hitbox. The intersection point in such cases
  /// will be the center of the enclosed [ShapeComponent].
  /// A hollow shape that is fully enclosed by a solid hitbox will cause an
  /// intersection result, but not the other way around.
  ///
  /// This field is not related to how the shape should be rendered, see
  /// [Paint.style] for that.
  bool isSolid = false;
}
