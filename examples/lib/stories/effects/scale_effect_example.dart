import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

import '../../commons/square_component.dart';

class ScaleEffectExample extends FlameGame with TapDetector {
  static const String description = '''
    The `ScaleEffect` scales up the canvas before drawing the components and its
    children.
    In this example you can tap the screen and the component will scale up or down,
    depending on its current state.
  ''';

  late SquareComponent square;
  bool grow = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    square = SquareComponent()
      ..position.setValues(200, 200)
      ..anchor = Anchor.center;
    square.paint = BasicPalette.white.paint()..style = PaintingStyle.stroke;
    final childSquare = SquareComponent(position: Vector2.all(70), size: 20);

    square.add(childSquare);
    add(square);
  }

  @override
  void onTap() {
    final s = grow ? 3.0 : 1.0;

    grow = !grow;
    square.add(
      ScaleEffect(
        scale: Vector2.all(s),
        speed: 2.0,
        curve: Curves.linear,
      ),
    );
  }
}
