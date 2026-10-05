import 'dart:math';

import 'package:examples/stories/bridge_libraries/flame_behavior_tree/common.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

const _isGuardNearby = BlackboardKey<bool>('isGuardNearby', initial: false);

class ThiefExample() extends BehaviorTreeGame {
  this : super(height: 480);

  static const String description = '''
    A thief tries to pick the lock of a door, to get to the vault behind it.
    Tap to call a guard, or to send them away again.

    - The thief only breaks in when no guard is nearby. This is a reactive
      sequence that checks for the guard on every tick, so if a guard shows up
      while the thief is on the way, the break-in is aborted and the thief goes
      home.
    - `RetryOnFailure` lets the thief try the lock again when an attempt fails.
      Only one out of three attempts works.
    - `TimeLimit` makes the thief give up when the lock takes longer than two
      and a half seconds.
    - `AlwaysSucceed` makes hiding an optional step. At home the thief hides if
      there is a guard, and does nothing if there is none. Either way the
      thief carries on.

    The result of a break-in depends on luck, so watch it a few times.
  ''';

  @override
  void onLoad() {
    final thief = _Thief();
    world.addAll([
      TapArea(
        size: Vector2(exampleWidth, 170),
        onTap: (_) => thief.toggleGuard(),
      ),
      caption(
        'Tap to call a guard, or to send them away.',
        position: Vector2(12, 12),
      ),
      thief.door,
      thief.vault,
      thief.guard,
      thief,
      TreeView(thief, position: Vector2(12, 178)),
    ]);
  }
}

class _Thief() extends CircleComponent with HasBehaviorTree {
  this
    : super(
        radius: 10,
        position: _home.clone(),
        anchor: Anchor.center,
        paint: Paint()..color = Colors.cyan,
      );

  static final _home = Vector2(40, 100);
  static final _doorPosition = Vector2(190, 100);
  static final _vaultPosition = Vector2(340, 100);

  final door = RectangleComponent(
    position: _doorPosition + Vector2(18, 0),
    size: Vector2(12, 50),
    anchor: Anchor.center,
    paint: Paint()..color = Colors.red.shade800,
  );

  final vault = RectangleComponent(
    position: _vaultPosition,
    size: Vector2(36, 36),
    anchor: Anchor.center,
    paint: Paint()..color = Colors.amber.shade700,
  );

  final guard = dot(
    Colors.deepOrange,
    position: Vector2(120, 50),
  )..paint.color = Colors.transparent;

  void toggleGuard() {
    final isNearby = !blackboard.get(_isGuardNearby);
    blackboard.set(_isGuardNearby, isNearby);
    guard.paint.color = isNearby ? Colors.deepOrange : Colors.transparent;
  }

  @override
  void onLoad() {
    final random = Random();

    Node isGuardNearby() {
      return named(
        'is a guard nearby?',
        Condition((context) => context.get(_isGuardNearby)),
      );
    }

    behaviorTree = BehaviorTree(
      Repeat(
        Sequence([
          Selector([
            // This sequence is reactive, so the guard is checked on every tick,
            // also while the thief is busy with the rest of the break-in.
            named(
              'break in, unless a guard shows up',
              Sequence(reactive: true, [
                named(
                  'is the coast clear?',
                  Inverter(isGuardNearby()),
                ),
                named(
                  'break in',
                  Sequence([
                    named(
                      'walk to the door',
                      MoveTo((context) => _doorPosition, speed: 90),
                    ),
                    named(
                      'give up after 2.5s',
                      TimeLimit(
                        named(
                          'try again when it fails',
                          RetryOnFailure(
                            times: 10,
                            Sequence([
                              named(
                                'pick the lock',
                                PlayEffect(
                                  (context) => MoveEffect.by(
                                    Vector2(0, -5),
                                    EffectController(
                                      duration: 0.1,
                                      alternate: true,
                                      repeatCount: 3,
                                    ),
                                  ),
                                ),
                              ),
                              named(
                                'did it open? (1 in 3)',
                                Condition((context) => random.nextInt(3) == 0),
                              ),
                            ]),
                          ),
                        ),
                        2.5,
                      ),
                    ),
                    named(
                      'open the door',
                      Task((context) {
                        context.owner<_Thief>().door.paint.color =
                            Colors.green.shade700;
                        return Status.success;
                      }),
                    ),
                    named(
                      'walk to the vault',
                      MoveTo(
                        (context) => _vaultPosition - Vector2(30, 0),
                        speed: 90,
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
            named(
              'could not break in, give up',
              Task((context) {
                return Status.success;
              }),
            ),
          ]),
          named(
            'go home',
            MoveTo((context) => _home, speed: 120),
          ),
          named(
            'close the door',
            Task((context) {
              context.owner<_Thief>().door.paint.color = Colors.red.shade800;
              return Status.success;
            }),
          ),
          named(
            'hide if a guard is nearby, otherwise skip',
            AlwaysSucceed(
              Sequence([
                isGuardNearby(),
                named(
                  'hide for a moment',
                  PlayEffect(
                    (context) => OpacityEffect.to(
                      0.2,
                      EffectController(duration: 0.7, alternate: true),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          named('wait', Wait(1)),
        ]),
      ),
      owner: this,
    );
  }
}
