import 'dart:ui';

import 'package:flame_3d/core.dart';
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
  void apply(Shader shader) {
    shader.setVector3('Light.color', color.toVector3());
    shader.setFloat('Light.intensity', intensity);
  }
}