import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart' as material;

class RotateAroundEffectExample extends FlameGame {
  static const description = '''
This example shows how to use the RotateAroundEffect to rotate a component
around a fixed point.
''';

  RotateAroundEffectExample()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: 400,
          height: 600,
        ),
        world: _RotateAroundEffectWorld(),
      );
}

class _RotateAroundEffectWorld extends World {
  @override
  void onLoad() {
    add(_GlowingBall(position: Vector2.zero(), radius: 30));
    final rotatingBalls = List.generate(
      4,
      (i) =>
          _GlowingBall(
            position: Vector2(100 + 10.0 * i, 0),
            radius: 10,
          )..add(
            RotateAroundEffect(
              tau,
              center: Vector2.zero(),
              EffectController(
                speed: 0.4 + 1.02 * i,
                infinite: true,
              ),
            ),
          ),
    );
    addAll(rotatingBalls);
  }
}

class _GlowingBall extends CircleComponent {
  _GlowingBall({
    required super.position,
    required super.radius,
  }) : super(anchor: Anchor.center);

  static final random = Random(6);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    paint = Paint()
      ..color = material.Colors.white
      ..shader = Gradient.radial(
        (size / 2).toOffset(),
        radius,
        [
          ColorExtension.random(base: 100, rng: random),
          ColorExtension.random(withAlpha: 0.2, rng: random),
        ],
        null,
        TileMode.clamp,
        null,
        Offset(radius / 2, radius / 2),
      );
  }
}
