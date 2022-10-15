import 'dart:ui';

import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class MoveAlongPathEffectGame extends FlameGame with HasTappableComponents {
  bool reset = false;
  @override
  Future<void> onLoad() async {
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        if (reset = !reset) {
          flower.add(
            MoveAlongPathEffect(
              Path()..quadraticBezierTo(100, 0, 50, -50),
              EffectController(duration: 1.5),
            ),
          );
        } else {
          flower.add(
            MoveAlongPathEffect(
              Path()..quadraticBezierTo(-100, 0, -50, 50),
              EffectController(duration: 1.5),
            ),
          );
        }
      },
    );
    add(flower);
  }
}
