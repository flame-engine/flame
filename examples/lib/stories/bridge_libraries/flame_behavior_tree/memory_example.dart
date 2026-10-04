import 'package:examples/stories/bridge_libraries/flame_behavior_tree/common.dart';
import 'package:flame/components.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';

const _isSafe = BlackboardKey<bool>('isSafe', initial: true);

class MemoryExample() extends BehaviorTreeGame {
  this : super(height: 250);

  static const String description = '''
    A `Sequence` has two ways of dealing with a child that is still running.

    By default it has memory: the next tick continues with the running child
    and does not look at the earlier children again. With `reactive: true` it
    starts from the first child on every tick, so it notices when an earlier
    child, like a condition, stops succeeding. The running child is then
    aborted, which here stops the agent in its tracks.

    Both agents walk along their track as long as it is safe. Tap to toggle
    between safe and dangerous, and see which one reacts.
  ''';

  late final TextComponent _state;
  late final List<TreeLane> _lanes;
  var _safe = true;

  @override
  void onLoad() {
    _state = caption('', position: Vector2(12, 12));
    _lanes = [
      _lane(
        title: 'Sequence([...])',
        explanation: 'Remembers the running child, ignores the danger.',
        reactive: false,
      ),
      _lane(
        title: 'Sequence([...], reactive: true)',
        explanation: 'Checks the condition again on every tick.',
        reactive: true,
      ),
    ];
    world.add(
      TapArea(
        size: Vector2(exampleWidth, 250),
        onTap: (_) {
          _safe = !_safe;
          for (final lane in _lanes) {
            lane.blackboard.set(_isSafe, _safe);
          }
          _updateText();
        },
      ),
    );
    world.add(_state);
    addLanes(world, _lanes, top: 36);
    _updateText();
  }

  void _updateText() {
    _state.text = _safe
        ? 'It is safe. Tap to make it dangerous.'
        : 'DANGER! Tap to make it safe again.';
  }

  TreeLane _lane({
    required String title,
    required String explanation,
    required bool reactive,
  }) {
    return TreeLane(
      title: title,
      explanation: explanation,
      hasAgent: true,
      build: (lane) => Repeat(
        Sequence(reactive: reactive, [
          Condition((context) => context.get(_isSafe)),
          MoveTo(
            (context) => Vector2(laneAgentEnd, lane.agent.y),
            speed: 40,
            target: lane.agent,
          ),
          // Back to the start for the next round.
          Task((context) {
            lane.agent.x = laneAgentStart;
            return Status.success;
          }),
        ]),
      ),
    );
  }
}
