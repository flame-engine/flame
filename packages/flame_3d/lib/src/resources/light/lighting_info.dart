import 'package:flame_3d/resources.dart';

class LightingInfo {
  AmbientLight ambient = AmbientLight();

  Iterable<Light> lights = [];

  void apply(Shader shader) {
    ambient.apply(shader);

    shader.setUInt('LightsInfo.numLights', lights.length);
    for (final light in lights) {
      light.apply(shader);
    }
  }

  static List<UniformSlot> shaderSlots = [
    UniformSlot.value('AmbientLight', {'color', 'intensity'}),
    UniformSlot.value('LightsInfo', {'numLights'}),
    UniformSlot.value('Light', {'position', 'color', 'intensity'}),
  ];
}