import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colonists/terrain/terrain.dart';

class Grass extends PositionComponent with Terrain {
  static final _color = Paint()..color = const Color(0xff567d46);
  static final _debugColor = Paint()..color = Colors.black.withOpacity(.5);

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    canvas.drawRect(rect, _color);

    final rect2 = Rect.fromCenter(center: rect.center, height: 10, width: 10);
    canvas.drawRect(rect2, _debugColor);
  }

  @override
  double difficulty = 1.0;
}
