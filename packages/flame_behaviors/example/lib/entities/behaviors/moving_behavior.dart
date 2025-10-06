import 'package:flame/extensions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class MovingBehavior extends Behavior<PositionedEntity> {
  MovingBehavior({required this.velocity});

  final Vector2 velocity;

  @override
  void update(double dt) {
    parent.position.add(velocity * dt);
  }
}
