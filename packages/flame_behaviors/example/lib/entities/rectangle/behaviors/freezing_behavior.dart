import 'package:example/entities/entities.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class FreezingBehavior extends TappableBehavior<Rectangle> {
  MovingBehavior? movement;

  Vector2? originalVelocity;

  @override
  void onMount() {
    movement = parent.findBehavior<MovingBehavior>();
    return super.onMount();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (movement?.velocity.isZero() ?? false) {
      movement?.velocity.setFrom(originalVelocity ?? Vector2.zero());
    } else {
      originalVelocity = movement?.velocity.clone();
      movement?.velocity.setFrom(Vector2.zero());
    }
    event.handled = true;
  }
}
