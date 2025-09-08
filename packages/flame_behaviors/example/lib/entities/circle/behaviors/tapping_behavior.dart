import 'package:example/entities/entities.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

/// This behavior ensures that SpawningBehavior of the game does not spawn
/// anything when we click on a circle (for dragging).
class TappingBehavior extends TappableBehavior<Circle> {
  @override
  void onTapDown(TapDownEvent event) {
    event.handled = true;
  }
}
