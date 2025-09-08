import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

/// {@template tappable_behavior}
/// A behavior that makes an [Entity] tappable.
/// {@endtemplate}
abstract class TappableBehavior<Parent extends EntityMixin>
    extends Behavior<Parent>
    with TapCallbacks {
  /// {@macro tappable_behavior}
  TappableBehavior({
    super.children,
    super.priority,
    super.key,
  });
}
