import 'package:flame_3d/resources.dart';

/// Describes the properties of a light source.
/// There are three types of light sources: directional, point, and spot.
/// Currently only [SpotLight] is implemented.
abstract class LightSource {
  void apply(Shader shader);
}
