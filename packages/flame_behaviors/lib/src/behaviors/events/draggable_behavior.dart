import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

/// {@template draggable_behavior}
/// A behavior that makes an [Entity] draggable.
/// {@endtemplate}
abstract class DraggableBehavior<Parent extends EntityMixin>
    extends Behavior<Parent>
    with DragCallbacks {
  /// {@macro draggable_behavior}
  DraggableBehavior({
    super.children,
    super.priority,
    super.key,
  });
}
