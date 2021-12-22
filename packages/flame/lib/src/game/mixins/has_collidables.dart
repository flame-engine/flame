import '../../../components.dart';
import '../../../game.dart';
import '../../collision/collision_detection.dart';

/// Keeps track of all the [Collidable]s in the component tree and initiates
/// collision detection every tick.
mixin HasCollidables on FlameGame {
  final CollisionDetection collisionDetection = CollisionDetection();

  @override
  void update(double dt) {
    super.update(dt);
    collisionDetection.run();
  }
}
