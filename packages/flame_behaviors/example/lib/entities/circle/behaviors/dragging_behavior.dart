import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_behaviors_example/entities/entities.dart';

class DraggingBehavior extends DraggableBehavior<Circle> {
  MovingBehavior? movement;

  Vector2? originalVelocity;

  @override
  void onMount() {
    movement = parent.findBehavior<MovingBehavior>();
    return super.onMount();
  }

  @override
  void onDragStart(DragStartEvent event) {
    originalVelocity = movement?.velocity.clone();
    movement?.velocity.setFrom(Vector2.zero());
    return super.onDragStart(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    movement?.velocity.setFrom(originalVelocity ?? Vector2.zero());
    return super.onDragCancel(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    movement?.velocity.setFrom(event.velocity);
    return super.onDragEnd(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    parent.position.add(event.localDelta);
  }
}
