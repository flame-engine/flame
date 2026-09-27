import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

final Paint hitboxStroke = Paint()
  ..color = const Color(0xffffffff)
  ..style = .stroke;

class CollidablePathComponent extends PathComponent
    with CollisionCallbacks, CollisionPassthrough {
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
    bool? renderHitboxes,
    bool? filter,
  }) : super() {
    final pathHitbox = PathHitbox(
      path: path,
      filter: filter ?? true,
      sampling: sampling,
      tolerance: tolerance,
    );
    add(pathHitbox);
    if (renderHitboxes ?? false) {
      final hitboxPaint = contourPaint ?? hitboxStroke;
      for (final hitbox in pathHitbox.polygonHitboxes) {
        hitbox.renderShape = true;
        hitbox.paint = hitboxPaint;
      }
    }
  }
}
