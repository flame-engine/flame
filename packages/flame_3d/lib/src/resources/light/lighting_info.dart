import 'package:flame_3d/resources.dart';

class LightingInfo {
  Iterable<Light> lights = [];

  void apply(Shader shader) {
    _applyAmbientLight(shader);
    _applyPointLights(shader);
  }

  void _applyAmbientLight(Shader shader) {
    final ambient = _extractAmbientLight(lights);
    ambient.apply(shader);
  }

  void _applyPointLights(Shader shader) {
    final pointLights = lights.where((e) => e.source is PointLight);
    final numLights = pointLights.length;
    if (numLights > maxLights) {
      throw Exception('At most $maxLights point lights are allowed');
    }

    shader.setUint('LightsInfo.numLights', numLights);
    for (final (idx, light) in pointLights.indexed) {
      light.apply(idx, shader);
    }
  }

  AmbientLight _extractAmbientLight(Iterable<Light> lights) {
    final ambient = lights.where((e) => e.source is AmbientLight);
    if (ambient.isEmpty) {
      return AmbientLight();
    }
    if (ambient.length > 1) {
      throw Exception('At most one ambient light is allowed');
    }
    return ambient.first.source as AmbientLight;
  }

  static List<UniformSlot> shaderSlots = [
    UniformSlot.array('Light', {'position', 'color', 'intensity'}),
    UniformSlot.value('AmbientLight', {'color', 'intensity'}),
    UniformSlot.value('LightsInfo', {'numLights'}),
  ];

  /// The maximum number of point lights supported by the shader.
  /// Since we use fixed-length arrays in the shader, we cannot support an
  /// arbitrary number of lights.
  static const maxLights = 8;
}
