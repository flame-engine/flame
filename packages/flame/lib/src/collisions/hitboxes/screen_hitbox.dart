import '../../../components.dart';
import '../../../game.dart';
import '../collision_callbacks.dart';
import 'rectangle_hitbox.dart';

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
    position = gameRef.camera.unprojectVector(_zeroVector);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}
