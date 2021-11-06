import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../game.dart';
import '../../components/position_component.dart';
import '../../extensions/vector2.dart';
import '../../geometry/rectangle.dart';
import 'hitbox.dart';

/// [CollidableType.active] collides with other [Collidable]s of type active or static
/// [CollidableType.passive] collides with other [Collidable]s of type active
/// [CollidableType.inactive] will not collide with any other [Collidable]s
enum CollidableType {
  active,
  passive,
  inactive,
}

mixin Collidable on HasHitboxes {
  CollidableType collidableType = CollidableType.active;

  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {}
  void onCollisionEnd(Collidable other) {}

  @override
  void onRemove() {
    final parentGame = findParent<FlameGame>();
    if (parentGame is HasCollidables) {
      parentGame.collidables.remove(this);
    }
    super.onRemove();
  }

  @override
  @mustCallSuper
  void prepare(Component parent) {
    super.prepare(parent);

    if (isPrepared) {
      final parentGame = findParent<FlameGame>();
      assert(
        parentGame is HasCollidables,
        'You can only use the HasHitboxes/Collidable feature with games that '
        'has the HasCollidables mixin',
      );
    }
  }
}

class ScreenCollidable<T extends FlameGame> extends PositionComponent
    with HasHitboxes, Collidable, HasGameRef<T> {
  @override
  CollidableType collidableType = CollidableType.passive;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = gameRef.size;
    addHitbox(HitboxRectangle());
  }

  final _zeroVector = Vector2.zero();
  @override
  void update(double dt) {
    super.update(dt);
    position = gameRef.camera.unprojectVector(_zeroVector);
    size = gameRef.size;
  }
}
