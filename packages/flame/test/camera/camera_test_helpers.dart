import 'dart:ui';

import 'package:flame/components.dart';

class CrossHair({
  super.size,
  super.position,
  final Color color = const Color(0xFFFF0000),
}) extends PositionComponent {
  this : super(anchor: Anchor.center);

  Paint get _paint => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..color = color;

  @override
  void render(Canvas canvas) {
    canvas.drawLine(Offset(size.x / 2, 0), Offset(size.x / 2, size.y), _paint);
    canvas.drawLine(Offset(0, size.y / 2), Offset(size.x, size.y / 2), _paint);
  }
}
