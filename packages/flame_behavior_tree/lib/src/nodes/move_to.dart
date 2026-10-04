import 'package:behavior_tree/behavior_tree.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behavior_tree/src/nodes/play_effect.dart';
import 'package:flutter/animation.dart';

/// A leaf node that moves a component to a position and succeeds once it
/// arrives.
///
/// [destination] is evaluated every time the node starts, so it can depend on
/// the blackboard or on the current state of the game. The trip takes either a
/// fixed [duration] in seconds, or is made at a constant [speed] in pixels per
/// second; exactly one of them has to be given. The [curve] is only used with a
/// [duration].
///
/// ```dart
/// MoveTo((context) => context.get(targetPosition), speed: 80)
/// ```
///
/// The movement is a [MoveEffect] added to the target, see [PlayEffect]. It
/// stops where it is if the node gets aborted.
class MoveTo(
  /// Returns the position to move to, in the coordinates of the [target]'s
  /// parent.
  final Vector2 Function(TickContext context) destination, {

  /// How long the movement takes, in seconds.
  final double? duration,

  /// How fast the movement is, in pixels per second.
  final double? speed,

  /// The curve of the movement, for movements with a [duration].
  final Curve curve = Curves.linear,

  /// The component to move. Defaults to the owner of the behavior tree, which
  /// has to be a [PositionComponent] in that case.
  PositionComponent? target,
}) extends PlayEffect {
  this
    : assert(
        (duration == null) != (speed == null),
        'Either duration or speed must be given, but not both.',
      ),
      super(
        (context) => MoveEffect.to(
          destination(context),
          speed != null
              ? EffectController(speed: speed)
              : EffectController(duration: duration, curve: curve),
        ),
        target: target,
      );
}
