import 'package:flame/anchor.dart';
import 'package:flame/components/position_component.dart';

import 'dart:ui';

import 'package:flame/extensions/vector2.dart';

class Square extends PositionComponent {
  static final _paint = Paint()..color = const Color(0xFFFFFFFF);

  Square() {
    size = Vector2.all(100);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paint);
  }
}
