import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class LookAtSmoothExample extends FlameGame with TapDetector {
  static const description = 'This example demonstrates how a component can be '
      'made to smoothly rotate towards a target using the angleTo method. '
      'Tap anywhere to change the target point for both the choppers. '
      'It also shows how nativeAngle can be used to make the component '
      'oriented in the desired direction if the image is not facing the '
      'correct direction.';

  bool _isRotating = false;
  late SpriteAnimationComponent _chopper1;
  late SpriteAnimationComponent _chopper2;

  final CircleComponent _targetComponent = CircleComponent(
    radius: 5,
    anchor: Anchor.center,
    paint: BasicPalette.black.paint(),
  );

  @override
  Color backgroundColor() => const Color.fromARGB(255, 96, 145, 112);

  @override
  Future<void>? onLoad() async {
    camera.viewport = FixedResolutionViewport(Vector2(640, 360));
    final spriteSheet = SpriteSheet(
      image: await images.load('animations/chopper.png'),
      srcSize: Vector2.all(48),
    );

    _spawnChoppers(spriteSheet);
    _spawnInfoText();

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (!_targetComponent.isMounted) {
      add(_targetComponent);
    }

    // Ignore if choppers are already rotating.
    if (!_isRotating) {
      _isRotating = true;
      _targetComponent.position = info.eventPosition.game;

      _chopper1.add(
        RotateEffect.by(
          _chopper1.angleTo(_targetComponent.absolutePosition),
          LinearEffectController(1),
          onComplete: () => _isRotating = false,
        ),
      );

      _chopper2.add(
        RotateEffect.by(
          _chopper2.angleTo(_targetComponent.absolutePosition),
          LinearEffectController(1),
          onComplete: () => _isRotating = false,
        ),
      );
    }

    super.onTapDown(info);
  }

  void _spawnChoppers(SpriteSheet spriteSheet) {
    // Notice now the nativeAngle is set to pi because the chopper
    // is facing in down/south direction in the original image.
    add(
      _chopper1 = SpriteAnimationComponent(
        nativeAngle: pi,
        size: Vector2.all(64),
        anchor: Anchor.center,
        animation: spriteSheet.createAnimation(row: 0, stepTime: 0.05),
        position: Vector2(size.x * 0.3, size.y * 0.5),
      ),
    );

    // This chopper does not use correct nativeAngle, hence using
    // lookAt on it results in the sprite pointing in incorrect
    // direction visually.
    add(
      _chopper2 = SpriteAnimationComponent(
        size: Vector2.all(64),
        anchor: Anchor.center,
        animation: spriteSheet.createAnimation(row: 0, stepTime: 0.05),
        position: Vector2(size.x * 0.6, size.y * 0.5),
      ),
    );
  }

  // Just displays some information. No functional contribution to the example.
  void _spawnInfoText() {
    final _shaded = TextPaint(
      style: TextStyle(
        color: BasicPalette.white.color,
        fontSize: 20.0,
        shadows: const [
          Shadow(offset: Offset(1, 1), blurRadius: 1),
        ],
      ),
    );

    add(
      TextComponent(
        text: 'nativeAngle = pi',
        textRenderer: _shaded,
        anchor: Anchor.center,
        position: _chopper1.absolutePosition + Vector2(0, -50),
      ),
    );

    add(
      TextComponent(
        text: 'nativeAngle = 0',
        textRenderer: _shaded,
        anchor: Anchor.center,
        position: _chopper2.absolutePosition + Vector2(0, -50),
      ),
    );
  }
}
