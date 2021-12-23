import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../game.dart';
import '../../collision/collision_item.dart';
import '../../geometry/rectangle.dart';

/// The [CollidableType] is used to determine which other type of [Collidable]s
/// that your component should collide with.
enum CollidableType {
  /// Collides with other [Collidable]s of type active or passive.
  active,

  /// Collides with other [Collidable]s of type active.
  passive,

  /// Will not collide with any other [Collidable]s.
  inactive,
}

mixin Collidable on HasHitboxes implements CollisionItem<Collidable> {
  // TODO(spydon): Too expensive to have a set in each item?
  final Set<Collidable> activeCollisions = {};

  @override
  Aabb2 get aabb => super.aabb;

  @override
  CollidableType collidableType = CollidableType.active;

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {}

  @override
  @mustCallSuper
  void onCollisionStart(Set<Vector2> intersectionPoints, Collidable other) {
    activeCollisions.add(other);
  }

  @override
  @mustCallSuper
  void onCollisionEnd(Collidable other) {
    activeCollisions.remove(other);
  }

  @override
  void onRemove() {
    final parentGame = findGame()! as HasCollidables;
    parentGame.collisionDetection.remove(this);
    super.onRemove();
  }

  // TODO(spydon): remove?
  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    final game = findGame()!;
    assert(
      game is HasCollidables,
      'You can only use the HasHitboxes/Collidable feature with games that '
      'has the HasCollidables mixin',
    );
  }
}

class ScreenCollidable<T extends FlameGame> extends PositionComponent
    with HasHitboxes, Collidable, HasGameRef<T> {
  @override
  CollidableType collidableType = CollidableType.passive;

  @override
  Future<void> onLoad() async {
    size = gameRef.size;
    addHitbox(HitboxRectangle());
  }

  final _zeroVector = Vector2.zero();
  @override
  void update(double dt) {
    position = gameRef.camera.unprojectVector(_zeroVector);
    size = gameRef.size;
  }
}
