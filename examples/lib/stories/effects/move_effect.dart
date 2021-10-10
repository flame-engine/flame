import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_example/commons/circle_component.dart';
import 'package:flutter/material.dart';

import '../../commons/square_component.dart';

class MoveEffectGame extends FlameGame with TapDetector {
  late SquareComponent square;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    square = SquareComponent()..position.setValues(200, 150);
    add(square);
    add(Component()
        ..addAll([
          CircleComponent(radius: 3) ..position=Vector2(100, 100),
          CircleComponent(radius: 3) ..position=Vector2(50, 120),
          CircleComponent(radius: 3) ..position=Vector2(200, 400),
          CircleComponent(radius: 3) ..position=Vector2(150, 0),
          CircleComponent(radius: 3) ..position=Vector2(100, 300),
        ])
      );
  }

  @override
  void onTapUp(TapUpInfo info) {
    square.add(
      MoveEffect(
        path: [
          info.eventPosition.game,
          Vector2(100, 100),
          Vector2(50, 120),
          Vector2(200, 400),
          Vector2(150, 0),
          Vector2(100, 300),
        ],
        speed: 250.0,
        isAlternating: true,
        peakDelay: 2.0,
      ),
    );
  }
}
