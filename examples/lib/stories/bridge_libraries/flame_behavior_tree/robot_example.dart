import 'dart:math';

import 'package:examples/stories/bridge_libraries/flame_behavior_tree/common.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

const _battery = BlackboardKey<double>('battery', initial: 100);

class RobotExample() extends BehaviorTreeGame {
  this : super(height: 390);

  static const String description = '''
    A robot goes to work spots, scans them, and goes back to its charger when
    its battery is low. It uses every kind of leaf node, which are the nodes
    that do the actual work:

    - `Condition` checks if the battery is low.
    - `Task` charges the robot, a little on every tick, until it is full. It
      is running until then.
    - `MoveTo` walks the robot somewhere.
    - `AsyncTask` scans a spot, which takes a second. It is running until its
      future completes.
    - `PlayEffect` flashes the robot when the scan is done.
    - `Wait` lets the robot rest for a moment.

    The first child of the selector is checked on every tick, so when the
    battery gets low the robot stops whatever it is doing, and goes to charge.
  ''';

  @override
  void onLoad() {
    final robot = _Robot();
    world.addAll([
      _Battery(robot),
      // The charger.
      RectangleComponent(
        position: Vector2(30, 120),
        size: Vector2(36, 36),
        anchor: Anchor.center,
        paint: Paint()..color = Colors.green.shade800,
      ),
      caption('charger', position: Vector2(30, 146), anchor: Anchor.topCenter),
      for (final spot in _Robot.workSpots)
        RectangleComponent(
          position: spot,
          size: Vector2(26, 26),
          anchor: Anchor.center,
          paint: Paint()..color = Colors.white24,
        ),
      robot,
      TreeView(robot, position: Vector2(12, 240)),
    ]);
  }
}

class _Robot() extends CircleComponent with HasBehaviorTree {
  this
    : super(
        radius: 11,
        position: Vector2(30, 120),
        anchor: Anchor.center,
        paint: Paint()..color = Colors.cyan,
      );

  static final workSpots = [
    Vector2(160, 70),
    Vector2(330, 60),
    Vector2(230, 170),
    Vector2(350, 160),
  ];

  bool isCharging = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isCharging) {
      blackboard.set(_battery, max(0, blackboard.get(_battery) - 10 * dt));
    }
  }

  @override
  void onLoad() {
    final random = Random();

    behaviorTree = BehaviorTree(
      Selector(reactive: true, [
        named(
          'go and charge',
          Sequence([
            named(
              'battery low?',
              Condition((context) => context.get(_battery) < 40),
            ),
            named(
              'go to the charger',
              MoveTo((context) => Vector2(30, 120), speed: 120),
            ),
            named(
              'charge until full',
              Task(
                (context) {
                  final robot = context.owner<_Robot>();
                  robot.isCharging = true;
                  final level = min(
                    100.0,
                    context.get(_battery) + 30 * context.dt,
                  );
                  context.set(_battery, level);
                  if (level < 100) {
                    return Status.running;
                  }
                  robot.isCharging = false;
                  return Status.success;
                },
                // The battery is not charging anymore when this is interrupted.
                onAbortCallback: (context) {
                  context.owner<_Robot>().isCharging = false;
                },
              ),
            ),
          ]),
        ),
        named(
          'work',
          Sequence([
            named(
              'walk to a work spot',
              MoveTo(
                (context) => workSpots[random.nextInt(workSpots.length)],
                speed: 90,
              ),
            ),
            named(
              'scan it (a future)',
              AsyncTask((context) async {
                await Future<void>.delayed(const Duration(seconds: 1));
                return Status.success;
              }),
            ),
            named(
              'flash when done',
              PlayEffect(
                (context) => ColorEffect(
                  Colors.lightGreen,
                  EffectController(duration: 0.3, alternate: true),
                ),
              ),
            ),
            named('rest', Wait(1)),
          ]),
        ),
      ]),
      owner: this,
    );
  }
}

/// Shows how much battery the robot has left.
class _Battery(this._robot) extends PositionComponent {
  this : super(position: Vector2(12, 12));

  final _Robot _robot;

  static const _width = 120.0;

  @override
  void render(Canvas canvas) {
    final level = _robot.blackboard.get(_battery);
    canvas
      ..drawRect(
        const Rect.fromLTWH(0, 0, _width, 8),
        Paint()..color = Colors.white12,
      )
      ..drawRect(
        Rect.fromLTWH(0, 0, _width * level / 100, 8),
        Paint()..color = level < 40 ? Colors.red : Colors.green,
      );
  }
}
