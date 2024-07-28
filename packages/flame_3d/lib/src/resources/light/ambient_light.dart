import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart';

class AmbientLight {
  Color color;
  double intensity;

  AmbientLight({
    this.color = const Color(0xFFFFFFFF),
    this.intensity = 0.1,
  }) : assert(intensity >= 0 && intensity <= 1);

  void apply(Shader shader) {
    shader.setVector3('AmbientLight.color', color.toVector3());
    shader.setFloat('AmbientLight.intensity', intensity);
  }
}