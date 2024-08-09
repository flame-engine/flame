import 'dart:ui';

import 'package:flame_3d/resources.dart';

class AmbientLight {
  Color color;
  double intensity;

  AmbientLight({
    this.color = const Color(0xFFFFFFFF),
    this.intensity = 1.0,
  });

  void apply(Shader shader) {
    shader.setColor('AmbientLight.color', color);
    shader.setFloat('AmbientLight.intensity', intensity);
  }
}
