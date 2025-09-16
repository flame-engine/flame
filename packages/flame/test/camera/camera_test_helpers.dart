import 'dart:ui';

import 'package:flame/components.dart';

class CrossHair extends PositionComponent {
  CrossHair({super.size, super.position, this.color = const Color(0xFFFF0000)})
    : super(anchor: Anchor.center);

  final Color color;
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
