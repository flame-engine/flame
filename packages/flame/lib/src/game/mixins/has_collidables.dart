import '../../../components.dart';
import '../../../game.dart';
import '../../geometry/collision_detection.dart';

/// Keeps track of all the [Collidable]s in the component tree and initiates
/// collision detection every tick.
mixin HasCollidables on FlameGame {
  final List<Collidable> collidables = [];

  @override
  void update(double dt) {
    super.update(dt);
    handleCollidables();
  }

  void handleCollidables() {
    collisionDetection(collidables);
  }
}
