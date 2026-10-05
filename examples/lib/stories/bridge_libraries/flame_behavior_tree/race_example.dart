import 'package:examples/stories/bridge_libraries/flame_behavior_tree/common.dart';
import 'package:flame/components.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

class RaceExample() extends BehaviorTreeGame {
  this : super(height: 440);

  static const String description = '''
    A `Parallel` node ticks all of its children on every tick, so they run at
    the same time. Here each child makes a runner run along its track. The
    blue runner takes two seconds and the orange one takes four.

    What the `ParallelPolicy` of the node decides is when it is done:

    - With `requireAll`, it is done when all the runners have arrived.
    - With `requireOne`, it is done as soon as one runner has arrived. The
      children that are still running are aborted, so the orange runner stops
      where it is.

    After a second, the runners go back to the start and the race begins again.
  ''';

  @override
  void onLoad() {
    final lanes = [
      _Lane(
        title: 'ParallelPolicy.requireAll',
        policy: ParallelPolicy.requireAll,
      )..position = Vector2(0, 8),
      _Lane(
        title: 'ParallelPolicy.requireOne',
        policy: ParallelPolicy.requireOne,
      )..position = Vector2(0, 230),
    ];
    world.addAll(lanes);
  }
}

class _Lane({required this.title, required this.policy})
    extends PositionComponent
    with HasBehaviorTree {
  this : super(size: Vector2(exampleWidth, 210));

  final String title;
  final ParallelPolicy policy;

  static const _startX = 24.0;
  static const _endX = exampleWidth - 24;

  late final CircleComponent blue = dot(
    Colors.lightBlue,
    position: Vector2(_startX, 44),
  );
  late final CircleComponent orange = dot(
    Colors.orange,
    position: Vector2(_startX, 72),
  );

  @override
  void onLoad() {
    addAll([
      caption(title, position: Vector2(12, 8)),
      for (final y in [44.0, 72.0])
        RectangleComponent(
          position: Vector2(_startX, y - 1),
          size: Vector2(_endX - _startX, 2),
          paint: Paint()..color = Colors.white24,
        ),
      blue,
      orange,
    ]);

    behaviorTree = BehaviorTree(
      Repeat(
        Sequence([
          named(
            'run until the policy says it is done',
            Parallel(policy: policy, [
              named(
                'blue runs for 2s',
                MoveTo(
                  (context) => Vector2(_endX, 44),
                  duration: 2,
                  target: blue,
                ),
              ),
              named(
                'orange runs for 4s',
                MoveTo(
                  (context) => Vector2(_endX, 72),
                  duration: 4,
                  target: orange,
                ),
              ),
            ]),
          ),
          named('wait', Wait(1)),
          named(
            'back to the start',
            Task((context) {
              blue.x = _startX;
              orange.x = _startX;
              return Status.success;
            }),
          ),
        ]),
      ),
      owner: this,
    );
    add(TreeView(this, position: Vector2(12, 100)));
  }
}
