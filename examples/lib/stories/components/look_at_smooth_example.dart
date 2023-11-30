import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class LookAtSmoothExample extends FlameGame {
  static const description = 'This example demonstrates how a component can be '
      'made to smoothly rotate towards a target using the angleTo method. '
      'Tap anywhere to change the target point for both the choppers. '
      'It also shows how nativeAngle can be used to make the component '
      'oriented in the desired direction if the image is not facing the '
      'correct direction.';

  LookAtSmoothExample() : super(world: _TapWorld());

  late SpriteAnimationComponent _chopper1;
  late SpriteAnimationComponent _chopper2;

  @override
  Color backgroundColor() => const Color.fromARGB(255, 96, 145, 112);

  @override
  Future<void> onLoad() async {
    final spriteSheet = SpriteSheet(
      image: await images.load('animations/chopper.png'),
      srcSize: Vector2.all(48),
    );

    _spawnChoppers(spriteSheet);
    _spawnInfoText();
  }

  void _spawnChoppers(SpriteSheet spriteSheet) {
    // Notice now the nativeAngle is set to pi because the chopper
    // is facing in down/south direction in the original image.
    world.add(
      _chopper1 = SpriteAnimationComponent(
        nativeAngle: pi,
        size: Vector2.all(128),
        anchor: Anchor.center,
        animation: spriteSheet.createAnimation(row: 0, stepTime: 0.05),
      ),
    );

    // This chopper does not use correct nativeAngle, hence using
    // lookAt on it results in the sprite pointing in incorrect
    // direction visually.
    world.add(
      _chopper2 = SpriteAnimationComponent(
        size: Vector2.all(128),
        anchor: Anchor.center,
        animation: spriteSheet.createAnimation(row: 0, stepTime: 0.05),
        position: Vector2(0, 160),
      ),
    );
  }

  // Just displays some information. No functional contribution to the example.
  void _spawnInfoText() {
    final shaded = TextPaint(
      style: TextStyle(
        color: BasicPalette.white.color,
        fontSize: 30.0,
        shadows: const [
          Shadow(offset: Offset(1, 1), blurRadius: 1),
        ],
      ),
    );

    world.add(
      TextComponent(
        text: 'nativeAngle = pi',
        textRenderer: shaded,
        anchor: Anchor.center,
        position: _chopper1.absolutePosition + Vector2(0, -70),
      ),
    );

    world.add(
      TextComponent(
        text: 'nativeAngle = 0',
        textRenderer: shaded,
        anchor: Anchor.center,
        position: _chopper2.absolutePosition + Vector2(0, -70),
      ),
    );
  }
}

class _TapWorld extends World with TapCallbacks {
  bool _isRotating = false;

  final CircleComponent _targetComponent = CircleComponent(
    radius: 5,
    anchor: Anchor.center,
    paint: BasicPalette.black.paint(),
  );

  @override
  void onTapDown(TapDownEvent event) {
    if (!_targetComponent.isMounted) {
      add(_targetComponent);
    }

    // Ignore if choppers are already rotating.
    if (!_isRotating) {
      _isRotating = true;
      _targetComponent.position = event.localPosition;

      final choppers = children.query<SpriteAnimationComponent>();
      for (final chopper in choppers) {
        chopper.add(
          RotateEffect.by(
            chopper.angleTo(_targetComponent.absolutePosition),
            LinearEffectController(1),
            onComplete: () => _isRotating = false,
          ),
        );
      }
    }
  }
}
