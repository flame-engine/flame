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
    if (numLights > _maxPointLights) {
      throw Exception('At most $_maxPointLights point lights are allowed');
    }

    // NOTE: using floats because Android GLES does not support integer uniforms
    // Refer to https://github.com/flutter/engine/pull/55329
    shader.setFloat('Lights.numLights', numLights.toDouble());
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

  static const _maxPointLights = 8;

  static List<UniformSlot> shaderSlots = [
    UniformSlot.value('AmbientLight'),
    UniformSlot.value('Lights'),
  ];
}
