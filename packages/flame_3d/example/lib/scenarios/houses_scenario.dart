import 'package:flame/game.dart';
import 'package:flame_3d_example/houses/houses_game.dart';
import 'package:flame_3d_example/scenarios/standalone_scenario.dart';

/// A 2D game with a hundred and more 3D houses in one embedded 3D layer, see
/// [HousesGame].
class HousesScenario() extends StandaloneScenario {
  @override
  Game createGame() => HousesGame();
}
