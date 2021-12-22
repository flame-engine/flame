import '../../../components.dart';
import '../../../game.dart';
import '../../collision/collision_detection.dart';

/// Keeps track of all the [Collidable]s in the component tree and initiates
/// collision detection every tick.
mixin HasCollidables on FlameGame {
  CollisionDetection<Collidable> _collisionDetection =
      CollidableCollisionDetection();
  CollisionDetection<Collidable> get collisionDetection => _collisionDetection;

  set collisionDetection(CollisionDetection<Collidable> cd) {
    cd.addAll(_collisionDetection.items);
    _collisionDetection = cd;
  }

  @override
  void update(double dt) {
    super.update(dt);
    collisionDetection.run();
  }
}
