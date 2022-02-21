import '../../components.dart';
import '../../game.dart';
import '../collision_detection/collision_callbacks.dart';
import '../collision_detection/hitboxes/hitbox_rectangle.dart';

/// This component is used to detect hitboxes colliding into the viewport of the
/// game.
class ScreenCollidable<T extends FlameGame> extends PositionComponent
    with CollisionCallbacks, HasGameRef<T> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = gameRef.size;
    add(HitboxRectangle());
  }

  final _zeroVector = Vector2.zero();
  @override
  void update(double dt) {
    super.update(dt);
    position = gameRef.camera.unprojectVector(_zeroVector);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}
