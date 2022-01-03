import '../../../components.dart';
import '../../../game.dart';
import '../../collision/collision_callbacks.dart';
import '../../geometry/rectangle.dart';

class ScreenCollidable<T extends FlameGame> extends PositionComponent
    with HasHitboxes, HasGameRef<T> {
  @override
  CollidableType collidableType = CollidableType.passive;

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
    size = gameRef.size;
  }
}
