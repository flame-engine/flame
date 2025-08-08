import 'package:example/example_game_3d.dart';
import 'package:example/scenarios/boxes_setup.dart';

abstract class GameScenario {
  void setup(ExampleGame3D game);

  static final Map<String, GameScenario> scenarios = {
    'boxes': BoxesScenario(),
  };
}
