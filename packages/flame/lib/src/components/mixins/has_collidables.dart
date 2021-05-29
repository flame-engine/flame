import 'package:ordered_set/queryable_ordered_set.dart';

import '../../../game.dart';
import '../../components/mixins/collidable.dart';
import '../../geometry/collision_detection.dart';

mixin HasCollidables on BaseGame {
  void handleCollidables() {
    final qos = components as QueryableOrderedSet;
    collisionDetection(qos.query<Collidable>());
  }
}
