import 'package:examples/stories/bridge_libraries/flame_behavior_tree/common.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

class ParallelExample() extends BehaviorTreeGame {
  this : super(height: 300);

  static const String description = '''
    A `Parallel` node ticks all of its children on every tick, so that they run
    at the same time. Its `ParallelPolicy` decides when it is done:

    - `requireAll` succeeds when all the children have succeeded, and fails as
      soon as one of them fails.
    - `requireOne` succeeds as soon as one of the children succeeds, and fails
      when all of them have failed.

    When the result is known, the children that are still running get aborted.
    The light on the right shows the status that the node returned: amber for
    `running`, green for `success` and red for `failure`.

    In the last row the circle moves and changes its color at the same time.
  ''';

  @override
  void onLoad() {
    addLanes(world, [
      TreeLane(
        title: 'Parallel([Wait(1), Wait(2)])',
        explanation: 'With requireAll it takes until both are done, 2s.',
        build: (lane) => Parallel([Wait(1), Wait(2)]),
      ),
      TreeLane(
        title: 'Parallel([Wait(1), Wait(2)], requireOne)',
        explanation: 'With requireOne it is done as soon as one is, 1s.',
        build: (lane) => Parallel(
          [Wait(1), Wait(2)],
          policy: ParallelPolicy.requireOne,
        ),
      ),
      TreeLane(
        title: 'Parallel([Wait(2), Condition(false)])',
        explanation:
            'With requireAll a failure is enough, the wait is aborted.',
        build: (lane) => Parallel([
          Wait(2),
          Condition((context) => false),
        ]),
      ),
      TreeLane(
        title: 'Parallel([MoveTo(...), PlayEffect(...)])',
        explanation: 'Moves and changes color at the same time.',
        hasAgent: true,
        build: (lane) => Sequence([
          Parallel([
            MoveTo(
              (context) => Vector2(laneAgentEnd, lane.agent.y),
              duration: 1.5,
              target: lane.agent,
            ),
            PlayEffect(
              target: lane.agent,
              (context) => ColorEffect(
                Colors.pink,
                EffectController(duration: 0.75, alternate: true),
              ),
            ),
          ]),
          MoveTo(
            (context) => Vector2(laneAgentStart, lane.agent.y),
            speed: 200,
            target: lane.agent,
          ),
        ]),
      ),
    ]);
  }
}
