import 'package:flame_3d/resources.dart';

class LightingInfo {
  AmbientLight ambient = AmbientLight();

  Iterable<Light> lights = [];

  void apply(Shader shader) {
    ambient.apply(shader);

    // shader.setUInt('LightsInfo.numLights', lights.length);
    for (final (idx, light) in lights.indexed) {
      light.apply(idx, shader);
    }
  }

  static List<UniformSlot> shaderSlots = [
    UniformSlot.value('AmbientLight', {'color', 'intensity'}),
    // UniformSlot.value('LightsInfo', {'numLights'}),
    UniformSlot.value('Light0', {'position', 'color', 'intensity'}),
    UniformSlot.value('Light1', {'position', 'color', 'intensity'}),
    UniformSlot.value('Light2', {'position', 'color', 'intensity'}),
  ];
}
