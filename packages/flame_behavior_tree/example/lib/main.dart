import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

typedef MyGame = FlameGame<GameWorld>;
const gameWidth = 320.0;
const gameHeight = 180.0;

void main() {
  runApp(const MainApp());
}

class const MainApp({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GameWidget<MyGame>.managed(
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

class GameWorld() extends World with HasGameRef {
  @override
  Future<void> onLoad() async {
    gameRef.camera.moveTo(Vector2(gameWidth * 0.5, gameHeight * 0.5));

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

    house.add(door);
    addAll([house, agent]);
  }
}

class Door({super.position, super.size, super.anchor})
    extends RectangleComponent
    with TapCallbacks {
  this : super(paint: BasicPalette.brown.paint());

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

class Agent({
  required final Door door,
  required final PositionComponent house,
  required Vector2 position,
}) extends PositionComponent with HasBehaviorTree {
  this : super(position: position);

  // Captured on construction, while the agent is still at its start position.
  final Vector2 _startPosition = position.clone();

  @override
  Future<void> onLoad() async {
    add(CircleComponent(radius: 3, anchor: Anchor.center));

    // Positions depend on the door and the house being mounted, so they are
    // computed when the nodes run and not when the tree is built.
    Vector2 outsideTheDoor() =>
        door.absolutePosition + Vector2(door.size.x * 0.5, 10);
    Vector2 insideTheDoor() =>
        door.absolutePosition + Vector2(door.size.x * 0.8, -15);

    // Keeps knocking until the door gets opened (tap the door to open it).
    // Nodes keep track of whether they are running, so every place in the tree
    // gets a node of its own.
    Node waitForDoor() {
      return Task((context) {
        if (door.isOpen) {
          return Status.success;
        }
        door.knock();
        return Status.running;
      });
    }

    // The tree is a loop: go inside, hang around, go outside, and again.
    // Each child of a sequence is resumed where it was left, so the agent
    // keeps walking even though the tree is ticked on every frame.
    behaviorTree = BehaviorTree(
      Repeat(
        Sequence([
          Wait(1),
          MoveTo((_) => outsideTheDoor(), duration: 3),
          waitForDoor(),
          MoveTo((_) => house.absoluteCenter, duration: 3),
          Wait(2),
          MoveTo((_) => insideTheDoor(), duration: 3),
          waitForDoor(),
          MoveTo((_) => outsideTheDoor(), duration: 2),
          MoveTo((_) => _startPosition, duration: 3),
        ]),
      ),
      owner: this,
    );
  }
}
