import 'package:flame/collisions.dart' as flame;
import 'package:flame/components.dart' as flame;
import 'package:flame_studio/component_editor/widgets/preview/dashed_outline.dart';
import 'package:flutter/painting.dart';

/// {@template preview_hitbox}
/// A Flame hitbox in the preview.
///
/// Hitboxes draw nothing themselves, so the preview outlines them with an
/// orange dashed line, hidden with [isVisible] when the user hides the
/// hitboxes. The outline only exists in the preview: the generated code
/// uses Flame's hitboxes.
///
/// The preview game has no collision detection, so these hitboxes never
/// collide.
/// {@endtemplate}
mixin PreviewHitbox on flame.PositionComponent, flame.HasVisibility {
  /// The color of the outline.
  static const color = Color(0xFFFF9800);

  /// The paint of the outline.
  static final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
}

/// {@macro preview_hitbox}
class PreviewRectangleHitbox()
    extends flame.RectangleHitbox
    with flame.HasVisibility, PreviewHitbox {
  /// {@macro preview_hitbox}
  ///
  /// It is given a size, otherwise Flame would make it fill its parent.
  this : super(size: flame.Vector2.zero());

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    drawDashedPolygon(canvas, [
      rect.topLeft,
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft,
    ], PreviewHitbox.paint);
  }
}

/// {@macro preview_hitbox}
class PreviewCircleHitbox()
    extends flame.CircleHitbox
    with flame.HasVisibility, PreviewHitbox {
  /// {@macro preview_hitbox}
  ///
  /// It is given a radius, otherwise Flame would make it fill its parent.
  this : super(radius: 0);

  @override
  void render(Canvas canvas) {
    drawDashedCircle(
      canvas,
      (size / 2).toOffset(),
      radius,
      PreviewHitbox.paint,
    );
  }
}

/// {@macro preview_hitbox}
class PreviewPolygonHitbox(super.vertices)
    extends flame.PolygonHitbox
    with flame.HasVisibility, PreviewHitbox {
  /// {@macro preview_hitbox}
  this;

  @override
  void render(Canvas canvas) {
    drawDashedPolygon(canvas, [
      for (final vertex in vertices) vertex.toOffset(),
    ], PreviewHitbox.paint);
  }
}
