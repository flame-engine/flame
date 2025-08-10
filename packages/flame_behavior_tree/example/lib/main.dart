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
    var isInside = false;
    var isAtTheDoor = false;
    var isAtCenterOfHouse = false;
    var isMoving = false;
    var wantsToGoOutside = false;

    final walkTowardsDoorInside = Task(() {
      if (!isAtTheDoor) {
        isMoving = true;

        add(
          MoveEffect.to(
            door.absolutePosition + Vector2(door.size.x * 0.8, -15),
            EffectController(
              duration: 3,
              curve: Curves.easeInOut,
            ),
            onComplete: () {
              isMoving = false;
              isAtTheDoor = true;
              isAtCenterOfHouse = false;
            },
          ),
        );
      }
      return isAtTheDoor ? NodeStatus.success : NodeStatus.running;
    });

    final stepOutTheDoor = Task(() {
      if (isInside) {
        isMoving = true;
        add(
          MoveEffect.to(
            door.absolutePosition + Vector2(door.size.x * 0.5, 10),
            EffectController(
              duration: 2,
              curve: Curves.easeInOut,
            ),
            onComplete: () {
              isMoving = false;
              isInside = false;
            },
          ),
        );
      }
      return !isInside ? NodeStatus.success : NodeStatus.running;
    });

    final walkTowardsInitialPosition = Task(
      () {
        if (isAtTheDoor) {
          isMoving = true;
          isAtTheDoor = false;

          add(
            MoveEffect.to(
              _startPosition,
              EffectController(
                duration: 3,
                curve: Curves.easeInOut,
              ),
              onComplete: () {
                isMoving = false;
                wantsToGoOutside = false;
              },
            ),
          );
        }

        return !wantsToGoOutside ? NodeStatus.success : NodeStatus.running;
      },
    );

    final walkTowardsDoorOutside = Task(() {
      if (!isAtTheDoor) {
        isMoving = true;
        add(
          MoveEffect.to(
            door.absolutePosition + Vector2(door.size.x * 0.5, 10),
            EffectController(
              duration: 3,
              curve: Curves.easeInOut,
            ),
            onComplete: () {
              isMoving = false;
              isAtTheDoor = true;
            },
          ),
        );
      }
      return isAtTheDoor ? NodeStatus.success : NodeStatus.running;
    });

    final walkTowardsCenterOfTheHouse = Task(() {
      if (!isAtCenterOfHouse) {
        isMoving = true;
        isInside = true;

        add(
          MoveEffect.to(
            house.absoluteCenter,
            EffectController(
              duration: 3,
              curve: Curves.easeInOut,
            ),
            onComplete: () {
              isMoving = false;
              wantsToGoOutside = true;
              isAtTheDoor = false;
              isAtCenterOfHouse = true;
            },
          ),
        );
      }
      return isInside ? NodeStatus.success : NodeStatus.running;
    });

    final checkIfDoorIsOpen = Condition(() => door.isOpen);

    final knockTheDoor = Task(() {
      door.knock();
      return NodeStatus.success;
    });

    final goOutsideSequence = Sequence(
      children: [
        Condition(() => wantsToGoOutside),
        Selector(
          children: [
            Sequence(
              children: [
                Condition(() => isInside),
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
        Condition(() => !wantsToGoOutside),
        Selector(
          children: [
            Sequence(
              children: [
                Condition(() => !isInside),
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
        Condition(() => isMoving),
        goOutsideSequence,
        goInsideSequence,
      ],
    );
    tickInterval = 2;
  }
}
