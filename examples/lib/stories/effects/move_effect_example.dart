import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MoveEffectExample extends FlameGame {
  static const description = '''
    Top square has `MoveEffect.to` effect that makes the component move along a
    straight line back and forth. The effect uses a non-linear progression
    curve, which makes the movement non-uniform.

    The middle green square has a combination of two movement effects: a
    `MoveEffect.to` and a `MoveEffect.by` which forces it to periodically jump.

    At the bottom there are 60 more components which demonstrate movement along
    an arbitrary path using `MoveEffect.along`.
  ''';

  @override
  void onMount() {
    const tau = Transform2D.tau;
    camera.viewport = FixedResolutionViewport(Vector2(400, 600));

    final paint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.deepOrange;
    final paint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.greenAccent;

    add(
      RectangleComponent.square(
        position: Vector2(20, 50),
        size: 20,
        paint: paint1,
      )..add(
          MoveEffect.to(
            Vector2(380, 50),
            EffectController(
              duration: 3,
              reverseDuration: 3,
              infinite: true,
              curve: Curves.easeOut,
            ),
          ),
        ),
    );
    add(
      RectangleComponent.square(
        position: Vector2(20, 150),
        size: 20,
        paint: paint2,
      )
        ..add(
          MoveEffect.to(
            Vector2(380, 150),
            EffectController(
              duration: 3,
              reverseDuration: 3,
              infinite: true,
            ),
          ),
        )
        ..add(
          MoveEffect.by(
            Vector2(0, -50),
            EffectController(
              duration: 0.25,
              reverseDuration: 0.25,
              startDelay: 1,
              atMinDuration: 2,
              curve: Curves.ease,
              infinite: true,
            ),
          ),
        ),
    );

    final path1 = Path()..moveTo(200, 250);
    for (var i = 1; i <= 5; i++) {
      final x = 200 + 100 * sin(i * tau * 2 / 5);
      final y = 350 - 100 * cos(i * tau * 2 / 5);
      path1.lineTo(x, y);
    }
    for (var i = 0; i < 40; i++) {
      add(
        CircleComponent(radius: 5)
          ..position = Vector2(0, -1000)
          ..add(
            MoveAlongPathEffect(
              path1,
              EffectController(
                duration: 10,
                startDelay: i * 0.2,
                infinite: true,
              ),
              absolute: true,
            ),
          ),
      );
    }

    final path2 = Path()..addOval(const Rect.fromLTRB(80, 230, 320, 470));
    for (var i = 0; i < 20; i++) {
      add(
        RectangleComponent.square(size: 10)
          ..paint = (Paint()..color = Colors.tealAccent)
          ..add(
            MoveAlongPathEffect(
              path2,
              EffectController(
                duration: 6,
                startDelay: i * 0.3,
                infinite: true,
              ),
              oriented: true,
            ),
          ),
      );
    }
  }
}
