import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

import '../../commons/square_component.dart';

const sizeInfo = '''
The `SizeEffect` changes the size of the component, the sizes of the children
will stay the same.
In this example you can tap the screen and the component will size up or down,
depending on its current state.
''';

class SizeEffectGame extends FlameGame with TapDetector {
  late SquareComponent square;
  bool grow = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    square = SquareComponent()
      ..position.setValues(200, 200)
      ..anchor = Anchor.center;
    square.paint = BasicPalette.white.paint()..style = PaintingStyle.stroke;
    final childSquare = SquareComponent()
      ..position = Vector2.all(70)
      ..size = Vector2.all(20)
      ..anchor = Anchor.center;

    square.add(childSquare);
    add(square);
  }

  @override
  void onTap() {
    final s = grow ? 300.0 : 100.0;

    grow = !grow;
    square.add(
      SizeEffect(
        size: Vector2.all(s),
        speed: 250.0,
        curve: Curves.bounceInOut,
      ),
    );
  }
}
