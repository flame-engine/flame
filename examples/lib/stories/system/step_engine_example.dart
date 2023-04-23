import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StepEngineExample extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  static const description = '''
    This example demonstrates how the game can be advanced frame by frame using
    stepEngine method.

    To pause and un-pause the game anytime press the `P` key. Once paused, use
    the `S` key to step by one frame.

    Up arrow and down arrow can be used to increase or decrease the step time.
  ''';

  // Fixed resolution of the game.
  static final Vector2 _visibleSize = Vector2(320, 180);
  double _stepTimeMultiplier = 1;
  static const _stepTime = 1 / 60;

  @override
  Color backgroundColor() => BasicPalette.darkGreen.color;

  @override
  Future<void> onLoad() async {
    final carSprite = await Sprite.load('Car.png');
    final car = SpriteComponent(
      sprite: carSprite,
      anchor: Anchor.center,
      angle: -pi / 10,
      position: Vector2(0, _visibleSize.y / 3),
      children: [CircleHitbox()],
    );

    final world = World(
      children: [
        ..._createCircularDetectors(),
        PositionComponent(children: [car, _rotateEffect]),
      ],
    );

    final cameraComponent = CameraComponent.withFixedResolution(
      world: world,
      width: _visibleSize.x,
      height: _visibleSize.y,
      hudComponents: [_controlsText],
    );

    await addAll([world, cameraComponent]);
  }

  @override
  KeyEventResult onKeyEvent(_, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.keyP)) {
      paused = !paused;
    } else if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      stepEngine(stepTime: _stepTime * _stepTimeMultiplier);
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      _stepTimeMultiplier += 1;
      _controlsText.text = _text;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      _stepTimeMultiplier -= 1;
      _controlsText.text = _text;
    }
    return super.onKeyEvent(_, keysPressed);
  }

  // Creates the circle detectors.
  List<Component> _createCircularDetectors() {
    final componentsToAdd = <Component>[];
    final offsetVec = Vector2(0, -_visibleSize.y / 2.5);
    for (var i = 0; i < 12; ++i) {
      offsetVec.rotate(2 * pi / 12);
      componentsToAdd.add(
        _DetectorComponents(
          radius: 5,
          position: offsetVec,
          anchor: Anchor.center,
          children: [CircleHitbox()],
        ),
      );
    }
    return componentsToAdd;
  }

  final _rotateEffect = RotateEffect.by(
    2 * pi,
    InfiniteEffectController(
      SpeedEffectController(
        LinearEffectController(1),
        speed: 1,
      ),
    ),
  );

  String get _text =>
      'P: Pause/Unpause\nS: Step x$_stepTimeMultiplier\nUp: Increase step\nDown: Decrease step';

  late final _controlsText = TextBoxComponent(
    text: _text,
    textRenderer: TextPaint(
      style: TextStyle(
        color: BasicPalette.white.color,
        fontSize: 20.0,
        shadows: const [
          Shadow(offset: Offset(1, 1), blurRadius: 1),
        ],
      ),
    ),
  );
}

class _DetectorComponents extends CircleComponent with CollisionCallbacks {
  _DetectorComponents({
    super.radius,
    super.position,
    super.anchor,
    super.children,
  });

  @override
  void onCollisionStart(_, __) {
    paint.color = BasicPalette.black.color;
    super.onCollisionStart(_, __);
  }

  @override
  void onCollisionEnd(__) {
    paint.color = BasicPalette.white.color;
    super.onCollisionEnd(__);
  }
}
