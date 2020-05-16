import 'package:flame/components/component.dart';

import 'dart:ui';

class Square extends PositionComponent {
  static final _paint = Paint()..color = const Color(0xFFFFFFFF);

  Square() {
    width = 100;
    height = 100;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(toRect(), _paint);
  }
}
