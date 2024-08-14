import 'package:flame_3d/resources.dart';

/// A point light that emits light in all directions equally.
class PointLight extends LightSource {
  PointLight({
    required super.color,
    required super.intensity,
  });
}
