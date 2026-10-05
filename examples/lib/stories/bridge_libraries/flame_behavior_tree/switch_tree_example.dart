import 'package:examples/stories/bridge_libraries/flame_behavior_tree/common.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

class SwitchTreeExample() extends BehaviorTreeGame {
  this : super(height: 300);

  static const String description = '''
    A component can switch to a different behavior tree at any time by
    assigning to `behaviorTree`. The running nodes of the old tree are aborted,
    which here stops the effects that they started.

    The agent patrols between two points. Tap it to make it sleep instead, and
    tap it again to wake it up. Notice that the patrol stops right where it is
    when the agent falls asleep, and starts over from there when it wakes up.

    The same abort happens when a component with a tree is removed from the
    game.
  ''';

  @override
  void onLoad() {
    final agent = _Agent();
    world.addAll([
      caption(
        'Tap the agent to switch its behavior.',
        position: Vector2(12, 12),
      ),
      agent,
      TreeView(agent, position: Vector2(12, 200)),
    ]);
  }
}

class _Agent() extends CircleComponent with HasBehaviorTree, TapCallbacks {
  this
    : super(
        radius: 14,
        position: Vector2(60, 150),
        anchor: Anchor.center,
        paint: Paint()..color = Colors.cyan,
      );

  late final BehaviorTree _patrol;
  late final BehaviorTree _sleep;

  @override
  void onLoad() {
    _patrol = BehaviorTree(
      Repeat(
        Sequence([
          MoveTo((context) => Vector2(exampleWidth - 60, 150), duration: 2.5),
          MoveTo((context) => Vector2(60, 150), duration: 2.5),
        ]),
      ),
      owner: this,
    );
    _sleep = BehaviorTree(
      Repeat(
        PlayEffect(
          (context) => ColorEffect(
            Colors.indigo,
            EffectController(duration: 1, alternate: true),
            opacityTo: 0.8,
          ),
        ),
      ),
      owner: this,
    );
    behaviorTree = _patrol;
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Assigning a tree aborts the one that was running before.
    behaviorTree = behaviorTree == _patrol ? _sleep : _patrol;
  }
}
