import 'package:examples/stories/bridge_libraries/flame_behavior_tree/common.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

const _destination = BlackboardKey<Vector2>('destination');
const _ticks = BlackboardKey<int>('ticks', initial: 0);
const _intervals = [0.0, 0.25, 0.5, 1.0];

class TickIntervalExample() extends BehaviorTreeGame {
  this : super(height: 300);

  static const String description = '''
    By default a behavior tree is ticked on every update of its component. That
    is often more than needed, and thinking less often is cheaper. Set
    `tickInterval` on a component with `HasBehaviorTree` to tick its tree only
    every so many seconds. It can be changed at any time.

    The agent follows the place that you tap. Tap the text at the top to change
    the tick interval, and watch how the agent reacts more slowly and how
    the number of ticks goes down. The tree is ticked, and counted, also when
    the agent has nowhere to go. The time that the nodes get as `context.dt`
    is the time since the previous tick, so the agent still moves at the same
    speed.
  ''';

  late final _Agent _agent;
  late final TextComponent _ticksText;

  @override
  void onLoad() {
    _agent = _Agent();
    _ticksText = caption('', position: Vector2(12, 36));
    world.addAll([
      TapArea(
        size: Vector2(exampleWidth, 300),
        onTap: (position) => _agent.blackboard.set(_destination, position),
      ),
      _IntervalButton(_agent),
      _ticksText,
      _agent,
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _ticksText.text =
        'The tree was ticked ${_agent.blackboard.get(_ticks)} '
        'times.';
  }
}

/// A text that cycles through the tick intervals when it is tapped.
class _IntervalButton(this._agent) extends TextComponent with TapCallbacks {
  this
    : super(
        position: Vector2(12, 12),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.lightBlueAccent,
            fontSize: 11,
            decoration: TextDecoration.underline,
          ),
        ),
        priority: 1,
      );

  final _Agent _agent;

  @override
  void onMount() {
    super.onMount();
    _updateText();
  }

  @override
  void onTapDown(TapDownEvent event) {
    final next =
        (_intervals.indexOf(_agent.tickInterval) + 1) % _intervals.length;
    _agent.tickInterval = _intervals[next];
    _updateText();
  }

  void _updateText() {
    text = 'tickInterval = ${_agent.tickInterval}s (tap to change)';
  }
}

class _Agent() extends CircleComponent with HasBehaviorTree {
  this
    : super(
        radius: 12,
        position: Vector2(exampleWidth / 2, 170),
        anchor: Anchor.center,
        paint: Paint()..color = Colors.cyan,
      );

  static const _speed = 100.0;

  @override
  void onLoad() {
    behaviorTree = BehaviorTree(
      // This sequence is reactive, so that the first task runs on every tick
      // of the tree, also while the agent is moving or has nowhere to go.
      Sequence(reactive: true, [
        named(
          'count the tick',
          Task((context) {
            context.set(_ticks, context.get(_ticks) + 1);
            return Status.success;
          }),
        ),
        named(
          'is there a destination?',
          Condition((context) => context.blackboard.has(_destination)),
        ),
        named(
          'step towards it',
          Task((context) {
            // Take a step towards the destination, as far as the time that
            // passed since the previous tick allows.
            final destination = context.get(_destination);
            final toDestination = destination - position;
            final step = _speed * context.dt;
            if (toDestination.length <= step) {
              position = destination;
              context.blackboard.remove(_destination);
              return Status.success;
            }
            position += toDestination.normalized() * step;
            return Status.running;
          }),
        ),
      ]),
      owner: this,
    );
  }
}
