import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';

import 'dart:ui';

class Square extends PositionComponent {
  final Paint _paint;

  Square(this._paint, double x, double y) {
    width = 100;
    height = 100;
    this.x = x;
    this.y = y;
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(toRect(), _paint);
  }
}
