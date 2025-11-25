import 'dart:ui';

import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';

class MoveAlongPathEffectGame extends FlameGame {
  bool reset = false;
  @override
  Future<void> onLoad() async {
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        flower.add(
          MoveAlongPathEffect(
            reset
                ? (Path()..quadraticBezierTo(-100, 0, -50, 50))
                : (Path()..quadraticBezierTo(100, 0, 50, -50)),
            EffectController(duration: 1.5),
          ),
        );
        reset = !reset;
      },
    );
    add(flower);
  }
}
