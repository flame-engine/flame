import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/animation.dart';

class SizeEffectExample extends FlameGame with TapDetector {
  static const String description = '''
    The `SizeEffect` changes the size of the component, the sizes of the
    children will stay the same.
    In this example you can tap the screen and the component will size up or
    down, depending on its current state.
  ''';

  late Rectangle square;
  bool grow = true;

  @override
  Future<void> onLoad() async {
    square = Rectangle.square(
      size: 100,
      position: Vector2.all(200),
      paint: BasicPalette.white.paint()..style = PaintingStyle.stroke,
    );
    final childSquare = Rectangle.square(
      position: Vector2.all(70),
      size: 20,
    );
    square.add(childSquare);
    add(square);
  }

  @override
  void onTap() {
    final s = grow ? 300.0 : 100.0;

    grow = !grow;

    square.add(
      SizeEffect.to(
        Vector2.all(s),
        EffectController(duration: 1.5, curve: Curves.bounceInOut),
      ),
    );
  }
}
