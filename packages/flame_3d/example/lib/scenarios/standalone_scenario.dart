import 'package:flame/game.dart';
import 'package:flame_3d_example/example_game_3d.dart';
import 'package:flame_3d_example/scenarios/game_scenario.dart';

/// A scenario that runs a game of its own, shown instead of the 3D example
/// game until the user goes back, rather than adding to the 3D world.
abstract class StandaloneScenario() implements GameScenario {
  /// Creates the game of this scenario.
  Game createGame();

  @override
  Future<void> onLoad() async {}

  @override
  void setup(ExampleGame3D game) => game.standaloneGame.value = createGame;
}
