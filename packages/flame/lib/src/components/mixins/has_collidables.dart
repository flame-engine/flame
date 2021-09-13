import '../../../game.dart';
import '../../components/mixins/collidable.dart';
import '../../geometry/collision_detection.dart';

mixin HasCollidables on BaseGame {
  @override
  Future<void>? onLoad() {
    children.register<Collidable>();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    handleCollidables();
  }

  void handleCollidables() {
    collisionDetection(children.query<Collidable>());
  }
}
