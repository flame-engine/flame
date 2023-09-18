import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/collisions/collision_callbacks.dart';
import 'package:flame/src/collisions/hitboxes/rectangle_hitbox.dart';

/// This component is used to detect hitboxes colliding into the edges of the
/// viewport of the game.
class ScreenHitbox<T extends FlameGame> extends PositionComponent
    with CollisionCallbacks, HasGameRef<T> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = gameRef.size;
    add(RectangleHitbox());
  }

  final _zeroVector = Vector2.zero();
  @override
  void update(double dt) {
    super.update(dt);
    // TODO(Lukas): Pass in a CameraComponent and use the position of the
    // viewfinder, or only allow this to be attached to a viewport.
    // ignore: deprecated_member_use_from_same_package
    position = gameRef.oldCamera.unprojectVector(_zeroVector);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }
}
