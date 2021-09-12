import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';

class SquareComponent extends PositionComponent with EffectsHelper {
  Paint paint = BasicPalette.white.paint();

  SquareComponent({int priority = 0})
      : super(
          size: Vector2.all(100.0),
          priority: priority,
        );

  @override
  void render(Canvas c) {
    super.render(c);
    c.drawRect(size.toRect(), paint);
  }
}
