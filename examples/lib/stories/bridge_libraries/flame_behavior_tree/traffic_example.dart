import 'package:examples/stories/bridge_libraries/flame_behavior_tree/common.dart';
import 'package:flame/components.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

const _isGreen = BlackboardKey<bool>('isGreen', initial: true);

class TrafficExample() extends BehaviorTreeGame {
  this : super(height: 320);

  static const String description = '''
    Two cars drive along their road, as long as the traffic light is green.
    Tap to switch the light, and see which car stops at a red light.

    Both cars have the same tree, except for one thing: the sequence of the top
    car has memory, and the sequence of the bottom car is reactive.

    A sequence with memory (the default) continues with the child that was
    running, and does not check the children before it again. The condition
    "is the light green?" was true when the car started driving, so the car
    does not look at the light anymore.

    A reactive sequence starts from its first child on every tick. As soon as
    the light turns red, the condition fails. The sequence fails, and its
    running child is aborted, which stops the car.
  ''';

  @override
  void onLoad() {
    final cars = [
      _Car(position: Vector2(30, 70), reactive: false),
      _Car(position: Vector2(30, 215), reactive: true),
    ];
    final light = dot(Colors.green, position: Vector2(370, 22), r: 9);
    var isGreen = true;

    world.addAll([
      TapArea(
        size: Vector2(exampleWidth, 320),
        onTap: (_) {
          isGreen = !isGreen;
          light.paint.color = isGreen ? Colors.green : Colors.red;
          for (final car in cars) {
            car.blackboard.set(_isGreen, isGreen);
          }
        },
      ),
      caption(
        'Tap to switch the traffic light.',
        position: Vector2(12, 14),
      ),
      light,
      caption('Sequence with memory', position: Vector2(12, 40)),
      caption('Reactive sequence', position: Vector2(12, 185)),
      for (final y in [70.0, 215.0])
        RectangleComponent(
          position: Vector2(10, y + 12),
          size: Vector2(exampleWidth - 20, 2),
          paint: Paint()..color = Colors.white24,
        ),
      ...cars,
      TreeView(cars[0], position: Vector2(12, 90)),
      TreeView(cars[1], position: Vector2(12, 235)),
    ]);
  }
}

class _Car({required Vector2 position, required this.reactive})
    extends RectangleComponent
    with HasBehaviorTree {
  this
    : super(
        position: position,
        size: Vector2(30, 16),
        anchor: Anchor.center,
        paint: Paint()..color = Colors.cyan,
      );

  final bool reactive;

  // Where the car goes back to, remembered while it is still at the start.
  final double _startX = position.x;

  @override
  void onLoad() {
    behaviorTree = BehaviorTree(
      Repeat(
        Sequence(reactive: reactive, [
          named(
            'is the light green?',
            Condition((context) => context.get(_isGreen)),
          ),
          named(
            'drive to the end of the road',
            MoveTo((context) => Vector2(380, y), speed: 60),
          ),
          named(
            'back to the start',
            Task((context) {
              context.owner<_Car>().x = _startX;
              return Status.success;
            }),
          ),
        ]),
      ),
      owner: this,
    );
  }
}
