import 'dart:ui' show Color;

import 'package:flame_3d/resources.dart';

class AmbientLight extends LightSource {
  AmbientLight({
    super.color = const Color(0xFFFFFFFF),
    super.intensity = 0.2,
  });

  void apply(Shader shader) {
    shader.setColor('AmbientLight.color', color);
    shader.setFloat('AmbientLight.intensity', intensity);
  }
}
