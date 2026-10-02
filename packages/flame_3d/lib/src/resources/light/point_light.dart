import 'package:flame_3d/resources.dart';

/// A point light that emits light in all directions equally.
class PointLight({
  required super.color,
  required super.intensity,
}) extends LightSource;
