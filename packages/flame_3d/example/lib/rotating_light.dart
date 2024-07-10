import 'dart:math';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';

class RotatingLight extends LightComponent {
  RotatingLight()
      : super.spot(
          position: Vector3.zero(),
        );

  @override
  void update(double dt) {
    const radius = 15;
    final angle = DateTime.now().millisecondsSinceEpoch / 4000;
    final x = cos(angle) * radius;
    final z = sin(angle) * radius;
    position.setValues(x, 10, z);
  }
}
