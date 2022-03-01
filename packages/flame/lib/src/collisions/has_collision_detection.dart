import '../../collisions.dart';
import '../../game.dart';

/// Keeps track of all the [HitboxShape]s in the component tree and initiates
/// collision detection every tick.
mixin HasCollisionDetection on FlameGame {
  CollisionDetection<Hitbox> _collisionDetection = StandardCollisionDetection();
  CollisionDetection<Hitbox> get collisionDetection => _collisionDetection;

  set collisionDetection(CollisionDetection<Hitbox> cd) {
    cd.addAll(_collisionDetection.items);
    _collisionDetection = cd;
  }

  @override
  void update(double dt) {
    super.update(dt);
    collisionDetection.run();
  }
}
