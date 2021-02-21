import '../../../game.dart';
import '../../components/mixins/collidable.dart';
import '../../geometry/collision_detection.dart';
import '../component.dart';

mixin HasCollidables on BaseGame {
  final List<Collidable> _collidables = [];

  void handleCollidables(Set<Component> removeLater, List<Component> addLater) {
    removeLater.whereType<Collidable>().forEach((c) {
      _collidables.remove(c);
    });
    _collidables.addAll(addLater.whereType<Collidable>());
    collisionDetection(_collidables);
  }
}
