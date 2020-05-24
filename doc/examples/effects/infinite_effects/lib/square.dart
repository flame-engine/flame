import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';

import 'dart:ui';

class Square extends PositionComponent {
  final Paint _paint;

  Square(this._paint, double x, double y, {double angle = 0.0}) {
    width = 100;
    height = 100;
    this.x = x;
    this.y = y;
    this.angle = angle;
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    canvas.translate(x, y);
    canvas.rotate(angle);
    canvas.translate(-x, -y);
    canvas.drawRect(toRect(), _paint);
  }
}
