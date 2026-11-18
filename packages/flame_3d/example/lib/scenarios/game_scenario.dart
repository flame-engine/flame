import 'package:flame_3d_example/example_game_3d.dart';
import 'package:flame_3d_example/scenarios/boxes_scenario.dart';
import 'package:flame_3d_example/scenarios/colors_scenario.dart';
import 'package:flame_3d_example/scenarios/culling_scenario.dart';
import 'package:flame_3d_example/scenarios/houses_scenario.dart';
import 'package:flame_3d_example/scenarios/models_scenario.dart';
import 'package:flame_3d_example/scenarios/particles_scenario.dart';
import 'package:flame_3d_example/scenarios/shadows_scenario.dart';
import 'package:flame_3d_example/scenarios/showcase_scenario.dart';

abstract class GameScenario() {
  Future<void> onLoad();

  void setup(ExampleGame3D game);

  static const String defaultScenario = 'boxes';

  static final Map<String, GameScenario> scenarios = {
    'boxes': BoxesScenario(),
    'colors': ColorsScenario(),
    'culling': CullingScenario(),
    'houses': HousesScenario(),
    'models': ModelsScenario(),
    'particles': ParticlesScenario(),
    'shadows': ShadowsScenario(),
    'showcase': ShowcaseScenario(),
    'camera_lab': CameraLabScenario(),
  };

  static void defaultSetup(ExampleGame3D game) {
    scenarios[defaultScenario]?.setup(game);
  }

  static Future<void> loadAll() async {
    await Future.wait([
      for (final scenario in scenarios.values) scenario.onLoad(),
    ]);
  }
}
