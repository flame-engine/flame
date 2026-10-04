import 'package:examples/stories/bridge_libraries/flame_behavior_tree/common.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

/// Where the agent should go, or not set if it has nowhere to go.
const _destination = BlackboardKey<Vector2>('destination');

class BasicExample() extends BehaviorTreeGame {
  this : super(height: 300);

  static const String description = '''
    This is the smallest useful behavior tree. The agent is a component with
    the `HasBehaviorTree` mixin, and the tree says: "if there is somewhere to
    go, go there, otherwise pulse yellow".

    Tap anywhere to send the agent there. Tapping while it is already moving
    makes it change its mind straight away.

    The tap puts the destination on the blackboard, which is how the game talks
    to the tree. The nodes in the tree read it from there.
  ''';

  @override
  void onLoad() {
    final agent = _Agent();
    world.addAll([
      TapArea(
        size: Vector2(exampleWidth, 300),
        onTap: (position) {
          agent.blackboard.set(_destination, position);
          // The agent might be in the middle of a trip to an older
          // destination. Aborting the tree makes it start over, and the
          // `MoveTo` below reads the new destination again.
          agent.behaviorTree.abort();
        },
      ),
      caption(
        'Tap anywhere to send the agent there.',
        position: Vector2(12, 12),
      ),
      agent,
    ]);
  }
}

class _Agent() extends CircleComponent with HasBehaviorTree {
  this
    : super(
        radius: 12,
        position: Vector2(exampleWidth / 2, 150),
        anchor: Anchor.center,
        paint: Paint()..color = Colors.cyan,
      );

  @override
  void onLoad() {
    behaviorTree = BehaviorTree(
      // A selector tries its children in order until one does not fail. It is
      // reactive, so that it re-checks the first child on every tick and stops
      // pulsing as soon as there is a destination.
      Selector(reactive: true, [
        // A sequence runs its children in order until one does not succeed.
        Sequence([
          Condition((context) => context.blackboard.has(_destination)),
          MoveTo((context) => context.get(_destination), speed: 120),
          Task((context) {
            context.blackboard.remove(_destination);
            return Status.success;
          }),
        ]),
        // Nowhere to go, so pulse. `PlayEffect` is done when the effect is.
        PlayEffect(
          (context) => ColorEffect(
            Colors.yellow,
            EffectController(duration: 0.5, alternate: true),
          ),
        ),
      ]),
      owner: this,
    );
  }
}
