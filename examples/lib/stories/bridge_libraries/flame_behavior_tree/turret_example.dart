import 'package:examples/stories/bridge_libraries/flame_behavior_tree/common.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

class TurretExample() extends BehaviorTreeGame {
  this : super(height: 380);

  static const String description = '''
    A turret shoots at a target that is within its range. Tap to move the
    target in and out of range.

    - `Cooldown` lets the turret fire a burst, and then stops it from firing
      again for two seconds. While it is cooling down it fails, which you can
      see in the tree.
    - `Repeat` runs what it wraps three times in a row, which makes the burst of
      three shots.
    - `Inverter` turns "is the target in range?" around, so that the turret
      only scans when there is nothing to shoot at.
  ''';

  @override
  void onLoad() {
    final target = dot(Colors.red, position: Vector2(170, 90), r: 9);
    final turret = _Turret(target);
    world.addAll([
      TapArea(
        size: Vector2(exampleWidth, 200),
        onTap: (position) => target.position = position,
      ),
      caption(
        'Tap to move the target.',
        position: Vector2(12, 12),
      ),
      // The range of the turret.
      CircleComponent(
        radius: _Turret.range,
        position: turret.position,
        anchor: Anchor.center,
        paint: Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke,
      ),
      target,
      turret,
      TreeView(turret, position: Vector2(12, 208)),
    ]);
  }
}

class _Turret(this.target) extends CircleComponent with HasBehaviorTree {
  this
    : super(
        radius: 12,
        position: Vector2(70, 110),
        anchor: Anchor.center,
        paint: Paint()..color = Colors.cyan,
      );

  static const range = 130.0;

  final PositionComponent target;

  bool get isTargetInRange => position.distanceTo(target.position) <= range;

  void fire() {
    final bullet = dot(Colors.yellow, position: position.clone(), r: 3);
    parent!.add(bullet);
    bullet.add(
      MoveEffect.to(
        target.position.clone(),
        EffectController(speed: 300),
        onComplete: bullet.removeFromParent,
      ),
    );
  }

  @override
  void onLoad() {
    behaviorTree = BehaviorTree(
      Selector([
        named(
          'shoot the target',
          Sequence([
            named(
              'is the target in range?',
              Condition((context) => context.owner<_Turret>().isTargetInRange),
            ),
            named(
              'after a burst, wait 2s before the next one',
              Cooldown(
                named(
                  'three times',
                  Repeat(
                    times: 3,
                    Sequence([
                      named(
                        'fire',
                        Task((context) {
                          context.owner<_Turret>().fire();
                          return Status.success;
                        }),
                      ),
                      named('wait a moment', Wait(0.2)),
                    ]),
                  ),
                ),
                2,
              ),
            ),
          ]),
        ),
        named(
          'scan',
          Sequence([
            named(
              'is nothing in range?',
              Inverter(
                Condition(
                  (context) => context.owner<_Turret>().isTargetInRange,
                ),
              ),
            ),
            named(
              'pulse',
              PlayEffect(
                (context) => ColorEffect(
                  Colors.lightGreen,
                  EffectController(duration: 0.6, alternate: true),
                ),
              ),
            ),
          ]),
        ),
      ]),
      owner: this,
    );
  }
}
