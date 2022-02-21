import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../game.dart';
import '../../geometry/collision_detection.dart';
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

mixin Collidable on HasHitboxes {
  CollidableType collidableType = CollidableType.active;

  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {}
  void onCollisionStart(Set<Vector2> intersectionPoints, Collidable other) {}
  void onCollisionEnd(Collidable other) {}

  @override
  void onRemove() {
    final parentGame = findGame()! as HasCollidables;
    final collidables = parentGame.collidables;
    handleRemovedCollidable(this, collidables);
    parentGame.collidables.remove(this);
    super.onRemove();
  }

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
    (game as HasCollidables).collidables.add(this);
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
