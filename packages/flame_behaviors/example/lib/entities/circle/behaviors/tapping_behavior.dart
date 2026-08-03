import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_behaviors_example/entities/entities.dart';

/// This behavior ensures that SpawningBehavior of the game does not spawn
/// anything when we click on a circle (for dragging).
///
/// It does so simply by existing: the tap is delivered to this behavior, and
/// since it does not set `continuePropagation`, it never reaches the game-level
/// SpawningBehavior underneath.
class TappingBehavior extends TappableBehavior<Circle> {
  @override
  void onTapDown(TapDownEvent event) {}
}
