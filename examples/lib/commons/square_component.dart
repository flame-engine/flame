import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class SquareComponent extends PositionComponent {
  Paint paint = BasicPalette.white.paint;

  SquareComponent() : super(size: Vector2.all(100.0));

  @override
  void render(Canvas c) {
    super.render(c);
    c.drawRect(size.toRect(), paint);
  }
}
