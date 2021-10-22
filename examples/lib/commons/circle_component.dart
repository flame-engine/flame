import 'dart:ui';

import 'package:flame/components.dart';

class CircleComponent extends PositionComponent {
  CircleComponent({this.radius = 10.0})
      : paint = Paint()..color = const Color(0xFF60CB35),
        super(
          size: Vector2.all(2 * radius),
          anchor: Anchor.center,
        );

  Paint paint;
  double radius;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(radius, radius), radius, paint);
  }
}
