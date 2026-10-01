import 'package:flame/extensions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class MovingBehavior({required final Vector2 velocity})
    extends Behavior<PositionedEntity> {
  @override
  void update(double dt) {
    parent.position.add(velocity * dt);
  }
}
