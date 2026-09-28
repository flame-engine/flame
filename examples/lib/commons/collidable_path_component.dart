import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

final Paint hitboxStroke = Paint()
  ..color = const Color(0xffffffff)
  ..style = .stroke;

/// A [PathComponent] with a [PathHitbox] that follows its path, so that it
/// collides and reacts to gestures as a whole.
///
/// The hitbox polygons are rendered with the given contour paint when the
/// hitboxes are rendered, which shows how closely they follow the path.
class CollidablePathComponent extends PathComponent with CollisionCallbacks {
  CollidablePathComponent({
    required super.path,
    super.sampling,
    super.tolerance,
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
    super.paint,
    super.paintLayers,
    Paint? contourPaint,
    bool renderHitboxes = false,
    bool filter = true,
  }) : super(filter: filter) {
    hitbox = PathHitbox(
      path: path,
      filter: filter,
      sampling: sampling,
      tolerance: tolerance,
    );
    if (renderHitboxes) {
      hitbox
        ..renderShape = true
        ..paint = contourPaint ?? hitboxStroke;
    }
    add(hitbox);
  }

  late final PathHitbox hitbox;
}
