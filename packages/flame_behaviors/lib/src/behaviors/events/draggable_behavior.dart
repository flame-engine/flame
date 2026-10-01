import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

/// {@template draggable_behavior}
/// A behavior that makes an [Entity] draggable.
/// {@endtemplate}
abstract class DraggableBehavior<Parent extends EntityMixin>({
  super.children,
  super.priority,
  super.key,
}) extends Behavior<Parent> with DragCallbacks;
