import 'dart:math';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class RotatingLight extends LightComponent {
  RotatingLight() : super(
    light: Light(
      position: Vector3.zero(),
    ),
  );

  @override
  void update(double dt) {
    const radius = 15;
    final angle = DateTime.now().millisecondsSinceEpoch / 4000;
    final x = cos(angle) * radius;
    final z = sin(angle) * radius;
    light.position.setValues(x, 10, z);
  }
}