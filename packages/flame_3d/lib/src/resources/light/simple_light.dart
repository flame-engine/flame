import 'dart:math';

import 'package:flame_3d/src/resources/light/light.dart';

class SimpleLight extends Light {
  @override
  void update(double dt) {
    const radius = 15;
    final angle = DateTime.now().millisecondsSinceEpoch / 4000;
    final x = cos(angle) * radius;
    final z = sin(angle) * radius;
    position.setValues(x, 10, z);
  }
}