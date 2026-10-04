import 'package:examples/stories/bridge_libraries/flame_behavior_tree/common.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

const _progress = BlackboardKey<double>('progress', initial: 0);

class LeafNodesExample() extends BehaviorTreeGame {
  this : super(height: 450);

  static const String description = '''
    Leaf nodes are the nodes that actually do something, they have no
    children. Every row runs a tree that only consists of one of them.

    The light on the right shows the status that the node returned: amber for
    `running`, green for `success` and red for `failure`. A node that is running
    gets ticked again on the next tick, until it is done.

    Rows with a blue circle show nodes that act on a component, here that
    circle. They are specific to `flame_behavior_tree`.
  ''';

  @override
  void onLoad() {
    addLanes(world, [
      TreeLane(
        title: 'Condition(...)',
        explanation: 'Succeeds on even seconds and fails on odd ones.',
        build: (lane) => Condition((context) {
          return context.owner<TreeLane>().time % 2 < 1;
        }),
      ),
      TreeLane(
        title: 'Task(...)',
        explanation: 'Is running for 1.5s, counted using the blackboard.',
        build: (lane) => Task((context) {
          final progress = context.get(_progress) + context.dt;
          if (progress < 1.5) {
            context.set(_progress, progress);
            return Status.running;
          }
          context.set(_progress, 0.0);
          return Status.success;
        }),
      ),
      TreeLane(
        title: 'Wait(1.5)',
        explanation: 'Is running for 1.5s of game time, then succeeds.',
        build: (lane) => Wait(1.5),
      ),
      TreeLane(
        title: 'AsyncTask(...)',
        explanation: 'Is running until a future completes after 1.5s.',
        build: (lane) => AsyncTask((context) async {
          await Future<void>.delayed(const Duration(milliseconds: 1500));
          return Status.success;
        }),
      ),
      TreeLane(
        title: 'PlayEffect(...)',
        explanation: 'Is running while an effect plays on the circle.',
        hasAgent: true,
        build: (lane) => PlayEffect(
          target: lane.agent,
          (context) => ColorEffect(
            Colors.pink,
            EffectController(duration: 0.75, alternate: true),
          ),
        ),
      ),
      TreeLane(
        title: 'MoveTo(...)',
        explanation: 'Is running while the circle moves. Here there and back.',
        hasAgent: true,
        build: (lane) => Sequence([
          MoveTo(
            (context) => Vector2(laneAgentEnd, lane.agent.y),
            duration: 1.5,
            curve: Curves.easeInOut,
            target: lane.agent,
          ),
          MoveTo(
            (context) => Vector2(laneAgentStart, lane.agent.y),
            speed: 100,
            target: lane.agent,
          ),
        ]),
      ),
    ]);
  }
}
