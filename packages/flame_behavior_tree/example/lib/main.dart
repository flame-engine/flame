import 'dart:async';

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:flutter/material.dart';

typedef MyGame = FlameGame<GameWorld>;
const gameWidth = 320.0;
const gameHeight = 180.0;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GameWidget<MyGame>.controlled(
          gameFactory: () => MyGame(
            world: GameWorld(),
            camera: CameraComponent.withFixedResolution(
              width: gameWidth,
              height: gameHeight,
            ),
          ),
        ),
      ),
    );
  }
}

class GameWorld extends World with HasGameReference {
  @override
  Future<void> onLoad() async {
    game.camera.moveTo(Vector2(gameWidth * 0.5, gameHeight * 0.5));

    final house = RectangleComponent(
      size: Vector2(100, 100),
      position: Vector2(gameWidth * 0.5, 10),
      paint: BasicPalette.cyan.paint()
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke,
      anchor: Anchor.topCenter,
    );

    final door = Door(
      size: Vector2(20, 4),
      position: Vector2(40, house.size.y),
      anchor: Anchor.centerLeft,
    );

    final agent = Agent(
      door: door,
      house: house,
      position: Vector2(gameWidth * 0.76, gameHeight * 0.9),
    );

    await house.add(door);
    await addAll([house, agent]);
  }
}

class Door extends RectangleComponent with TapCallbacks {
  Door({super.position, super.size, super.anchor})
    : super(paint: BasicPalette.brown.paint());

  bool isOpen = false;
  bool _isInProgress = false;
  bool _isKnocking = false;

  @override
  void onTapDown(TapDownEvent event) {
    if (!_isInProgress) {
      _isInProgress = true;
      add(
        RotateEffect.to(
          isOpen ? 0 : -pi * 0.5,
          EffectController(duration: 0.5, curve: Curves.easeInOut),
          onComplete: () {
            isOpen = !isOpen;
            _isInProgress = false;
          },
        ),
      );
    }
  }

  void knock() {
    if (!_isKnocking) {
      _isKnocking = true;
      add(
        MoveEffect.by(
          Vector2(0, -1),
          EffectController(
            alternate: true,
            duration: 0.1,
            repeatCount: 2,
          ),
          onComplete: () {
            _isKnocking = false;
          },
        ),
      );
    }
  }
}

class Agent extends PositionComponent with HasBehaviorTree {
  Agent({required this.door, required this.house, required Vector2 position})
    : _startPosition = position.clone(),
      super(position: position);

  final Door door;
  final PositionComponent house;
  final Vector2 _startPosition;

  @override
  Future<void> onLoad() async {
    await add(CircleComponent(radius: 3, anchor: Anchor.center));
    _setupBehaviorTree();
    super.onLoad();
  }

  void _setupBehaviorTree() {
    // Initialize blackboard with agent state
    blackboard = Blackboard();
    blackboard!.set('isInside', false);
    blackboard!.set('isAtTheDoor', false);
    blackboard!.set('isAtCenterOfHouse', false);
    blackboard!.set('isMoving', false);
    blackboard!.set('wantsToGoOutside', false);

    final walkTowardsDoorInside = WalkTowardsDoorInsideTask(
      door: door,
      agent: this,
    );

    final stepOutTheDoor = StepOutTheDoorTask(
      door: door,
      agent: this,
    );

    final walkTowardsInitialPosition = WalkTowardsInitialPositionTask(
      startPosition: _startPosition,
      agent: this,
    );

    final walkTowardsDoorOutside = WalkTowardsDoorOutsideTask(
      door: door,
      agent: this,
    );

    final walkTowardsCenterOfTheHouse = WalkTowardsCenterOfTheHouseTask(
      house: house,
      agent: this,
    );

    final checkIfDoorIsOpen = CheckIfDoorIsOpenCondition(door);
    final knockTheDoor = KnockTheDoorTask(door);
    final checkIfMoving = CheckMovingCondition();
    final checkWantsToGoOutside = CheckWantsToGoOutsideCondition();
    final checkIsInside = CheckIsInsideCondition();
    final checkIsOutside = CheckIsOutsideCondition();

    final goOutsideSequence = Sequence(
      children: [
        checkWantsToGoOutside,
        Selector(
          children: [
            Sequence(
              children: [
                checkIsInside,
                walkTowardsDoorInside,
                Selector(
                  children: [
                    Sequence(
                      children: [
                        checkIfDoorIsOpen,
                        stepOutTheDoor,
                      ],
                    ),
                    knockTheDoor,
                  ],
                ),
              ],
            ),
            walkTowardsInitialPosition,
          ],
        ),
      ],
    );

    final goInsideSequence = Sequence(
      children: [
        Inverter(checkWantsToGoOutside),
        Selector(
          children: [
            Sequence(
              children: [
                checkIsOutside,
                walkTowardsDoorOutside,
                Selector(
                  children: [
                    Sequence(
                      children: [
                        checkIfDoorIsOpen,
                        walkTowardsCenterOfTheHouse,
                      ],
                    ),
                    knockTheDoor,
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    treeRoot = Selector(
      children: [
        checkIfMoving,
        goOutsideSequence,
        goInsideSequence,
      ],
    );
    tickInterval = 2;
  }
}

// Custom behavior tree nodes that use the blackboard

class CheckMovingCondition extends BaseNode {
  @override
  void tick() {
    final isMoving = blackboard?.get<bool>('isMoving') ?? false;
    status = isMoving ? NodeStatus.success : NodeStatus.failure;
  }
}

class CheckWantsToGoOutsideCondition extends BaseNode {
  @override
  void tick() {
    final wantsToGoOutside = blackboard?.get<bool>('wantsToGoOutside') ?? false;
    status = wantsToGoOutside ? NodeStatus.success : NodeStatus.failure;
  }
}

class CheckIsInsideCondition extends BaseNode {
  @override
  void tick() {
    final isInside = blackboard?.get<bool>('isInside') ?? false;
    status = isInside ? NodeStatus.success : NodeStatus.failure;
  }
}

class CheckIsOutsideCondition extends BaseNode {
  @override
  void tick() {
    final isInside = blackboard?.get<bool>('isInside') ?? false;
    status = !isInside ? NodeStatus.success : NodeStatus.failure;
  }
}

class CheckIfDoorIsOpenCondition extends BaseNode {
  CheckIfDoorIsOpenCondition(this.door);
  final Door door;

  @override
  void tick() {
    status = door.isOpen ? NodeStatus.success : NodeStatus.failure;
  }
}

class KnockTheDoorTask extends BaseNode {
  KnockTheDoorTask(this.door);
  final Door door;

  @override
  void tick() {
    door.knock();
    status = NodeStatus.success;
  }
}

class WalkTowardsDoorInsideTask extends BaseNode {
  WalkTowardsDoorInsideTask({required this.door, required this.agent});
  final Door door;
  final Agent agent;

  @override
  void tick() {
    final isAtTheDoor = blackboard?.get<bool>('isAtTheDoor') ?? false;
    
    if (!isAtTheDoor) {
      blackboard?.set('isMoving', true);

      agent.add(
        MoveEffect.to(
          door.absolutePosition + Vector2(door.size.x * 0.8, -15),
          EffectController(
            duration: 3,
            curve: Curves.easeInOut,
          ),
          onComplete: () {
            blackboard?.set('isMoving', false);
            blackboard?.set('isAtTheDoor', true);
            blackboard?.set('isAtCenterOfHouse', false);
          },
        ),
      );
    }
    status = isAtTheDoor ? NodeStatus.success : NodeStatus.running;
  }
}

class StepOutTheDoorTask extends BaseNode {
  StepOutTheDoorTask({required this.door, required this.agent});
  final Door door;
  final Agent agent;

  @override
  void tick() {
    final isInside = blackboard?.get<bool>('isInside') ?? false;
    
    if (isInside) {
      blackboard?.set('isMoving', true);
      agent.add(
        MoveEffect.to(
          door.absolutePosition + Vector2(door.size.x * 0.5, 10),
          EffectController(
            duration: 2,
            curve: Curves.easeInOut,
          ),
          onComplete: () {
            blackboard?.set('isMoving', false);
            blackboard?.set('isInside', false);
          },
        ),
      );
    }
    status = !isInside ? NodeStatus.success : NodeStatus.running;
  }
}

class WalkTowardsInitialPositionTask extends BaseNode {
  WalkTowardsInitialPositionTask({
    required this.startPosition,
    required this.agent,
  });
  final Vector2 startPosition;
  final Agent agent;

  @override
  void tick() {
    final isAtTheDoor = blackboard?.get<bool>('isAtTheDoor') ?? false;
    final wantsToGoOutside = blackboard?.get<bool>('wantsToGoOutside') ?? false;

    if (isAtTheDoor) {
      blackboard?.set('isMoving', true);
      blackboard?.set('isAtTheDoor', false);

      agent.add(
        MoveEffect.to(
          startPosition,
          EffectController(
            duration: 3,
            curve: Curves.easeInOut,
          ),
          onComplete: () {
            blackboard?.set('isMoving', false);
            blackboard?.set('wantsToGoOutside', false);
          },
        ),
      );
    }

    status = !wantsToGoOutside ? NodeStatus.success : NodeStatus.running;
  }
}

class WalkTowardsDoorOutsideTask extends BaseNode {
  WalkTowardsDoorOutsideTask({required this.door, required this.agent});
  final Door door;
  final Agent agent;

  @override
  void tick() {
    final isAtTheDoor = blackboard?.get<bool>('isAtTheDoor') ?? false;
    
    if (!isAtTheDoor) {
      blackboard?.set('isMoving', true);
      agent.add(
        MoveEffect.to(
          door.absolutePosition + Vector2(door.size.x * 0.5, 10),
          EffectController(
            duration: 3,
            curve: Curves.easeInOut,
          ),
          onComplete: () {
            blackboard?.set('isMoving', false);
            blackboard?.set('isAtTheDoor', true);
          },
        ),
      );
    }
    status = isAtTheDoor ? NodeStatus.success : NodeStatus.running;
  }
}

class WalkTowardsCenterOfTheHouseTask extends BaseNode {
  WalkTowardsCenterOfTheHouseTask({required this.house, required this.agent});
  final PositionComponent house;
  final Agent agent;

  @override
  void tick() {
    final isAtCenterOfHouse = blackboard?.get<bool>('isAtCenterOfHouse') ?? false;
    
    if (!isAtCenterOfHouse) {
      blackboard?.set('isMoving', true);
      blackboard?.set('isInside', true);

      agent.add(
        MoveEffect.to(
          house.absoluteCenter,
          EffectController(
            duration: 3,
            curve: Curves.easeInOut,
          ),
          onComplete: () {
            blackboard?.set('isMoving', false);
            blackboard?.set('wantsToGoOutside', true);
            blackboard?.set('isAtTheDoor', false);
            blackboard?.set('isAtCenterOfHouse', true);
          },
        ),
      );
    }
    status = (blackboard?.get<bool>('isInside') ?? false)
        ? NodeStatus.success
        : NodeStatus.running;
  }
}
