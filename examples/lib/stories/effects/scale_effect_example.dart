import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/src/effects2/controllers/standard_controller.dart'; // ignore: implementation_imports
import 'package:flame/src/effects2/scale_effect.dart'; // ignore: implementation_imports
import 'package:flutter/material.dart';

import '../../commons/square_component.dart';

class ScaleEffectExample extends FlameGame with TapDetector {
  static const String description = '''
    The `ScaleEffect` scales up the canvas before drawing the components and its
    children.
    In this example you can tap the screen and the component will scale up or
    down, depending on its current state.
  ''';

  late SquareComponent square;
  bool grow = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    square = SquareComponent(
      position: Vector2.all(200),
      paint: BasicPalette.white.paint()..style = PaintingStyle.stroke,
    );
    final childSquare = SquareComponent(position: Vector2.all(70), size: 20);
    square.add(childSquare);
    add(square);
  }

  @override
  void onTap() {
    final s = grow ? 300.0 : 100.0;

    grow = !grow;

    square.add(
      ScaleEffect.to(
        Vector2.all(s),
        standardController(
          duration: 1.5,
          curve: Curves.bounceInOut,
        ),
      ),
    );
  }
}
