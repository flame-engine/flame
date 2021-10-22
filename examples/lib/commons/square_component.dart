import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';

class SquareComponent extends PositionComponent with EffectsHelper {
  Paint paint = BasicPalette.white.paint();

  SquareComponent({int priority = 0, double size = 100.0})
      : super(
          size: Vector2.all(size),
          priority: priority,
          anchor: Anchor.center,
        );

  @override
  void render(Canvas c) {
    super.render(c);
    c.drawRect(size.toRect(), paint);
  }
}
