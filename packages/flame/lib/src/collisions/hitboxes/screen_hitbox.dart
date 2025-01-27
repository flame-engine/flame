import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/collisions/collision_callbacks.dart';
import 'package:flame/src/collisions/hitboxes/rectangle_hitbox.dart';

/// This component is used to detect hitboxes colliding into the edges of the
/// viewport of the game.
class ScreenHitbox<T extends FlameGame> extends PositionedComponent with CollisionCallbacks, HasGameReference<T> {
  bool _hasWorldAncestor = false;
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    _hasWorldAncestor = findParent<World>() != null;
    if (_hasWorldAncestor) {
      game.camera.viewfinder.transform.addListener(_updateTransform);
      _updateTransform();
    }
  }

  final Vector2 _tmpPosition = Vector2.zero();

  void _updateTransform() {
    final viewfinder = game.camera.viewfinder;
    final visibleRect = game.camera.visibleWorldRect;
    size.setValues(visibleRect.width, visibleRect.height);
    _tmpPosition.setValues(visibleRect.topLeft.dx, visibleRect.topLeft.dy);
    position = Anchor.topLeft.toOtherAnchorPosition(
      _tmpPosition,
      viewfinder.anchor,
      size,
    );
    anchor = viewfinder.anchor;
    angle = viewfinder.angle;
    if (angle != 0) {
      final cosTheta = cos(angle).abs();
      final sinTheta = sin(angle).abs();
      final newWidth = (size.x * cosTheta) + (size.y * sinTheta);
      final newHeight = (size.x * sinTheta) + (size.y * cosTheta);

      // Shrink the new dimensions to keep the original AABB size before the
      // rotation.
      final scaleWidth = size.x / newWidth;
      final scaleHeight = size.y / newHeight;

      size.setValues(newWidth * scaleWidth, newHeight * scaleHeight);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    if (_hasWorldAncestor) {
      _updateTransform();
    }
  }
}
