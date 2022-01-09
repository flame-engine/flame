import '../../../collision_detection.dart';
import '../../../components.dart';
import '../../../game.dart';

/// Keeps track of all the [HitboxShape]s in the component tree and initiates
/// collision detection every tick.
mixin HasCollisionDetection on FlameGame {
  CollisionDetection<HasHitboxes> _collisionDetection =
      StandardCollisionDetection();
  CollisionDetection<HasHitboxes> get collisionDetection => _collisionDetection;

  set collisionDetection(CollisionDetection<HasHitboxes> cd) {
    cd.addAll(_collisionDetection.items);
    _collisionDetection = cd;
  }

  @override
  void update(double dt) {
    super.update(dt);
    collisionDetection.run();
  }
}
