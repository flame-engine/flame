import 'dart:ui';

import 'package:flame_3d/resources.dart';

/// A point light that emits light in all directions equally.
class PointLight extends LightSource {
  final Color color;
  final double intensity;

  PointLight({
    required this.color,
    required this.intensity,
  });

  @override
  void apply(int index, Shader shader) {
    shader.setColor('Light$index.color', color);
    shader.setFloat('Light$index.intensity', intensity);
  }
}
