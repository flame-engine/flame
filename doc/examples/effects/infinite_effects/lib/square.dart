import 'dart:ui';

import 'package:flame/components.dart';

class Square extends PositionComponent {
  final Paint _paint;

  Square(this._paint, Vector2 position, {double angle = 0.0}) {
    size = Vector2.all(100.0);
    this.position = position;
    this.angle = angle;
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paint);
  }
}
