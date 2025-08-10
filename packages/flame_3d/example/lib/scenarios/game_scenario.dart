import 'package:example/example_game_3d.dart';
import 'package:example/scenarios/boxes_scenario.dart';
import 'package:example/scenarios/models_scenario.dart';

abstract class GameScenario {
  Future<void> onLoad();

  void setup(ExampleGame3D game);

  static const String defaultScenario = 'boxes';

  static final Map<String, GameScenario> scenarios = {
    'boxes': BoxesScenario(),
    'models': ModelsScenario(),
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
