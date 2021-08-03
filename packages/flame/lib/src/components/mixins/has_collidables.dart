import '../../../game.dart';
import '../../components/mixins/collidable.dart';
import '../../geometry/collision_detection.dart';

mixin HasCollidables on BaseGame {
  void handleCollidables() {
    collisionDetection(components.query<Collidable>());
  }
}
