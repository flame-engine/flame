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
    if (numLights > 3) {
      // temporary, until we support dynamic arrays
      throw Exception('At most 3 point lights are allowed');
    }

    shader.setUint('LightsInfo.numLights', numLights);
    for (final (index, light) in pointLights.indexed) {
      light.apply(index, shader);
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
    UniformSlot.value('AmbientLight', {'color', 'intensity'}),
    UniformSlot.value('LightsInfo', {'numLights'}),
    UniformSlot.value('Light0', {'position', 'color', 'intensity'}),
    UniformSlot.value('Light1', {'position', 'color', 'intensity'}),
    UniformSlot.value('Light2', {'position', 'color', 'intensity'}),
  ];
}
