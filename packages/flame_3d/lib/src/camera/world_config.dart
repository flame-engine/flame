import 'package:flame_3d/src/resources/light/ambient_light.dart';

class WorldConfig {
  final AmbientLight ambientLight;

  WorldConfig({
    AmbientLight? ambientLight,
  }) : ambientLight = ambientLight ?? AmbientLight();
}